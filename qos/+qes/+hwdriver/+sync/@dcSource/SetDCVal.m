function SetDCVal(obj,val,chnl)
    % set instrument dc output value
    % adcmt 6166: 6161-compatible mode must be set to ON (set by using the instrument front panel)

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    try
        switch TYP
            case {'agilent33120','hp33120'}  % as voltage source
                SetAgilent_33120(obj,val);
                obj.dcval(chnl) = val;
            case {'adcmt6166i','adcmt6161i'} % as current source
                SetAdcmt_6166I(obj,val);
                obj.dcval(chnl) = val;
            case {'adcmt6166v','adcmt6161v'} % as current source
                SetAdcmt_6166V(obj,val);
                obj.dcval(chnl) = val;
            case {'yokogawa7651i'} % as current source
                SetYokogawa_7651I(obj,val);
                obj.dcval(chnl) = val;
            case {'yokogawa7651v'} % as current source
                SetYokogawa_7651V(obj,val);
                obj.dcval(chnl) = val;
            case {'ustc_dadc_v1'}
                obj.interfaceobj.SetDC(val,chnl);
                obj.dcval(chnl) = val;
            otherwise
                 error('DCSource:SetDCVal', ['Unsupported instrument: ',TYP]);
        end
    catch
        error('DCSource:SetDCVal', 'Setting instrument failed.');
    end
end