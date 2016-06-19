% analyze_folder('/Users/benjaminblonder/Desktop/thermal data/thermal_control_160617_180132/', '/Users/benjaminblonder/Desktop/thermal data/visible test_160617_180132/')

function [] = analyze_folder(folder_in_thermal_timeseries, folder_in_visible, folder_out, trim)
    if (nargin < 4)
        trim = 5;
    end
    if (nargin < 3)
        folder_out = 'output';
    end
    
    if ~exist(folder_out, 'dir')
        mkdir(folder_out);
    end

    addpath('npy-matlab-master');

    % load in thermal images
    files_thermal_timeseries_npy = dir([folder_in_thermal_timeseries '*.npy']);
    id_start = trim;
    id_stop = length(files_thermal_timeseries_npy)-trim;
    files_thermal_timeseries_npy = files_thermal_timeseries_npy(id_start:id_stop);
    numfiles_thermal_timeseries = length(files_thermal_timeseries_npy);

    % initialize storage
    image_array = zeros(480,640,numfiles_thermal_timeseries);
    stats = cell([numfiles_thermal_timeseries 1]);
    image_sum = zeros(480,640);
    for i=1:numfiles_thermal_timeseries
        % load thermal image
        fn = fullfile(folder_in_thermal_timeseries, files_thermal_timeseries_npy(i).name);
        image_array(:,:,i) = readNPY(fn);
        image_sum = image_sum + image_array(:,:,i);

        % save stats
        fn_stats = strrep(fn,'infrared-data.npy', 'stats.csv');

        stats{i} = readtable(fn_stats);
        stats{i}.gps_time = {stats{i}.gps_time};
        if (mod(floor((i/numfiles_thermal_timeseries)*100),10)==0) 
            fprintf('+');
        end
    end
    fprintf('\n')
    image_thermal_mean = image_sum / numfiles_thermal_timeseries;
    image_thermal_mean = (image_thermal_mean - quantile(image_thermal_mean(:),0.01)) ./ (quantile(image_thermal_mean(:),0.99) - quantile(image_thermal_mean(:),0.01));

    % combine stats
    stats_final = table;
    for i=1:length(stats)
       disp(files_thermal_timeseries_npy(i).name);
       stats_final = vertcat(stats_final, stats{i}); 
    end    
    
    % find mean visible image
    files_visible = dir([folder_in_visible '*jpg']);
    image_visible_sum = [];
    for i=1:length(files_visible)
        image_this = double(imread(fullfile(folder_in_visible,files_visible(i).name)));
        if (i==1)
            image_visible_sum = image_this;
        else
            image_visible_sum = image_visible_sum + image_this;
        end
    end
    image_visible_mean = uint8(image_visible_sum / length(files_visible));
    
    [image_fused, image_visible_registered, points_thermal, points_visible] = image_align(image_thermal_mean, image_visible_mean);
    

    
    % loop over each image, after alignment
    
    done = false;
    while (~done)
        ans_do_one = questdlg('Do ROI?','Prompt','yes','no','yes');
        if (strcmp(ans_do_one, 'yes')==1)
            f1 = figure;
            imshow(image_fused);

            % choose region of interest
            bw = roipoly;
            pixels_keep = bw>0;

            % calculate stats in this region
            stats = zeros([numfiles_thermal_timeseries 5]);
            for i=1:numfiles_thermal_timeseries
                image_this = image_array(:,:,i);
                pixels_this = image_this(pixels_keep);
                %imshow(image_this .* bw, [27300, 31300]);
                stats(i,1) = mean(pixels_this);
                stats(i,2) = std(pixels_this);
                stats(i,3) = quantile(pixels_this,0.05);
                stats(i,4) = quantile(pixels_this,0.5);
                stats(i,5) = quantile(pixels_this,0.95);
                if (mod(floor((i/numfiles_thermal_timeseries)*100),10)==0) 
                    fprintf('.');
                end 
            end
            fprintf('\n')
            % show plot
            f2 = figure;
            plot(1:numfiles_thermal_timeseries, stats(:,3),'-g'); hold on;
            plot(1:numfiles_thermal_timeseries, stats(:,4),'-r');
            plot(1:numfiles_thermal_timeseries, stats(:,5),'-b');

            ans_roi = questdlg('Keep this ROI?','Prompt','yes','no','finished','yes');
            if (strcmp(ans_roi,'yes')==1)
                filename_output = inputdlg('Enter sample name','Input',1,{''});
                filename_output = filename_output{1};

                if (~isempty(filename_output))
                    table_out = table;
                    table_out.folder = repmat(folder_in_thermal_timeseries, [numfiles_thermal_timeseries 1]);
                    table_out.file = {files_thermal_timeseries_npy.name}';
                    table_out.thermal_mean = stats(:,1);
                    table_out.thermal_sd = stats(:,2);
                    table_out.thermal_q05 = stats(:,3);
                    table_out.thermal_q50 = stats(:,4);
                    table_out.thermal_q95 = stats(:,5);

                    table_out = horzcat(table_out, stats_final);

                    filename_output_final = sprintf('%s/%s.csv',folder_out,filename_output);
                    writetable(table_out, filename_output_final)
                    disp(sprintf('wrote file %s', filename_output_final));
                    
                    imwrite(bw, sprintf('%s/%s-mask.png',folder_out,filename_output));
                end
            elseif (strcmp(ans_roi,'finished')==1)
                done = true;
            end
            
            close(f2);
            close(f1);
        else
            done = true;
        end
    end
end