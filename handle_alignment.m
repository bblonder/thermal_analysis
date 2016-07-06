finishroi = questdlg('Finish ROI selection','ROI','Yes','No - realign','No - new ROI','Yes');

delete(get(0,'CurrentFigure'));
uiresume;  