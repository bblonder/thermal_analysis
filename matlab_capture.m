nuc_count_last = 0;
nuc_temp_sd_last = 0;
nuc_count_max = 50; % max number of tries to fix NUC
nuc_sd_min = 0.5; % minimum temperature s.d. in degC to allow NUC to pass

options = {'Camera setup', 'Camera close','AutoFocus','FocusManual','NUC','Snapshots'};

done = 0;
while ~done
    action = listdlg('PromptString','Choose an action','SelectionMode','single','ListString', options, 'ListSize',[200 200],'InitialValue',3);
    if length(action)==0
        done = 1;
    else

        switch(action)
            case 1
                try
                    g = gigecam(1);
                    for index=1:10
                        % do some cycling to force the mode
                        g.IRFormat='Radiometric';
                        g.IRFormat='TemperatureLinear10mK'; %'Radiometric'
                        w = snapshot(g);
                        pause(0.5);
                        fprintf('.');
                    end
                    
                    g.TSensSelector='Lens';
                    g.NoiseReduction='On';
                    g.AutoFocusMethod='Fine';
                    g.NUCMode = 'Off';

                    executeCommand(g, 'AutoFocus');
                    pause(1);

                    fprintf('Focus distance: %f\n', g.FocusDistance);

                    [img, ts] = snapshot(g);
                    imagesc(double(img)*10/1000-273.15); colorbar;
                catch
                    warning('could not open camera');
                end
            case 2
                try
                    clear g;
                    done = 1;
                catch
                    warning('could not close camera');
                end
            case 3
                try
                    executeCommand(g, 'AutoFocus');
                    pause(3);

                    fprintf('Focus distance: %f\n', g.FocusDistance);

                    [img, ts] = snapshot(g);
                    imagesc(double(img)*10/1000-273.15); colorbar;
                catch
                    warning('could not focus');
                end
            case 4
                try
                    prompt = {'Focus distance (m approx)'};
                    dlg_title = 'Input';
                    num_lines = 1;
                    defaultans = {sprintf('%.4f',g.FocusDistance)};
                    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
                    focus_dist_new = str2num(answer{1});
                    g.FocusDistance = focus_dist_new;
                    fprintf('Focus distance: %f\n', g.FocusDistance);
                    pause(0.1);
                    [img, ts] = snapshot(g);
                    imagesc(double(img)*10/1000-273.15); colorbar;

                end
            case 5
                try
                    [nuc_count, sd_temp_degc] = nuc_count_repeated(g, nuc_sd_min, nuc_count_max);

                    sd_temp_degc

                    nuc_count_last = nuc_count;
                    nuc_temp_sd_last = sd_temp_degc;
                end
            case 6
                try
                    prompt = {'Frame interval (sec):','Number of frames:','NUC Interval (# frames)','File prefix:'};
                    dlg_title = 'Input (set numframes=0 for continuous logging)';
                    num_lines = 1;
                    defaultans = {'5','0','0','test'};
                    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
                    frame_interval = str2num(answer{1}); 
                    frame_count = str2num(answer{2});
                    nuc_frame_interval = str2num(answer{3});
                    file_prefix = answer{4};

                    % set home directory as path
                    selpath = uigetdir('~','Choose a directory');

                    all_frames_done = 0;
                    i = 0;
                    while (~all_frames_done)
                        g.IRFormat='TemperatureLinear10mK';
                        [img, ts] = snapshot(g);

                        imagesc(double(img)*10/1000-273.15); colorbar;

                        time_str = datestr(now,'yymmdd-HHMMSS');

                        save(fullfile(selpath,sprintf('snapshot_%s_%s_matrix_tlinear.mat',file_prefix, time_str)),'img');
                        %imwrite(255*rescale_image_quantile(double(img), 0.0, 1.0),parula(255), fullfile(selpath,sprintf('snapshot_%s_%s_image_tlinear.png',file_prefix, time_str)));
                        imwrite(255*rescale_image_range(double(img)*10/1000-273.15, 10, 40),parula(255), fullfile(selpath,sprintf('snapshot_%s_%s_image_tlinear.png',file_prefix, time_str)));
                        %imwrite(img,fullfile(selpath, sprintf('snapshot_%s_%s_image_tlinear.tif',file_prefix, time_str)));

                        % grab radiometric frames for later calibration
                        % purposes
                        g.IRFormat='Radiometric';
                        pause(1);
                        for j=1:10 % burn some frames to clear the buffer
                            [img_rm, ts] = snapshot(g);
                        end
                        save(fullfile(selpath,sprintf('snapshot_%s_%s_matrix_radiometric.mat',file_prefix, time_str)),'img_rm');
                        imwrite(255*rescale_image_quantile(double(img_rm), 0.0, 1.0),parula(255), fullfile(selpath,sprintf('snapshot_%s_%s_image_radiometric.png',file_prefix, time_str)));
                        %imwrite(img_rm,fullfile(selpath,sprintf('snapshot_%s_%s_image_radiometric.tif',file_prefix, time_str)));

                        % return to tlinear mode
                        g.IRFormat='TemperatureLinear10mK';
                        pause(frame_interval);

                        % on-screen diagnostic
                        fprintf('%d %s\n', i, time_str);

                        % write a log
                        fileID = fopen(fullfile(selpath, sprintf('snapshot_%s_%s_log.txt',file_prefix, time_str)),'w');
                        fprintf(fileID,'nuc_count_last\t%d\n',nuc_count_last);
                        fprintf(fileID,'nuc_temp_sd_last\t%.4f\n',nuc_temp_sd_last);
                        fprintf(fileID,'TSens\t%.4f\n',g.TSens);
                        fclose(fileID);

                        % do a NUC if desired
                        if (nuc_frame_interval > 0)
                            if (mod(i, nuc_frame_interval) == 0)
                                [nuc_count, sd_temp_degc] = nuc_count_repeated(g, nuc_sd_min, nuc_count_max);

                                nuc_count_last = nuc_count;
                                nuc_temp_sd_last = sd_temp_degc;
                            end
                        end
                        % iterate
                        i=i+1;
                        if (frame_count > 0)
                            all_frames_done = (i>=frame_count);
                        else
                            all_frames_done = 0;
                        end
                    end

                catch
                    warning('could not capture images');
                end
        end
    end
end