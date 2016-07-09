%im_thermal = imread('/Users/benjaminblonder/Desktop/thermal data/thermal_control_160617_180132/160617_180132-000000-000050-infrared.png');
%im_visible = imread('/Users/benjaminblonder/Desktop/thermal data/visible test_160617_180132/vistest 3.jpg');
%image_align(im_thermal, im_visible)

function [im_fused, im_visible_registered, points_thermal, points_visible, transform] = image_align(im_thermal, im_visible, points_thermal, points_visible)
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
            transform = fitgeotrans(points_visible, points_thermal, 'affine');

            Rthermal = imref2d(size(im_thermal));
            im_visible_registered = imwarp(im_visible,transform,'OutputView',Rthermal);

            im_thermal_flipped = imcomplement(im_thermal);
            im_fused = imfuse(im_thermal_flipped, im_visible_registered(:,:,2),'ColorChannels',[1 0 2]);
            f = figure;
            imshow(im_fused);
          
            
        end
        
        ans_done = MFquestdlg([0.5 0.5], 'Keep this alignment?','Prompt','yes','no','yes');
        if (strcmp(ans_done,'yes')==1)        
            done = true;
        end
        close(f);
    end
end