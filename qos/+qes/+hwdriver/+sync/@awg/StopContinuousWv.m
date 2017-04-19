function StopContinuousWv(obj,WaveformObj)
    %
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    switch TYP
        case {'tek5000','tek5k',...
              'tek7000','tek7k'}
            error('not implemented');
        case {'tek70000','tek70k'}
            error('not implemented');
        case {'ustc_da_v1'}
            if WaveformObj.iq
                obj.interfaceobj.StopContinuousRun(WaveformObj.awgchnl(1));
                obj.interfaceobj.StopContinuousRun(WaveformObj.awgchnl(2));
            else
                obj.interfaceobj.StopContinuousRun(WaveformObj.awgchnl(1));
            end
        otherwise
            error('AWG:SetRunModeError','Unsupported awg!');
    end
end
