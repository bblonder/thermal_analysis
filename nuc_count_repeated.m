function [nuc_count, sd_temp_degc] = nuc_count_repeated(g, nuc_sd_min, nuc_count_max)
    nuc_done = 0;
    nuc_count = 0;
    while (~nuc_done)
        executeCommand(g, 'NUCAction');
        pause(2);
        img = snapshot(g);
        imagesc(img); colorbar;

        sd_temp_degc = std(double(img(:))*10/1000-273.15);
        nuc_done = (sd_temp_degc > nuc_sd_min | nuc_count > nuc_count_max);
        nuc_count = nuc_count + 1;
    end
end