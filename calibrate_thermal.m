% [cm mm aa stats] = align_thermal('/Users/benjaminblonder/Documents/rmbl/rmbl 2016/thermal ecology/thermal data/cbt june 20th diurnal/combined/', 20, 1);
% [Tkelvin_aligned_calibrated, finalstats] = calibrate_thermal(aa, stats, 263, 343, 1, '/Users/benjaminblonder/Documents/rmbl/rmbl 2016/thermal ecology/thermal data/cbt june 20th diurnal/temperature_reference_CBT_20_06_2016_Rozi.xlsx', 'cbt_2016_06_20_newer.mat');

% assumes that stats are in the format of 
% [hours, minutes, seconds, temp_black, temp_refl, temp_sky]

function [Tkelvin_aligned_calibrated, finalstats] = calibrate_thermal(image_array, stats, bound_temp_lo, bound_temp_hi, dogroundcalibration, xlsinputname, outputname)
    if dogroundcalibration==1
        xls_raw = xlsread(xlsinputname);
        xls_time = (xls_raw(:,1)*60 + xls_raw(:,2)) * 60; % convert to seconds
        xls_time = xls_time - xls_time(1);
        xls_temp_black = xls_raw(:,4) + 273.15;
        xls_temp_refl = xls_raw(:,5) + 273.15;
    end
    
    num_files = size(image_array,3);

    image_mean = zeros([size(image_array,1) size(image_array,2)]);
    for i=1:num_files
        image_mean = image_mean + double(image_array(:,:,i));
        fprintf('%d\n',i);
    end
    image_mean = image_mean / num_files;
    
    % calculate time deltas
    time_raw = nan([length(stats), 6]);
    time_elapsed = zeros([length(stats), 1]);
    for i=1:length(stats)        
        try
            thisdate = stats{i}.gps_utc;
            time_raw(i,:) = datevec(thisdate, 'yyyy-mm-ddTHH:MM:SS.000Z');
        end
    end
    % convert to elapsed time
    for i=1:length(stats)
        try
            time_elapsed(i) = etime(time_raw(i,:),time_raw(1,:));
        end
    end
    
    % get values of the xls temperatures at these times
    if dogroundcalibration==1
        temp_black = interp1(xls_time, xls_temp_black, time_elapsed,'spline');
        temp_refl = interp1(xls_time, xls_temp_refl, time_elapsed,'spline');
    else
        temp_black = NaN([length(time_elapsed) 1]);
        temp_refl = NaN([length(time_elapsed) 1]);
    end
    
    % fill in other stats
    temp_atm = 293*ones([length(stats), 1]);
    temp_reflected = 293*ones([length(stats), 1]);
    temp_external_optics = 293*ones([length(stats), 1]);
    relative_humidity = 0.5*ones([length(stats), 1]);
    emissivity = 0.97*ones([length(stats), 1]);
    distance_focal = 2*ones([length(stats), 1]);
    for i=1:length(stats)
        try
            temp_atm(i) = stats{i}.wx_temp_air_c + 273.15; %in C, convert to K
        end   
        
        try
            temp_reflected(i) = temp_refl(i);
        end  

        try
            temp_external_optics(i) = stats{i}.TSens;
        end 
        
        try
            relative_humidity(i) = stats{i}.wx_rel_hum_pct / 100;
        end
        
        try
            distance_focal(i) = stats{i}.FocusDistance;
            if (distance_focal(i) > 2)
                distance_focal(i) = 2;
            end
        end
    end
    
    % convert radiometric counts to temperatures using trefl values
    %temp_array = repmat(single(0), size(image_array));
    temp_array = repmat(uint16(0), size(image_array));
    for i=1:length(stats)
        fprintf('*');
        ithis = image_array(:,:,i);
        %ithis(ithis==0) = NaN; % remove any extraneous values values
        
        temp_this = calibrated_temperature_simple(...
                double(image_array(:,:,i)), ...
                temp_atm(i), ...
                temp_reflected(i), ...
                temp_external_optics(i), ...
                relative_humidity(i), ...
                emissivity(i), ...
                distance_focal(i) ...
            );
        
        % remove further extraneous values
        %temp_this(temp_this < bound_temp_lo) = NaN;
        %temp_this(temp_this > bound_temp_hi) = NaN;
        temp_this(temp_this < bound_temp_lo) = 0;
        temp_this(temp_this > bound_temp_hi) = 0;
        
        %temp_array(:,:,i) = temp_this;
        temp_array(:,:,i) = temp_this*100;
    end
    fprintf('\n');
    
    if (dogroundcalibration==1)
        % choose region of interest
        
        f1 = figure('Name','Select ROI for black reference');
        imshow(rescale_image_quantile(image_mean,0.05,0.95));
        bw = roipoly;
        pixels_keep = bw>0;
        close(f1)

        % calculate stats in this region
        temperature_stats = zeros([num_files 5]);
        for i=1:num_files
            %temp_this = temp_array(:,:,i);
            temp_this = double(temp_array(:,:,i)) / 100;
            pixels_this = temp_this(pixels_keep);
            % keep non-NA pixels
            %pixels_this = pixels_this(~isnan(pixels_this));
            pixels_this = pixels_this(pixels_this>0);

            temperature_stats(i,1) = mean(pixels_this);
            temperature_stats(i,2) = std(pixels_this);
            temperature_stats(i,3) = quantile(pixels_this,0.05);
            temperature_stats(i,4) = quantile(pixels_this,0.5);
            temperature_stats(i,5) = quantile(pixels_this,0.95); 

            fprintf('.');
        end
        fprintf('\n')
        
        % show plots
        f2 = figure('Name','Black ref (black) uncalibrated (green) recalibrated (red)');
        plot(time_elapsed, temp_black,'-k'); hold on;
        plot(time_elapsed, temperature_stats(:,4),'-g');
        
        inputans = inputdlg({'Start time (s)','Stop time (s)'},'Select index range', 1, {sprintf('%d',time_elapsed(1)),sprintf('%d',time_elapsed(length(time_elapsed)))}); 
        start_time = str2num(inputans{1});
        stop_time = str2num(inputans{2});
        index_start = find(time_elapsed >= start_time,1,'first');
        index_stop = find(time_elapsed < stop_time,1,'last');
        
        [b,~,~,~,~] = regress(temp_black(index_start:index_stop), [ones(size(temperature_stats(index_start:index_stop,4))) temperature_stats(index_start:index_stop,4) temperature_stats(index_start:index_stop,4).^2]);

        Tkelvin_aligned_calibrated = uint16(temp_array);
        for i=1:num_files
            temp_this = double(temp_array(:,:,i))/100;
            Tkelvin_aligned_calibrated(:,:,i) = uint16( (b(1) + b(2) * temp_this + b(3) * temp_this.^2)*100 );
            fprintf('|');
        end
        fprintf('\n');
        %Tkelvin_aligned_calibrated = b(1) + (b(2)*100)*temp_array + (b(3)*100^2)*temp_array.^2;
        %Tkelvin_aligned_calibrated = temp_array;
        
        temp_new = zeros([num_files 1]);
        for i=1:num_files
            temp_this = double(Tkelvin_aligned_calibrated(:,:,i))/100;
            pixels_this = temp_this(pixels_keep);
            pixels_this = pixels_this(pixels_this>0);
            temp_new(i) = quantile(pixels_this,0.5);
            fprintf('/');
        end
        fprintf('\n');


        plot(time_elapsed, temp_new,'-r')
    else
        Tkelvin_aligned_calibrated = temp_array;
    end
    
    
    mediantemp = zeros([size(Tkelvin_aligned_calibrated,3) 1]);
    mediantime = zeros([size(Tkelvin_aligned_calibrated,3) 1]);
    for i=1:size(Tkelvin_aligned_calibrated,3)
        pixels_all = double(Tkelvin_aligned_calibrated(:,:,i))/100;
        %pixels_all = pixels_all(~isnan(pixels_all));
        pixels_all = pixels_all(pixels_all>0);
        
        mediantemp(i) = median(pixels_all);
        mediantime(i) = time_elapsed(i);
        fprintf('-');
    end
    fprintf('\n');
    
    f4 = figure('Name','Image median (magenta)');
    plot(time_elapsed, mediantemp,'-m');
    
    finalstats = [time_elapsed temp_black temp_atm temp_reflected temp_external_optics relative_humidity emissivity distance_focal time_raw]; 
    
    dosave = questdlg('Save matrix of output','Do save?','yes','no','yes');
    if (strcmp(dosave,'yes'))
        save(outputname, 'Tkelvin_aligned_calibrated', 'finalstats','-v7.3'); % this allows for partial loading
    end
end