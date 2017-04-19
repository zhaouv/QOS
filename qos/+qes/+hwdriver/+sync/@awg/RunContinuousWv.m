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
%             if ~isempty(WaveformObj.sb_comp)
%                 mzeros=WaveformObj.sb_comp([1,2]);
%             else
                mzeros = obj.MixerZeros(WaveformObj.awgchnl,WaveformObj.fc);
%             end
            WaveformData = {real(y);imag(y)};
            WaveformData{1} = uint16(WaveformData{1} + mzeros(1)+32768);
            WaveformData{2} = uint16(WaveformData{2}*WaveformObj.balance + mzeros(2)+32768);
            if max(WaveformData{2})>65536 || min(max(WaveformData{2})>65536 )<0
                warning('IQ amp too high!')
                WaveformData = {real(y);imag(y)};
                WaveformData{1} = uint16(WaveformData{1}/WaveformObj.balance + mzeros(1)+32768);
                WaveformData{2} = uint16(WaveformData{2} + mzeros(2)+32768);
            end
%             figure(55);plot(WaveformData{1});hold on;plot(WaveformData{2});axis tight;hold off;title(num2str([WaveformObj.balance mzeros]))
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
