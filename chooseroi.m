function [mask] = chooseroi(im1, im2, name)
    f = figure('Name', name);
    
    warningState = warning('off','Images:initSize:adjustingMag');
    warning(warningState);
    subplot(1,2,1), p1=imshow(im1,'InitialMagnification',100, 'Border','tight');   
    subplot(1,2,2), p2=imshow(im2,'InitialMagnification',100, 'Border','tight');

    
    imp = impoly();
    addNewPositionCallback(imp,@(p) assignin('base','xy',p));
    addNewPositionCallback(imp,@(p) assignin('base','xlim_this',get(gca, 'xlim')));
    addNewPositionCallback(imp,@(p) assignin('base','ylim_this',get(gca, 'ylim')));
    addNewPositionCallback(imp,@(p) redraw(p, im1));

    set(f,'CloseRequestFcn','handle_alignment')
    uiwait;
    xy = evalin('base','xy');
    mask = poly2mask(xy(:,1), xy(:,2), size(im1, 1), size(im1, 2));
end