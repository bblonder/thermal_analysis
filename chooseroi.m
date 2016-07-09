function [mask, finishroi] = chooseroi(im1, im2, im3)
    done = false;
    while (~done)
        f = figure;
        warningState = warning('off','Images:initSize:adjustingMag');
        warning(warningState);

        subaxis(2,2,1,'Spacing', 0.0, 'Padding', 0, 'Margin', 0);
        p0=imshow(im1);
        axis tight; axis off;
        subaxis(2,2,2,'Spacing', 0.0, 'Padding', 0, 'Margin', 0); 
        p1=imshow(im2);   
        axis tight; axis off;
        subaxis(2,2,3,'Spacing', 0.0, 'Padding', 0, 'Margin', 0);
        p2=imshow(im3);
        axis tight; axis off;


        imp = impoly();
        addNewPositionCallback(imp,@(p) assignin('base','xy',p));
        addNewPositionCallback(imp,@(p) assignin('base','xlim_this',get(gca, 'xlim')));
        addNewPositionCallback(imp,@(p) assignin('base','ylim_this',get(gca, 'ylim')));
        addNewPositionCallback(imp,@(p) redraw(p, im1, im2));

        set(f,'CloseRequestFcn','handle_alignment')
        uiwait;

        xy = evalin('base','xy');
        finishroi = evalin('base','finishroi');

        if (strcmp(finishroi, 'Yes'))
            done = true;  
        elseif (strcmp(finishroi, 'No - new ROI')) % new ROI
            delete(imp);
            clear xy;
            done = false;
            uiresume;  
        else % new alignment
            done = true;
        end
    end
    
    mask = poly2mask(xy(:,1), xy(:,2), size(im1, 1), size(im1, 2));
end