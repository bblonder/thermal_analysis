% [~, ~, array_aligned, name, datetimes]= matlab_align_thermal('~/Desktop/thermal excerpt panama/east/', 2, 1, 0.5, 273+10,273+40, 10, 'out');
function [correctedMean movMean array_aligned, name, datetimes] = matlab_align_thermal(folder_in_thermal_timeseries, interval_keyframes, interval_frames, freak_threshold, guess_temp_lo_K, guess_temp_hi_K, guess_obj_dist_m, output_prefix)
    % load in thermal images
    files_thermal_timeseries = dir([folder_in_thermal_timeseries '*_radiometric.mat']);
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
    fileMean = load(fullfile(folder_in_thermal_timeseries, files_thermal_timeseries(1).name));
    movMean = double(fileMean.img_rm);
    % rescale frame
    movMean = imgaussfilt(rescale_image_quantile(movMean, 0.01, 0.99),2);
    imgB = movMean;
    imgBp = imgB;
    correctedMean = imgBp;
    Hcumulative = eye(3);
    count_average = 0;
    
    transform_current = Hcumulative;
    
    indexvals = 1:interval_frames:numfiles_thermal_timeseries;        
    % allocate memory
    array_aligned = repmat(uint16(zeros(1)),[480 640 length(indexvals)]);

    % iterate through each frame
    f = figure;
    for i=1:length(indexvals)
        fn = fullfile(folder_in_thermal_timeseries, files_thermal_timeseries(indexvals(i)).name);
        
        try
            if (mod(indexvals(i),interval_keyframes)==1)
                fprintf('*');
                % Move old frames
                imgA = imgB; % z^-1
                imgAp = imgBp; % z^-1
                % Read in new frame
                imgB = double(readNPY(fn));
                imgB_untransformed = imgB;
                imgB = imgaussfilt(rescale_image_quantile(imgB, 0.01, 0.99),2);
                movMean = movMean + imgB;

                % do stabilization transform and warp
                H = cvexEstStabilizationTform(imgA,imgB,freak_threshold);
                HsRt = cvexTformToSRT(H);
                Hcumulative = HsRt * Hcumulative;
                imgBp = imwarp(imgB,affine2d(Hcumulative),'OutputView',imref2d(size(imgB)));
                % add new value to mean
                correctedMean = correctedMean + imgBp;
                
                transform_current = Hcumulative;
                
                count_average = count_average + 1;
            end
        end
        
        file_current = load(fn);
        im_current = double(file_current.img_rm);

        % transform the raw image too
        im_current_warped = imwarp(im_current,affine2d(transform_current),'OutputView',imref2d(size(im_current)));         
        
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



