%x = analyze_image('cbt_2016_06_20_newer.mat','/Users/benjaminblonder/Documents/rmbl/rmbl 2016/thermal ecology/thermal data/cbt june 20th diurnal/combined/','160620_133726-000000-000000-visible.png','out');
function [image_thermal_mean] = analyze_image(file_thermal_mat, folder_visible, file_visible, folder_out)
    scalefactor = 2;

    if (nargin < 3)
        folder_out = 'output';
    end
    
    if ~exist(folder_out, 'dir')
        mkdir(folder_out);
    end
    
    data_thermal = matfile(file_thermal_mat);
    stats = data_thermal.finalstats;
    time_elapsed = stats(:,1);
    num_files = length(time_elapsed);
    
    % initialize storage
    image_thermal_mean = double(data_thermal.Tkelvin_aligned_calibrated(:,:,num_files/3))/100;
    image_thermal_mean = imresize(image_thermal_mean, scalefactor);
    image_thermal_mean = rescale_image_quantile(image_thermal_mean, 0.01, 0.99);
    %image_thermal_mean = adapthisteq(image_thermal_mean, 'NumTiles',[8 8]);
    image_thermal_mean = imsharpen(image_thermal_mean,'Radius',2,'Amount',1.5);
    image_thermal_mean = ind2rgb(floor(255*image_thermal_mean),hot(255));
    fprintf('\n')

    points_thermal = [];
    points_visible = [];
    image_this = imread(fullfile(folder_visible, file_visible));

    done = false;
    doalign = true;
    while (~done)
        if (doalign)
            [image_fused, image_visible_registered, points_thermal, points_visible] = image_align(image_thermal_mean, image_this, points_thermal, points_visible);
            %[image_fused, image_visible_registered, points_thermal, points_visible] = image_align_auto(image_thermal_mean, image_this, points_thermal, points_visible);
        end
        
        [bw finishroi] = chooseroi(image_visible_registered, image_thermal_mean);

        if (strcmp(finishroi, 'No - realign'))
            doalign = true;
        else % if we did get a good ROI
            doalign = false;
            
            bw = imresize(bw, [480 640]);
            pixels_keep = bw>0;

            % calculate stats in this region
            thermal_stats = zeros([num_files 5]);
            for j=1:num_files
                image_this = double(data_thermal.Tkelvin_aligned_calibrated(:,:,j))/100;
                pixels_this = image_this(pixels_keep);
                pixels_this = pixels_this(pixels_this>0);
                thermal_stats(j,1) = mean(pixels_this);
                thermal_stats(j,2) = std(pixels_this);
                thermal_stats(j,3) = quantile(pixels_this,0.05);
                thermal_stats(j,4) = quantile(pixels_this,0.5);
                thermal_stats(j,5) = quantile(pixels_this,0.95);
                fprintf('%.3f\n',j/num_files);
            end
            fprintf('\n')
            % show plot
            f2 = figure;
            plot(time_elapsed, thermal_stats(:,3),'-g'); hold on;
            plot(time_elapsed, thermal_stats(:,4),'-r');
            plot(time_elapsed, thermal_stats(:,5),'-b');

            ans_roi = questdlg('Keep this ROI?','Prompt','yes','no','finished','yes');
            if (strcmp(ans_roi,'yes')==1)
                filename_output = inputdlg('Enter sample name','Input',1,{strrep(strrep(file_visible,'.jpg',''),'.png','')});
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

    

end