function [] = matlab_redraw(p, im1)
    bw = poly2mask(p(:,1),p(:,2), size(im1,1), size(im1,2));
    
    J1 = im1;
    if (size(J1,3) > 1)
        J1r = im1(:,:,1);
        J1g = im1(:,:,2);
        J1b = im1(:,:,3);
        
        % show in green channel
        J1r(bw) = 0;
        J1b(bw) = 0;
        
        J1 = cat(3, J1r, J1g, J1b);
    else
        J1(bw) = 0;
    end
    
    subaxis(1,2,1,'Spacing', 0.0, 'Padding', 0, 'Margin', 0); imshow(J1); axis tight; axis off;    
    xlim_this = evalin('base', 'xlim_this');
    ylim_this = evalin('base', 'ylim_this');
    set(gca,'xlim',xlim_this,'ylim',ylim_this);
end