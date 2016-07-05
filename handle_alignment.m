finishroi = questdlg('Finish ROI selection');

if (strcmp(finishroi,'Yes'))
    delete(get(0,'CurrentFigure'));
    fprintf('do extraction here\n');
    uiresume;
elseif (strcmp(finishroi,'No'))
    delete(imp);
    imp = impoly();
    addNewPositionCallback(imp,@(p) assignin('base','xy',p));
    addNewPositionCallback(imp,@(p) redraw(p, im1));
end