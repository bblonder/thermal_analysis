function [] = matlab_play_movie(array_aligned, name, datetimes, temp_lo, temp_hi, obj_dist)
    v = VideoWriter(sprintf('%s.mp4',name),'MPEG-4');
    open(v);
    
    fig = figure('Position', [1, 1, 900, 800]);
    
    for (i=1:(size(array_aligned,3)-1))
        % guess the temperature using default settings
        temp = calibrated_temperature_simple(array_aligned(:,:,i), 293, 293, 293, 0.5, 0.97, obj_dist); % 50 pct RH, 293 K atm, 10 meter distance, 0.97 emissivity
        thisim = double(temp) - 273.15;
        
        datestamp = '';
        try
            dt = datetimes{i};
            datestamp = sprintf('%s %d-%02d-%02d - %02d:%02d:%02d (local)', name, datetimes{i}(1), datetimes{i}(2), datetimes{i}(3), datetimes{i}(4), datetimes{i}(5), datetimes{i}(6));
        end
 
        % scale image
        imagesc(thisim,[temp_lo-273.15,temp_hi-273.15]); 
        axis off;
        % add colorbar and title
        colorbar; colormap('hot');
        title(datestamp);
        % set 1 px = 1 px for output
        truesize(fig);
        
        % grab a frame and write out
        drawnow;
        frame = getframe(fig);
        writeVideo(v,frame);
        fprintf('writing video frame %d\n',i)
    end
    % close the file
    close(v);
    
    % close the figure
    close(fig);
    
end