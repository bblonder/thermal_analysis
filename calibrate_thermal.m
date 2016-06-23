% calibrate_thermal(aa, stats, '/Users/benjaminblonder/Documents/rmbl/rmbl 2016/thermal ecology/thermal data/cbt june 20th diurnal/temperature_reference_CBT_20_06_2016_Rozi.xlsx')

function [Tkelvin_aligned_calibrated finalstats] = calibrate_thermal(image_array, stats, xlsname)
    xls_raw = xlsread(xlsname);
    xls_time = (xls_raw(:,1)*60 + xls_raw(:,2)) * 60; % convert to seconds
    xls_time = xls_time - xls_time(1);
    xls_temp_black = xls_raw(:,4) + 273.15;
    xls_temp_refl = xls_raw(:,5) + 273.15;
    
    num_files = size(image_array,3);

    image_mean = zeros([size(image_array,1) size(image_array,2)]);
    for i=1:num_files
        image_mean = image_mean + double(image_array(:,:,i));
        fprintf('.');
    end
    image_mean = image_mean / num_files;
    
    % calculate time deltas
    time_raw = nan([length(stats), 6]);
    time_elapsed = zeros([length(stats), 1]);
    for i=1:length(stats)
        thisdate = stats{i}.gps_utc;
        
        try
            time_raw(i,:) = datevec(thisdate, 'yyyy-mm-ddTHH:MM:SS.000Z');
        end
    end
    % convert to elapsed time
    for i=1:length(stats)
        try
            time_elapsed(i) = etime(time_raw(i,:),time_raw(1,:));
        end
    end
    time_elapsed = time_elapsed; % convert to hours
    
    % get values of the xls temperatures at these times
    temp_black = interp1(xls_time, xls_temp_black, time_elapsed,'spline');
    temp_refl = interp1(xls_time, xls_temp_refl, time_elapsed,'spline');
    
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
    
    %[temp_atm temp_reflected temp_external_optics relative_humidity distance_focal]
    
    % convert radiometric counts to temperatures using trefl values
    temp_array = repmat(uint16(0), size(image_array));
    for i=1:length(stats)
        temp_this = calibrated_temperature_simple(...
                double(image_array(:,:,i)), ...
                temp_atm(i), ...
                temp_reflected(i), ...
                temp_external_optics(i), ...
                relative_humidity(i), ...
                0.97, ...
                distance_focal(i) ...
            );
        temp_array(:,:,i) = uint16(temp_this * 100);
    end
    
    % choose region of interest
    f1 = figure;
    imshow(rescale_image_quantile(image_mean,0.05,0.95));
    bw = roipoly;
    pixels_keep = bw>0;

    % calculate stats in this region
    temperature_stats = zeros([num_files 5]);
    for i=1:num_files
        temp_this = temp_array(:,:,i);
        pixels_this = double(temp_this(pixels_keep))/100;
        if (i<10)
            mean(pixels_this)
        end
        
        temperature_stats(i,1) = mean(pixels_this);
        temperature_stats(i,2) = std(pixels_this);
        temperature_stats(i,3) = quantile(pixels_this,0.05);
        temperature_stats(i,4) = quantile(pixels_this,0.5);
        temperature_stats(i,5) = quantile(pixels_this,0.95); 
        
        fprintf('.');
    end
    fprintf('\n')
    
    
    [b,~,~,~,stats] = regress(temp_black, [ones(size(temperature_stats(:,4))) temperature_stats(:,4)]);
    
    Tkelvin_aligned_calibrated = temp_array;
    
    for i=1:num_files
        Tkelvin_aligned_calibrated(:,:,i) = uint16(100*(b(1) + b(2) * double(temp_array(:,:,i))/100));
    end
    
    temp_new = zeros([num_files 1]);
    for i=1:num_files
        temp_this = Tkelvin_aligned_calibrated(:,:,i);
        pixels_this = double(temp_this(pixels_keep))/100;
        temp_new(i) = quantile(pixels_this,0.5);
    end
    
    f3 = figure; 
    plot(temperature_stats(:,4), temp_black,'.g'); hold on;
    plot(temp_new, temp_black,'.r')
    
    % show plots
    f2 = figure;
    plot(time_elapsed, temp_black,'-k'); hold on;
    plot(time_elapsed, temperature_stats(:,4),'-g');
    plot(time_elapsed, temp_new,'.r')
    
    finalstats = [time_raw time_elapsed temp_black temp_atm temp_reflected temp_external_optics relative_humidity emissivity distance_focal]; 
    
    save('calibratedtemperature.mat', 'Tkelvin_aligned_calibrated', 'finalstats','-v7');
end