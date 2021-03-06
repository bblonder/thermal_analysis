% [array_aligned, name, datetimes]= matlab_align_thermal('east', 1, 1, 1, 0.1, 273+10,273+40, 10, 'out');

% make sure vision toolbox is included and path to
% cvexEstStabilizationTform is included on PATH
function [array_aligned, name, datetimes] = matlab_align_thermal(folder_in_thermal_timeseries, freak_do_stabilization, freak_interval_keyframes, freak_interval_frames, freak_threshold, guess_temp_lo_K, guess_temp_hi_K, guess_obj_dist_m, output_prefix)
    % load in thermal images
    files_thermal_timeseries = dir(fullfile(folder_in_thermal_timeseries, '*_radiometric.mat'));
    % extract good names
    filenames_stripped = strings(length(files_thermal_timeseries),1);
    for i=1:length(files_thermal_timeseries)
        filenames_stripped(i) = strrep(strrep(files_thermal_timeseries(i).name, 'snapshot_',''),'_matrix_radiometric.mat','');
    end
    
    keepfiles = ones([length(files_thermal_timeseries) 1]);
    for i=1:length(files_thermal_timeseries)
        fn = fullfile(folder_in_thermal_timeseries, files_thermal_timeseries(i).name);
        try
            data_current = load(fn);
            % get variable from matrix
            im_current = double(data_current.img_rm);

            zeros = nnz(im_current==0);
            if (zeros > 50)
                fprintf('drop %d %d %s\n', i, zeros, fn);
                keepfiles(i) = 0;
            else
                fprintf(' *%d* %s\n',i, fn);
            end
            fprintf('\n');
        catch
            fprintf('drop %d %d %s\n', i, zeros, fn);
            keepfiles(i) = 0;           
        end
        
    end
    files_thermal_timeseries = files_thermal_timeseries(keepfiles>0);
    filenames_stripped = filenames_stripped(keepfiles>0);
    numfiles_thermal_timeseries = length(files_thermal_timeseries);
    
    % get first frame
    if (freak_do_stabilization==1)
        fileMean = load(fullfile(folder_in_thermal_timeseries, files_thermal_timeseries(1).name));
        movMean = double(fileMean.img_rm);
        % rescale frame
        imgB = movMean;
        imgBp = imgB;
        correctedMean = imgBp;
        Hcumulative = eye(3);
        count_average = 0;

        transform_current = Hcumulative;
    end
    
    indexvals = 1:freak_interval_frames:numfiles_thermal_timeseries;        
    % allocate memory
    array_aligned = repmat(uint16(zeros(1)),[480 640 length(indexvals)]);

    % iterate through each frame
    f = figure;
    for i=1:length(indexvals)
        fn = fullfile(folder_in_thermal_timeseries, files_thermal_timeseries(indexvals(i)).name);
        file_current = load(fn);
        im_current = double(file_current.img_rm);
        
        if (freak_do_stabilization==1)
            try
                if (mod(indexvals(i),freak_interval_keyframes)==0)
                    fprintf('*');
                    % Move old frames
                    imgA = imgB; % z^-1
                    imgAp = imgBp; % z^-1
                    % Read in new frame
                    fileB = load(fn);
                    imgB = double(fileB.img_rm);
                    imgB_untransformed = imgB;

                    movMean = movMean + imgB;

                    % do stabilization transform and warp
                    imgA_scaled = rescale_image_quantile(double(imgA), 0.01,0.99);
                    imgB_scaled = rescale_image_quantile(double(imgB), 0.01,0.99);
                    % consider additional edge-finding or contrast
                    % enhancement code here...
                    
                    %C = imfuse(imgA_scaled, imgB_scaled);
                    %imshow(C);
                    
                    H = cvexEstStabilizationTform(imgA_scaled, imgB_scaled, freak_threshold);
                    HsRt = cvexTformToSRT(H);
                    Hcumulative = HsRt * Hcumulative;
                    imgBp = imwarp(imgB,affine2d(Hcumulative),'OutputView',imref2d(size(imgB)));
                    % add new value to mean
                    correctedMean = correctedMean + imgBp;

                    transform_current = Hcumulative;

                    count_average = count_average + 1;
                end
            catch e
                fprintf(e.message);
                fprintf('\n');
            end

            % transform the raw image too
            im_current_warped = imwarp(im_current,affine2d(transform_current),'OutputView',imref2d(size(im_current)));         
        else % if no stabilization attempted
            im_current_warped = im_current;
        end
        
        % show the transform
        imshow(rescale_image_quantile(im_current_warped, 0.05, 0.95));
        % reconvert back to uint16
        array_aligned(:,:,i) = uint16(im_current_warped);
        
        fprintf('%d ', indexvals(i))

    end
    
    % close the window
    close(f);
    
    % calculate the mean stats
    correctedMean = correctedMean/(count_average);
    movMean = movMean/(count_average);
    
    % convert names to dates
    for (i=1:length(filenames_stripped))
        dts = split(filenames_stripped(i),'_');
        datetimes{i} = datevec(dts(2),'yymmdd-HHMMSS');
    end
    % keep a name 
    name = dts(1);

    fprintf('\n')
    
    % save the raw array
    outputname = sprintf("%s_%s.mat",output_prefix, name);
    save(outputname, 'array_aligned', 'name', 'datetimes', '-v7.3'); % this allows for partial loading
     
    % write a guessed temperature movie
    matlab_play_movie(array_aligned, name, datetimes, guess_temp_lo_K, guess_temp_hi_K, guess_obj_dist_m, outputname)
end



