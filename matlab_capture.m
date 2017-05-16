n_images = 30;
options = {'Camera setup', 'Camera close','Focus','Snapshots'};

done = 0;
while ~done
    action = listdlg('PromptString','Choose an action','SelectionMode','single','ListString', options, 'ListSize',[200 200]);
    switch(action)
        case 1
            try
                g = gigecam(1);
                g.IRFormat='TemperatureLinear10mK'; %'Radiometric'
                g.TSensSelector='Shutter';
                g.NoiseReduction='On';
                g.AutoFocusMethod='Fine';
                g.NUCMode = 'Automatic';
                
                executeCommand(g, 'NUCAction');
                executeCommand(g, 'AutoFocus');
                pause(3);
                
                fprintf('Focus distance: %f\n', g.FocusDistance);
                
                [img, ts] = snapshot(g);
                imshow(rescale_image_quantile(double(img),0.01,0.99));
            catch
                warning('could not open camera');
            end
        case 2
            try
                clear g;
            catch
                warning('could not close camera');
            end
        case 3
            try
                executeCommand(g, 'NUCAction');
                executeCommand(g, 'AutoFocus');
                pause(3);
                
                fprintf('Focus distance: %f\n', g.FocusDistance);
                
                [img, ts] = snapshot(g);
                f = figure;
                imshow(rescale_image_quantile(double(img),0.01,0.99));
            catch
                warning('could not focus');
            end
        case 4
            try
                prompt = {'Frame interval (sec):','Number of frames:','File prefix:'};
                dlg_title = 'Input';
                num_lines = 1;
                defaultans = {'5','1','test'};
                answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
                frame_interval = str2num(answer{1}); 
                frame_count = str2num(answer{2});
                file_prefix = answer{3};
                
                f = figure;
                for i=1:frame_count
                    [img, ts] = snapshot(g);
                    
                    imagesc(img);
                    
                    time_str = datestr(now,'yymmdd-HHMMSS');
                    
                    save(sprintf('snapshot_%s_%s_matrix.mat',file_prefix, time_str),'img')
                    imwrite(rescale_image_quantile(double(img), 0.01, 0.99),parula(255), sprintf('snapshot_%s_%s_image.png',file_prefix, time_str));
                    imwrite(img,sprintf('snapshot_%s_%s_image.tif',file_prefix, time_str));
                    
                    pause(frame_interval);
                    
                    fprintf('%d %s\n', i, time_str);
                end
                

            catch
                warning('could not capture images');
            end
    end
    
    try
        %close(f);
    end
end