function [] = redraw(p, im1, im2)
    bw = poly2mask(p(:,1),p(:,2), size(im2,1), size(im2,2));
    
    J2 = im2;
    if (size(J2,3) > 1)
        J2r = im2(:,:,1);
        J2g = im2(:,:,2);
        J2b = im2(:,:,3);
        
        J2g(bw) = 0;
        J2b(bw) = 0;
        
        J2 = cat(3, J2r, J2g, J2b);
    else
        J2(bw) = 0;
    end
    
    J1 = im1;
    if (size(J1,3) > 1)
        J1r = im1(:,:,1);
        J1g = im1(:,:,2);
        J1b = im1(:,:,3);
        
        J1g(bw) = 0;
        J1b(bw) = 0;
        
        J1 = cat(3, J1r, J1g, J1b);
    else
        J1(bw) = 0;
    end
    
    subaxis(2,2,1,'Spacing', 0.0, 'Padding', 0, 'Margin', 0); imshow(J1); axis tight; axis off;    
    xlim_this = evalin('base', 'xlim_this');
    ylim_this = evalin('base', 'ylim_this');
    set(gca,'xlim',xlim_this,'ylim',ylim_this);
    
    subaxis(2,2,2,'Spacing', 0.0, 'Padding', 0, 'Margin', 0); imshow(J2); axis tight; axis off;        
    xlim_this = evalin('base', 'xlim_this');
    ylim_this = evalin('base', 'ylim_this');
    set(gca,'xlim',xlim_this,'ylim',ylim_this);
    
end