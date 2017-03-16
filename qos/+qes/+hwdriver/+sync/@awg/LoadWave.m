function LoadWave(obj,WaveformObj,Delay)
    % Load wave into the specified awg channel.
    % this method is intended to be called within
    % the method LoadWave of class waveform only.
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if nargin < 3
        Delay = 0;
    end
    TYP = lower(obj.drivertype);
    switch TYP
        case {'tek5000','tek5k','tek7000','tek7k'} % tek awg dose not support delay.
            % AWG: Tecktronix AWG 5000,7000,70000
            WvfrmName = WaveformObj.name;
            ChnlIdx = WaveformObj.awgchnl;
            fprintf(obj.interfaceobj,['SOUR', num2str(ChnlIdx), ':WAV "', WvfrmName, '"']); 
            fprintf(obj.interfaceobj,['SOUR', num2str(WaveformObj.awgchnl),':VOLT:AMPL 0.6']);
            fprintf(obj.interfaceobj,['SOUR', num2str(WaveformObj.awgchnl),':VOLT:OFFS 0']);
            fprintf(obj.interfaceobj,['AWGCONTROL:DOUTPUT', num2str(WaveformObj.awgchnl), ':STATE 1']);
        case {'hp33120','agl33120','hp33220','agl33220'} % not tested
            % todo
        case {'ustc_da_v1'}
            obj.interfaceobj.LoadWave(WaveformObj.awgchnl,WaveformObj.name,Delay); % add delay
        otherwise
            error('AWG:LoadWaveError','Unsupported awg!');
    end
end
        
    