% matlab_analyze_image('out_east.mat', 'results');
function [] = matlab_analyze_image(file_thermal_mat, folder_out)
    scalefactor = 2;

    if (nargin < 2)
        folder_out = 'output';
    end
    if (nargin < 3)
    end
    
    if ~exist(folder_out, 'dir')
        mkdir(folder_out);
    end
    
    data_thermal = matfile(file_thermal_mat); % load slice-by-slice
    num_files = size(data_thermal.array_aligned, 3);
    
    % create datetimes for plotting
    dt = datetime(cell2mat(data_thermal.datetimes'));
    
    % preprocess exemplar thermal image - pick the 1st frame to work with
    image_thermal_representative = double(data_thermal.array_aligned(:,:,1));
    image_thermal_representative = imresize(image_thermal_representative, scalefactor);
    image_thermal_representative = rescale_image_quantile(image_thermal_representative, 0.01, 0.99);
    image_thermal_representative = imsharpen(image_thermal_representative,'Radius',2,'Amount',1.5);
    image_thermal_representative = ind2rgb(floor(255*image_thermal_representative),hot(255));
    fprintf('\n')

    points_thermal = [];
    points_visible = [];

    done = false;
    while (~done)
        doanotherroi = true;
        
        while (doanotherroi==true)
            warning('choosing the thermal image as the visible');
            image_visible = image_thermal_representative; % hack - change this soon
            
            [bw, finishroi] = matlab_choose_roi(image_visible, image_thermal_representative);

            if (strcmp(finishroi, 'No - realign'))
                doalign = true;
            else % if we did get a good ROI
                doalign = false;
                
                question_answers = inputdlg({'Sample name','Tair (K)', 'Relative humidity (frac)','Emissivity (dimensionless)', 'Object distance (m)'},'Input',1,{'','293','0.5','0.97','10'});
                filename_output = question_answers{1};
                t_air = str2num(question_answers{2});
                rel_hum = str2num(question_answers{3});
                emissivity = str2num(question_answers{4});
                obj_dist = str2num(question_answers{5});

                % downscale image
                bw = imresize(bw, [480 640]);
                pixels_keep = bw>0;

                % calculate stats in this region
                thermal_stats = zeros([num_files 5]);
                for j=1:num_files
                    % calibrate the thermal data to temperatures
                    temp = calibrated_temperature_simple(data_thermal.array_aligned(:,:,j), t_air, 293, 293, rel_hum, emissivity, obj_dist); % 50 pct RH, 293 K atm, 10 meter distance, 0.97 emissivity

                    % mask the thermal data to the ROI
                    pixels_this = temp(pixels_keep);
                    pixels_this = pixels_this(pixels_this>0); % remove any stray zero-temperature pixels
                    
                    % extract summary stats
                    thermal_stats(j,1) = mean(pixels_this);
                    thermal_stats(j,2) = std(pixels_this);
                    thermal_stats(j,3) = quantile(pixels_this,0.05);
                    thermal_stats(j,4) = quantile(pixels_this,0.5);
                    thermal_stats(j,5) = quantile(pixels_this,0.95);
                    fprintf('%.4f\n',j/num_files);
                end
                fprintf('\n')
                % show plot
                f2 = figure;
                plot(dt, thermal_stats(:,3),'-k'); hold on;
                plot(dt, thermal_stats(:,4),'-r');
                plot(dt, thermal_stats(:,5),'-k');
                xlabel('Time (seconds)');
                ylabel('Temperature');

                ans_roi = MFquestdlg([0.5 0.5], 'Keep this ROI?','Prompt','yes','no','finished','yes');
                if (strcmp(ans_roi,'yes')==1)
                    if (~isempty(filename_output))
                        table_out = table;
                        table_out.thermal_mean = thermal_stats(:,1);
                        table_out.thermal_sd = thermal_stats(:,2);
                        table_out.thermal_q05 = thermal_stats(:,3);
                        table_out.thermal_q50 = thermal_stats(:,4);
                        table_out.thermal_q95 = thermal_stats(:,5);
                        table_out.t_air = repmat(t_air,size(table_out.thermal_mean));
                        table_out.rel_hum = repmat(rel_hum,size(table_out.thermal_mean));
                        table_out.emissivity = repmat(emissivity,size(table_out.thermal_mean));
                        table_out.obj_dist = repmat(obj_dist,size(table_out.thermal_mean));

                        % concatenate in all of the datetime information
                        table_out = horzcat(...
                            array2table(cellstr(repmat(data_thermal.name, size(data_thermal.datetimes'))),'VariableNames',{'FileName'}), ...
                            array2table(cellstr(repmat(filename_output, size(data_thermal.datetimes'))),'VariableNames',{'SampleName'}), ...
                            array2table(cell2mat(data_thermal.datetimes'),'VariableNames',{'Y','M','D','h','m','s'}), ...
                            table_out);

                        filename_output_final = sprintf('%s/%s.csv',folder_out,filename_output);
                        writetable(table_out, filename_output_final)
                        imwrite(bw, sprintf('%s/%s-mask.png',folder_out,filename_output));
                        fprintf('wrote file and image %s\n', filename_output_final);
                        
                        done = true;
                    end
                elseif (strcmp(ans_roi,'finished')==1)
                    done = true;
                end

                close(f2);
            end
            
            ans_roi = questdlg('Do another ROI in this aligned image?','Query','Yes','No','Yes');
            doanotherroi = strcmp(ans_roi, 'Yes');
        end
    end
    
    % close all figures
    close all;
end