%im_thermal = imread('/Users/benjaminblonder/Desktop/thermal data/thermal_control_160617_180132/160617_180132-000000-000050-infrared.png');
%im_visible = imread('/Users/benjaminblonder/Desktop/thermal data/visible test_160617_180132/vistest 3.jpg');
%image_align(im_thermal, im_visible)

function [im_fused, im_visible_registered, points_thermal, points_visible] = image_align(im_thermal, im_visible, points_thermal, points_visible)
    if nargin <= 2
        points_thermal = [];
        points_visible = [];
    end

    done = false;
    

    while (~done)
            
        % try to do alignment
        if (isempty(points_thermal))
            [points_thermal, points_visible] = cpselect(im_thermal, im_visible, 'Wait',true);
        else
            [points_thermal, points_visible] = cpselect(im_thermal, im_visible, points_thermal, points_visible, 'Wait',true);
        end
        
        try
            transform = fitgeotrans(points_visible, points_thermal, 'projective');

            Rthermal = imref2d(size(im_thermal));
            im_visible_registered = imwarp(im_visible,transform,'OutputView',Rthermal);

            
            %im_visible_registered_bw = adapthisteq(rgb2gray(im_visible_registered));
            im_fused = imfuse(im_thermal, im_visible_registered,'blend');
            f = figure;
            imshow(im_fused);
          
            
        end
        
        ans_done = MFquestdlg([0.5 0.5], 'Keep this alignment?','Prompt','yes','no','yes');
        if (strcmp(ans_done,'yes')==1)        
            done = true;
            close(f);
        end
    end
end