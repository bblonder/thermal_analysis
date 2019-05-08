% no ground calibration second time
% [Tkelvin_aligned_calibrated, finalstats] = matlab_calibrate_thermal(aa, names, 263, 343, 'east_test.mat');

function [Tkelvin_aligned_calibrated, names, datetimes] = matlab_calibrate_thermal(image_array, names, bound_temp_lo, bound_temp_hi, file_visible, outputname)    
    num_files = size(image_array,3);
    
    datetimes = cell(size(names));
    % calculate datetimes
    for (i=1:length(names))
        dts = split(names(i),'_');
        datetimes{i} = datevec(dts(2),'YYMMDD-hhmmss');
    end
    
    image_mean = zeros([size(image_array,1) size(image_array,2)]);
    for i=1:num_files
        image_mean = image_mean + double(image_array(:,:,i));
        fprintf('%d\n',i);
    end
    image_mean = image_mean / num_files;
    
    % convert radiometric counts to temperatures
    temp_array = repmat(uint16(0), size(image_array));
    for i=1:length(stats)
        fprintf('*');
        ithis = image_array(:,:,i);
        %ithis(ithis==0) = NaN; % remove any extraneous values values
        
        temp_this = calibrated_temperature_simple(...
                double(image_array(:,:,i)), ...
                temp_atm, ...
                temp_reflected, ...
                temp_external_optics, ...
                relative_humidity, ...
                emissivity, ...
                distance_focal ...
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
    
    error('add playmovie');
end