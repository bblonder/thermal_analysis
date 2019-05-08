% [array_aligned, name, datetimes] = matlab_align_thermal('east', 273+10,273+40, 10);
function [array_aligned, name, datetimes] = matlab_align_thermal(folder_in_thermal_timeseries, guess_temp_lo_K, guess_temp_hi_K, guess_obj_dist_m, output_prefix)
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
    
    % convert names to dates
    for (i=1:length(filenames_stripped))
        dts = split(filenames_stripped(i),'_');
        datetimes{i} = datevec(dts(2),'yymmdd-HHMMSS');
    end
    % keep a name 
    name = dts(1);

    % make temporary directories
    td_in = 'temp_in';
    td_out = 'temp_out';
    if ~exist(td_in)
        mkdir(td_in);
    end
    if ~exist(td_out)
        mkdir(td_out);
    end

    for i=1:numfiles_thermal_timeseries
        fn = fullfile(folder_in_thermal_timeseries, files_thermal_timeseries(i).name);
        file_current = load(fn);
        im_current = file_current.img_rm;
        
        imwrite(im_current(:,:,[1 1 1]), fullfile(td_in, sprintf('%d.tiff',i)));
        fprintf('tempfile writing frame %d\n', i);
    end
    
    % run stabilizer
    stabilize(td_in, td_out, 'tiff', numfiles_thermal_timeseries, 1);

    % allocate memory
    array_aligned = repmat(uint16(zeros(1)),[480 640 numfiles_thermal_timeseries]);
    % put all the temp files back together
    for i=1:numfiles_thermal_timeseries
        im_stabilized = imread(fullfile(td_out, sprintf('%d.tiff',i)));
        array_aligned(:,:,i) = im_stabilized(:,:,1); % pick any channel
    end
    
    % save the raw array
    outputname = sprintf("%s.mat", name);
    save(outputname, 'array_aligned', 'name', 'datetimes', '-v7.3'); % this allows for partial loading
     
    % write a guessed temperature movie
    matlab_play_movie(array_aligned, name, datetimes, guess_temp_lo_K, guess_temp_hi_K, guess_obj_dist_m);
    
    % remove all figure windows
    close all;
    
    % remove the temporary directories
    rmdir(td_in,'s');
    rmdir(td_out,'s');
end



