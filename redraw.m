function [] = redraw(p, im)
    bw = poly2mask(p(:,1),p(:,2), size(im,1), size(im,2));
    
    J = im;
    if (size(J,3) > 1)
        Jr = im(:,:,1);
        Jg = im(:,:,2);
        Jb = im(:,:,3);
        
        Jg(bw) = 0;
        Jb(bw) = 0;
        
        J = cat(3, Jr, Jg, Jb);
    else
        J(bw) = 0;
    end
    
    subplot(1,2,1); imshow(J); 
    
    xlim_this = evalin('base', 'xlim_this');
    ylim_this = evalin('base', 'ylim_this');
    set(gca,'xlim',xlim_this,'ylim',ylim_this)
end