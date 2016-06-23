% calibrated_temperature(repmat(16000,[480 640]), 0.5, 293, 1, 1.9, 0.006569, -0.002276, 0.01262, -0.00667, 0.97, 1, 293, 293, 4214, 69.62449646, 16671, 1, 1430.099976)
function [Tkelvin] = calibrated_temperature(lPixval, m_RelHum, m_AtmTemp, m_ObjectDistance, m_X, m_alpha1, m_beta1, m_alpha2, m_beta2, m_Emissivity, m_ExtOptTransm, m_AmbTemp, m_ExtOptTemp, m_J0, m_J1, m_R, m_F, m_B)
    ASY_SAFEGUARD = 1.0002;

    [m_AtmTao, m_K1, m_K2] = doUpdateCalcConst(m_RelHum, m_AtmTemp, m_ObjectDistance, m_X, m_alpha1, m_beta1, m_alpha2, m_beta2, m_Emissivity, m_ExtOptTransm, m_AmbTemp, m_ExtOptTemp, m_B, m_F, m_R);
    %fprintf('tao: %.2f k1: %.2f k2: %.2f\n', m_AtmTao, m_K1, m_K2)

    dPow = (lPixval - m_J0) / m_J1;
    dSig = m_K1 * dPow - m_K2;
    dbl_reg = m_R ./ dSig + m_F;
    
    if (m_F <= 1.0)
        dbl_reg(dbl_reg < ASY_SAFEGUARD) = ASY_SAFEGUARD;
    else
        tmp = m_F * ASY_SAFEGUARD;
        dbl_reg(dbl_reg < tmp) = tmp;
    end

    Tkelvin = m_B ./ log(dbl_reg);
end

function [tao] = doCalcAtmTao(m_RelHum, m_AtmTemp, m_ObjectDistance, m_X, m_alpha1, m_beta1, m_alpha2, m_beta2)
    H2O_K1 = +1.5587e+0;
    H2O_K2 = +6.9390e-2;
    H2O_K3 = -2.7816e-4;
    H2O_K4 = +6.8455e-7;
    TAO_TATM_MIN = -30.0;	
    TAO_TATM_MAX  = 90.0;
    TAO_SQRTH2OMAX = 6.2365;
    TAO_COMP_MIN = 0.400;
    TAO_COMP_MAX = 1.000;

    H = m_RelHum;
    C = m_AtmTemp;
    T = (C - 273.15);

    sqrtD = sqrt(m_ObjectDistance);
    X  = m_X;
    a1 = m_alpha1;
    b1 = m_beta1;
    a2 = m_alpha2;
    b2 = m_beta2;

    if (T < TAO_TATM_MIN)
        T = TAO_TATM_MIN;
    elseif (T > TAO_TATM_MAX)
        T = TAO_TATM_MAX;
    end

    TT = T*T;

    sqrtH2O = sqrt(H*exp(H2O_K1 + H2O_K2*T + H2O_K3*TT + H2O_K4*TT*T));

    if (sqrtH2O > TAO_SQRTH2OMAX)
        sqrtH2O = TAO_SQRTH2OMAX;
    end

    a1b1sqH2O = (a1+b1*sqrtH2O);
    a2b2sqH2O = (a2+b2*sqrtH2O);
    exp1 = exp(-sqrtD*a1b1sqH2O);
    exp2 = exp(-sqrtD*a2b2sqH2O);

    tao = X*exp1 + (1-X)*exp2;
    dtao = -(a1b1sqH2O*X*exp1+a2b2sqH2O*(1-X)*exp2); 
    % The real D-derivative is also divided by 2 and sqrtD.
    % Here we only want the sign of the slope!

    if (tao < TAO_COMP_MIN)
        tao = TAO_COMP_MIN;		% below min value, clip
    elseif (tao > TAO_COMP_MAX)
        % check tao at 1 000 000 m dist
        tao = X*exp(-(1000)*a1b1sqH2O)+(1.0-X)*exp(-(1000)*a2b2sqH2O);

        % above max, staying up, assume \/-shape
        if (tao > 1.0)
            tao = TAO_COMP_MIN;
        else
            tao = TAO_COMP_MAX; % above max, going down, assume /\-shape
        end
    elseif ( dtao > 0.0 && m_ObjectDistance > 0.0)
        tao = TAO_COMP_MIN;	 % beween max & min, going up, assume \/
    end
    % else between max & min, going down => OK as it is, -)
end


function [K1] = doCalcK1(m_AtmTao, m_Emissivity, m_ExtOptTransm)
    dblVal = m_AtmTao * m_Emissivity * m_ExtOptTransm;

    if (dblVal > 0.0)
        dblVal = 1/dblVal;
    end
    
    K1 = dblVal;
end

function [K2] = doCalcK2(dAmbObjSig, dAtmObjSig, dExtOptTempObjSig, m_Emissivity, m_AtmTao, m_ExtOptTransm)
    fprintf('sig_refl: %.2f sig_atm: %.2f sig_extopt: %.2f\n', dAmbObjSig, dAtmObjSig, dExtOptTempObjSig)

    temp1 = 0.0;
    temp2 = 0.0;
    temp3 = 0.0;

    emi = m_Emissivity;

    if (emi > 0.0)
        temp1 = (1.0 - emi)/emi * dAmbObjSig;

        if (m_AtmTao > 0.0)
            temp2 = (1.0 - m_AtmTao)/(emi*m_AtmTao)* dAtmObjSig;
        end

        if (m_ExtOptTransm > 0.0 && m_ExtOptTransm < 1.0)
            temp3 = (1.0 - m_ExtOptTransm) / (emi*m_AtmTao*m_ExtOptTransm)* dExtOptTempObjSig;
        end
    end
    
    K2 = (temp1 + temp2 + temp3);
end

function [m_AtmTao, m_K1, m_K2] = doUpdateCalcConst(m_RelHum, m_AtmTemp, m_ObjectDistance, m_X, m_alpha1, m_beta1, m_alpha2, m_beta2, m_Emissivity, m_ExtOptTransm, m_AmbTemp, m_ExtOptTemp, m_B, m_F, m_R)
    m_AtmTao = doCalcAtmTao(m_RelHum, m_AtmTemp, m_ObjectDistance, m_X, m_alpha1, m_beta1, m_alpha2, m_beta2);

    m_K1 = doCalcK1(m_AtmTao, m_Emissivity, m_ExtOptTransm);

    m_K2 = doCalcK2(tempToObjSig(m_AmbTemp, m_B, m_F, m_R),tempToObjSig(m_AtmTemp, m_B, m_F, m_R),tempToObjSig(m_ExtOptTemp, m_B, m_F, m_R), m_Emissivity, m_AtmTao, m_ExtOptTransm);
end

function [objSign] = tempToObjSig(dblKelvin, m_B, m_F, m_R)
    ASY_SAFEGUARD = 1.0002;
    EXP_SAFEGUARD = 709.78;

    objSign = 0.0;
    dbl_reg = dblKelvin;

    % objSign = R / (exp(B/T) - F)
    %objSign = m_R / (exp(m_B/dbl_reg) - m_F);

     if (dbl_reg > 0.0)
         dbl_reg = m_B / dbl_reg; 
 
         if (dbl_reg < EXP_SAFEGUARD)
             dbl_reg = exp(dbl_reg); 
 
             if (m_F <= 1.0)
                 if ( dbl_reg < ASY_SAFEGUARD )
                     dbl_reg = ASY_SAFEGUARD; % Don't get above a R/(1-F) (horizontal) asymptote
                 end
             else
                 % F > 1.0
                 if ( dbl_reg < m_F*ASY_SAFEGUARD )
                     dbl_reg = m_F*ASY_SAFEGUARD;
                     % Don't get too close to a B/ln(F) (vertical) asymptote
                 end
             end
 
             objSign = m_R/(dbl_reg - m_F);
         end
     end
end
    





