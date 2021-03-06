% [cm mm aa stats] = align_thermal('/Users/benjaminblonder/Documents/rmbl/rmbl 2016/thermal ecology/thermal data/cbt jun 20/thermal/combined/', 20, 1);
% [Tkelvin_aligned_calibrated, finalstats] = calibrate_thermal(aa, stats, 263, 343, 1, '/Users/benjaminblonder/Documents/rmbl/rmbl 2016/thermal ecology/thermal data/cbt jun 20/temperature_reference_CBT_20_06_2016_Rozi.xlsx', '/Users/benjaminblonder/Documents/rmbl/rmbl 2016/thermal ecology/thermal data/cbt jun 20/thermal/combined/160620_133726-000000-002000-visible.png', 'cbt_2016_06_20_newest.mat');

% [cm mm aa stats]= align_thermal('/Users/benjaminblonder/Documents/rmbl/rmbl 2016/thermal ecology/thermal data/pfeiler jun 27/thermal/combined/', 10, 1, 0.5, 200);
% [Tkelvin_aligned_calibrated, finalstats] = calibrate_thermal(aa, stats, 263, 343, 1, '/Users/benjaminblonder/Documents/rmbl/rmbl 2016/thermal ecology/thermal data/pfeiler jun 27/reference_temperature_PFEILER_27_06_2016.xlsx', 800, '/Users/benjaminblonder/Documents/rmbl/rmbl 2016/thermal ecology/thermal data/pfeiler jun 27/thermal/thermal_control_160627_173852/160627_173852-000000-000300-visible.png', 'pfeiler_2016_06_27.mat');

% [cm mm aa stats]= align_thermal('/Users/benjaminblonder/Documents/rmbl/rmbl 2016/thermal ecology/thermal data/painterboy jul 3/thermal/combined/', 2, 1, 0.5, 200);
% [Tkelvin_aligned_calibrated, finalstats] = calibrate_thermal(aa, stats, 263, 343, 1, '/Users/benjaminblonder/Documents/rmbl/rmbl 2016/thermal ecology/thermal data/painterboy jul 3/PBM 30.06.2016 temperatures.xlsx', -1250, '/Users/benjaminblonder/Documents/rmbl/rmbl 2016/thermal ecology/thermal data/painterboy jul 3/thermal/combined/160630_142527-000000-015600-visible.png', 'painterboy_2016_07_03.mat');

% [cm mm aa stats]= align_thermal('/Users/benjaminblonder/Documents/rmbl/rmbl 2016/thermal ecology/thermal data/almont jul 14/thermal/combined/', 2, 1, 0.5, 200);
% [Tkelvin_aligned_calibrated, finalstats] = calibrate_thermal(aa, stats, 263, 343, 1, '/Users/benjaminblonder/Documents/rmbl/rmbl 2016/thermal ecology/thermal data/almont jul 14/thermal/Refence Data Sheet almont jul 15.xlsx', 0, '/Users/benjaminblonder/Documents/rmbl/rmbl 2016/thermal ecology/thermal data/almont jul 14/thermal/combined/952526-000000-008600-visible.png', 'almont_2016_07_14.mat');

% [cm mm aa stats]= align_thermal('/Users/benjaminblonder/Documents/rmbl/rmbl 2016/thermal ecology/thermal data/pfeiler july 8/thermal/combined/', 2, 1, 0.5, 200);
% [Tkelvin_aligned_calibrated, finalstats] = calibrate_thermal(aa, stats, 263, 343, 1, '/Users/benjaminblonder/Documents/rmbl/rmbl 2016/thermal ecology/thermal data/pfeiler july 8/thermal/reference_temperature_PFEILER_08_07_2016.xlsx', 0, '/Users/benjaminblonder/Documents/rmbl/rmbl 2016/thermal ecology/thermal data/pfeiler july 8/thermal/combined/104254-000000-000000-visible.png', 'pfeiler_2016_07_08.mat');

% [cm mm aa stats]= align_thermal('/Users/benjaminblonder/Documents/rmbl/rmbl 2016/thermal ecology/thermal data/road 23 jun/thermal/combined/', 2, 1, 0.5, 200);
% [Tkelvin_aligned_calibrated, finalstats] = calibrate_thermal(aa, stats, 263, 343, 1, '/Users/benjaminblonder/Documents/rmbl/rmbl 2016/thermal ecology/thermal data/road 23 jun/temperature_reference_ROAD_23_06_2016.xlsx', 1175, '/Users/benjaminblonder/Documents/rmbl/rmbl 2016/thermal ecology/thermal data/road 23 jun/thermal/combined/160623_134700-000000-007400-visible.png', 'road_2016_06_23.mat');

% [cm mm aa stats]= align_thermal('/Users/benjaminblonder/Documents/rmbl/rmbl 2016/rmbl thermal ecology/thermal data/baldy 28 jul/thermal/combined 1/', 2, 1, 0.5, 200);
% aa_small = aa(:,:,1:2980); % due to high wind & collapse at the end-
% stats_small = stats(1:2980);
% scary frames!
% [Tkelvin_aligned_calibrated, finalstats] = calibrate_thermal(aa_small, stats_small, 263, 343, 1, '/Users/benjaminblonder/Documents/rmbl/rmbl 2016/rmbl thermal ecology/thermal data/baldy 28 jul/thermal/reference_temperature_baldy_28jul.xlsx', 100, '/Users/benjaminblonder/Documents/rmbl/rmbl 2016/rmbl thermal ecology/thermal data/baldy 28 jul/thermal/combined 1/092163-000001-003600-visible.png', 'baldy_partone_2016_07_28.mat');

% [cm mm aa stats]=
% align_thermal('/Users/benjaminblonder/Documents/rmbl/rmbl 2016/rmbl thermal ecology/thermal data/baldy 28 jul/thermal/combined 2/', 2, 1, 0.5, 200);`

% take one - with calibration first part of day
% aa_small = aa(:,:,1:2500);
% stats_small = stats(1:2500);
% [Tkelvin_aligned_calibrated, finalstats] = calibrate_thermal(aa_small, stats_small, 263, 343, 1, '/Users/benjaminblonder/Documents/rmbl/rmbl 2016/rmbl thermal ecology/thermal data/baldy 28 jul/thermal/reference_temperature_baldy_28jul.xlsx', 0, '/Users/benjaminblonder/Documents/rmbl/rmbl 2016/rmbl thermal ecology/thermal data/baldy 28 jul/thermal/combined 2/160728_194758-000000-010300-visible.png', 'baldy_parttwo_2016_07_28.mat');

% no ground calibration second time
% [Tkelvin_aligned_calibrated, finalstats] = calibrate_thermal(aa, stats, 263, 343, 0, '/Users/benjaminblonder/Documents/rmbl/rmbl 2016/rmbl thermal ecology/thermal data/baldy 28 jul/thermal/reference_temperature_baldy_28jul.xlsx', 0, '/Users/benjaminblonder/Documents/rmbl/rmbl 2016/rmbl thermal ecology/thermal data/baldy 28 jul/thermal/combined 2/160728_194758-000000-010300-visible.png', 'baldy_parttwo_2016_07_28.mat');




% assumes that stats (from camera) are in the format of 
% [hours, minutes, seconds, temp_black, temp_refl, temp_sky, ...]

function [Tkelvin_aligned_calibrated, finalstats] = calibrate_thermal(image_array, stats, bound_temp_lo, bound_temp_hi, dogroundcalibration, xlsinputname, time_offset, file_visible_lores, outputname)
    if dogroundcalibration==1
        xls_raw = xlsread(xlsinputname);
        xls_time = (xls_raw(:,1)*60 + xls_raw(:,2)) * 60; % convert to seconds
        xls_time_elapsed = xls_time - xls_time(1);
        xls_temp_black = xls_raw(:,4) + 273.15;
        xls_temp_refl = xls_raw(:,5) + 273.15;

    end
    
    num_files = size(image_array,3);
    
    % calculate time deltas
    time_raw = nan([length(stats), 6]);
    time_elapsed = zeros([length(stats), 1]);
    for i=1:length(stats)        
        %try
            %thisdate = stats{i}.gps_utc;
            %time_raw(i,:) = datevec(thisdate, 'yyyy-mm-ddTHH:MM:SS.000Z');
        %end
        try
            time_raw(i,:) = datevec(stats{i}.Date,'yymmdd-HHMMSS');
        end
    end
    % convert to elapsed time
    for i=1:length(stats)
        try
            time_elapsed(i) = etime(time_raw(i,:),time_raw(1,:));
        end
    end
    
    time_elapsed
    
    %return;
    
    image_mean = zeros([size(image_array,1) size(image_array,2)]);
    for i=1:num_files
        image_mean = image_mean + double(image_array(:,:,i));
        fprintf('%d\n',i);
    end
    image_mean = image_mean / num_files;
    
    % fill in other stats
    temp_atm = 293*ones([length(stats), 1]);
    temp_reflected = 293*ones([length(stats), 1]);
    temp_external_optics = 293*ones([length(stats), 1]);
    relative_humidity = 0.5*ones([length(stats), 1]);
    emissivity = 0.97*ones([length(stats), 1]);
    distance_focal = 2*ones([length(stats), 1]);
    light_ir = 0*ones([length(stats), 1]);
    light_vis = 0*ones([length(stats), 1]);
    light_uv = 0*ones([length(stats), 1]);
    pressure = NaN([length(stats), 1]);
    temp_sens = 293*ones([length(stats), 1]);
    latitude = NaN([length(stats), 1]);
    longitude = NaN([length(stats), 1]);
    
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
        
        try
            light_ir(i) = stats{i}.wx_ir_lux;
        end
        
        try
            light_vis(i) = stats{i}.wx_vis_lux;
        end
        
        try
            light_uv(i) = stats{i}.wx_uv_lux;
        end
        
        try
            pressure(i) = stats{i}.wx_pressure_hpa;
        end
        
        try
            temp_sens(i) = stats{i}.TSens;
        end
        
        try
            latitude(i) = stats{i}.gps_latitude;
        end
        
        try
            longitude(i) = stats{i}.gps_longitude;
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
    
    if (dogroundcalibration==0)
        temp_black = NaN([length(time_elapsed) 1]);
    end
    
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
        

        
        regressionfitagain = true;
        while (regressionfitagain==true)
            inputans = inputdlg({'Start time (s)','Stop time (s)','Delta (s)'},'Select index range', 1, {'0','45000',sprintf('%d', time_offset)}); 
            start_time = str2num(inputans{1});
            stop_time = str2num(inputans{2});
            time_offset = str2num(inputans{3});
            index_start = find(time_elapsed >= (start_time),1,'first');
            index_stop = find(time_elapsed < (stop_time),1,'last');

            % get values of the xls temperatures at these times
            if dogroundcalibration==1
                temp_black = interp1(xls_time_elapsed - time_offset, xls_temp_black, time_elapsed,'spline',NaN);
            end
            
            % show plots
            f2 = figure('Name','Black ref (black) uncalibrated (green) xlstime (blue) recalibrated (red)');
            plot(time_elapsed, temp_black,'-k'); hold on;
            plot(time_elapsed, temperature_stats(:,4),'-g');
            
            ts = temperature_stats(index_start:index_stop,4);
            [b,~,~,~,~] = regress(temp_black(index_start:index_stop), [ones(size(ts)) ts ts.^2 ]);

            plot(xls_time_elapsed - time_offset, xls_temp_black,'-b'); hold on; 
            plot(time_elapsed(index_start:index_stop), b(1) + b(2) * ts + b(3) * ts.^2, '-r');
            
            drawnow; 
            
            regressionfitagain = ~strcmp(questdlg('Done?','Fit','Yes','No','Yes'),'Yes');
            
            close(f2);
        end

        Tkelvin_aligned_calibrated = uint16(temp_array);
        for i=1:num_files
            temp_this = double(temp_array(:,:,i))/100;
            Tkelvin_aligned_calibrated(:,:,i) = uint16(100*( b(1) + b(2) * temp_this + b(3) * temp_this.^2 ) );
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
    
    
%     mediantemp = zeros([size(Tkelvin_aligned_calibrated,3) 1]);
%     mediantime = zeros([size(Tkelvin_aligned_calibrated,3) 1]);
%     for i=1:size(Tkelvin_aligned_calibrated,3)
%         pixels_all = double(Tkelvin_aligned_calibrated(:,:,i))/100;
%         %pixels_all = pixels_all(~isnan(pixels_all));
%         pixels_all = pixels_all(pixels_all>0);
%         
%         mediantemp(i) = median(pixels_all);
%         mediantime(i) = time_elapsed(i);
%         fprintf('-');
%     end
%     fprintf('\n');
    
    %f4 = figure('Name','Image median (magenta)');
    %plot(time_elapsed, mediantemp,'-m');
    
    finalstats = table(time_elapsed, temp_black, temp_atm, temp_reflected, temp_external_optics, relative_humidity, emissivity, distance_focal, light_vis, light_ir, light_uv, pressure, temp_sens, latitude, longitude, time_raw); 
    
    % do visible alignment
    image_visible_lores = imread(file_visible_lores);
    points_thermal_lores = [];
    points_visible_lores = [];
    whichim = floor(size(Tkelvin_aligned_calibrated,3)/2);
    image_thermal_representative = double(Tkelvin_aligned_calibrated(:,:,whichim))/100;
    image_thermal_representative = imresize(image_thermal_representative, 2);
    image_thermal_representative = rescale_image_quantile(image_thermal_representative, 0.01, 0.99);
    image_thermal_representative = imsharpen(image_thermal_representative,'Radius',2,'Amount',1.5);
    image_thermal_representative = ind2rgb(floor(255*image_thermal_representative),hot(255));

    [image_fused_lores, image_visible_lores_registered, points_thermal_lores, points_visible_lores] = image_align(image_thermal_representative, image_visible_lores, points_thermal_lores, points_visible_lores); 
    
    dosave = questdlg('Save matrix of output','Do save?','yes','no','yes');
    if (strcmp(dosave,'yes'))
        if dogroundcalibration==0
            b = NaN; % this allows for partial loading
        end
        
        save(outputname, 'Tkelvin_aligned_calibrated', 'finalstats','image_visible_lores_registered','b','time_offset', '-v7.3'); % this allows for partial loading
    end
end