g = gigecam(1);

g.IRFormat='TemperatureLinear10mK'; %'Radiometric'
g.TSensSelector='Shutter';
g.NoiseReduction='On';
g.AutoFocusMethod='Fine';

nucinterval = 100;
counter = 0;

while(1)
    if (mod(counter,nucinterval)==0)
        executeCommand(g, 'NUCAction');
        executeCommand(g, 'AutoFocus');
        pause(3);
    end
    [img, ts] = snapshot(g);
    img = double(img) * (10/1000) - 273.15;

    imagesc(img); colorbar;
    
    counter = counter + 1;
end
