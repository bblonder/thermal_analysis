function [image_thermal_mean] = analyze_all(file_thermal_mat, folder_in_visible, folder_out)
    scalefactor = 2;

    if (nargin < 3)
        folder_out = 'output';
    end
    
    if ~exist(folder_out, 'dir')
        mkdir(folder_out);
    end
    
    data_thermal = load(file_thermal_mat);
    Tkelvin = data_thermal.Tkelvin_aligned_calibrated;
    stats = data_thermal.finalstats;
    time_elapsed = stats(:,1);
    num_files = length(time_elapsed);
    
    % initialize storage
    image_thermal_mean = zeros([480,640]);
    for i=1:num_files
        % load thermal image
        image_thermal_mean = Tkelvin(:,:,i) + image_thermal_mean;
        fprintf('.');
    end
    image_thermal_mean = image_thermal_mean / size(Tkelvin,3);
    image_thermal_mean = imresize(image_thermal_mean, scalefactor);
    image_thermal_mean = rescale_image_quantile(image_thermal_mean, 0.01, 0.99);
    image_thermal_mean(isnan(image_thermal_mean(:))) = 0;
    image_thermal_mean = adapthisteq(image_thermal_mean, 'NumTiles',[8 8]);
    image_thermal_mean = imsharpen(image_thermal_mean,'Radius',2,'Amount',1.5);
    image_thermal_mean = ind2rgb(floor(255*image_thermal_mean),hot(255));
    fprintf('\n')

    
    % loop over visible images
    files_visible = dir([folder_in_visible '*jpg']);
    points_thermal = [];
    points_visible = [];
    for i=1:length(files_visible)
        image_this = imread(fullfile(folder_in_visible,files_visible(i).name));
        
        [image_fused, image_visible_registered, points_thermal, points_visible] = image_align(image_thermal_mean, image_this, points_thermal, points_visible);


        done = false;
        while (~done)
            %f1 = figure('Name', files_visible(i).name);
            %subplot(1,2,1),subimage(image_visible_registered);
            %subplot(1,2,2),subimage(image_thermal_mean);

            % choose region of interest
            %bw = roipoly;
            
            bw = chooseroi(image_visible_registered, image_thermal_mean, files_visible(i).name);

            bw = imresize(bw, [480 640]);
            pixels_keep = bw>0;
            
            % calculate stats in this region
            thermal_stats = zeros([num_files 5]);
            for j=1:num_files
                image_this = Tkelvin(:,:,j);
                pixels_this = image_this(pixels_keep);
                pixels_this = pixels_this(~isnan(pixels_this));
                %imshow(image_this .* bw, [27300, 31300]);
                thermal_stats(j,1) = mean(pixels_this);
                thermal_stats(j,2) = std(pixels_this);
                thermal_stats(j,3) = quantile(pixels_this,0.05);
                thermal_stats(j,4) = quantile(pixels_this,0.5);
                thermal_stats(j,5) = quantile(pixels_this,0.95);
                fprintf('.');
            end
            fprintf('\n')
            % show plot
            f2 = figure;
            plot(time_elapsed, thermal_stats(:,3),'-g'); hold on;
            plot(time_elapsed, thermal_stats(:,4),'-r');
            plot(time_elapsed, thermal_stats(:,5),'-b');

            ans_roi = questdlg('Keep this ROI?','Prompt','yes','no','finished','yes');
            if (strcmp(ans_roi,'yes')==1)
                filename_output = inputdlg('Enter sample name','Input',1,{sprintf('%s',strrep(files_visible(i).name,'.jpg',''))});
                filename_output = filename_output{1};

                if (~isempty(filename_output))
                    table_out = table;
                    table_out.file = repmat(file_thermal_mat, [num_files 1]);
                    table_out.thermal_mean = thermal_stats(:,1);
                    table_out.thermal_sd = thermal_stats(:,2);
                    table_out.thermal_q05 = thermal_stats(:,3);
                    table_out.thermal_q50 = thermal_stats(:,4);
                    table_out.thermal_q95 = thermal_stats(:,5);

                    table_out = horzcat(table_out, array2table(stats));

                    filename_output_final = sprintf('%s/%s.csv',folder_out,filename_output);
                    writetable(table_out, filename_output_final)
                    fprintf('wrote file %s\n', filename_output_final);

                    imwrite(bw, sprintf('%s/%s-mask.png',folder_out,filename_output));
                    imwrite(image_visible_registered, sprintf('%s/%s-visible-registered.jpg',folder_out,filename_output));
                    done = true;
                end
            elseif (strcmp(ans_roi,'finished')==1)
                done = true;
            end

            close(f2);
        end
    end

    

    
    % loop over each image, after alignment
    

end