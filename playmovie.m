function [] = playmovie(temp, finalstats, stats, gmtoffset,filename)
    ns = min(size(temp,3),100);
    temp_ss = temp(:,:,randsample(size(temp,3),ns));

    quantiles = quantile(double(temp_ss(:))/100 - 273.15,[0.01,0.99]);
    
    v = VideoWriter(sprintf('%s.mp4',filename),'MPEG-4');
    open(v);
    
    fig = figure('Position', [1, 1, 900, 800]);
    
    for (i=1:(size(temp,3)-1))
        thisim = double(temp(:,:,i))/100 - 273.15;
        
        datestamp = '';
        try
            datestamp = sprintf('%d/%02d/%02d - %02d:%02d:%02d (local) - range [%.2f %.2f] - %.2f degC Tair, %.0f lux', finalstats.time_raw(i,1), finalstats.time_raw(i,2), finalstats.time_raw(i,3), gmtoffset + finalstats.time_raw(i,4), finalstats.time_raw(i,5), finalstats.time_raw(i,6), quantiles(1), quantiles(2), stats{i}.wx_temp_air_c, stats{i}.wx_vis_lux );
        end
        
        thisim = imsharpen(thisim);

        imagesc(thisim,quantiles); 
        axis off;
        colorbar; colormap('parula');
        title(datestamp);
        truesize(fig);
        
        drawnow;

        frame = getframe(fig);
        writeVideo(v,frame);
    end
    
    close(v);
end