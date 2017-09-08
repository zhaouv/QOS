function RunContinuousWv(obj,WaveformObj)
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
        t = WaveformObj.t0:ceil(WaveformObj.t0+WaveformObj.length-1);
        y = WaveformObj(t);
        if WaveformObj.iq
            mzeros = obj.MixerZeros(WaveformObj.awgchnl,WaveformObj.fc);
            WaveformData = {real(y);imag(y)};
            WaveformData{1} = uint16(WaveformData{1} + mzeros(1)+32768);
            WaveformData{2} = uint16(WaveformData{2} + mzeros(2)+32768);
%             figure(55);plot(WaveformData{1});hold on;plot(WaveformData{2});axis tight;hold off;title(num2str([mean(WaveformData{1}) mean(WaveformData{2}) ]-32768))
        else
            WaveformData = {uint16(real(y)+32768)};
        end
        if WaveformObj.iq
            obj.interfaceobj.StartContinuousRun(WaveformObj.awgchnl(1),WaveformData{1});
            obj.interfaceobj.StartContinuousRun(WaveformObj.awgchnl(2),WaveformData{2});
        else
            obj.interfaceobj.StartContinuousRun(WaveformObj.awgchnl(1),WaveformData{1});
        end
    otherwise
        error('AWG:SetRunModeError','Unsupported awg!');
end
end
