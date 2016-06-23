%im_thermal = imread('/Users/benjaminblonder/Desktop/thermal data/thermal_control_160617_180132/160617_180132-000000-000050-infrared.png');
%im_visible = imread('/Users/benjaminblonder/Desktop/thermal data/visible test_160617_180132/vistest 3.jpg');
%image_align(im_thermal, im_visible)

function [im_fused, im_visible_registered, points_thermal, points_visible] = image_align(im_thermal, im_visible)
    done = false;
    
    while (~done)
        [points_thermal, points_visible] = cpselect(im_thermal, im_visible,'Wait',true);
        transform = fitgeotrans(points_visible, points_thermal, 'projective');

        Rthermal = imref2d(size(im_thermal));
        im_visible_registered = imwarp(im_visible,transform,'OutputView',Rthermal);
        
        f = figure;
        im_fused = imfuse(im_thermal, im_visible_registered,'blend');
        imshow(im_fused);
        
        ans_done = questdlg('Keep this alignment?','Prompt','yes','no','yes');
        if (strcmp(ans_done,'yes')==1)        
            done = true;
        end

        close(f)
    end
end