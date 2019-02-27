function [Tkelvin] = calibrated_temperature_simple(counts, temp_atm, temp_reflected, temp_external_optics, relative_humidity, emissivity, distance_focal)
    %[temp_atm, temp_reflected, temp_external_optics, relative_humidity, emissivity, distance_focal]

    Tkelvin = calibrated_temperature( ...
        double(counts), ... % input data
        relative_humidity, ... % relative humidity (fraction)
        temp_atm, ... % atmospheric temp (K)
        distance_focal, ... % object distance (m)
        1.9, ... % X
        0.006569, ... % alpha_1
        -0.002276, ... % beta_1
        0.01262, ... % alpha_2
        -0.00667, ... % beta_2
        emissivity, ... % emissivity
        1, ... % external optics transmission
        temp_reflected, ... % reflected (ambient) temperature
        temp_external_optics, ... % external optics temperature
        4214, ... % J0
        69.62449646, ... % J1
        16671, ... % R
        1, ... % F
        1430.099976... % B
    );
end
