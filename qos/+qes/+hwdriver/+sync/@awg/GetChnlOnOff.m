function val = GetChnlOnOff(obj,chnl)
    % query output status of the channel chnl
    % this method is intended to be called within
    % the method On of class waveform only.
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    switch TYP
        case {'tek5000','tek5k',...
              'tek7000','tek7k',...
              'tek70000','tek70k'}
            % AWG: Tecktronix AWG 5000,7000,70000
            flushinput(obj.interfaceobj); % query dose not flush input butter(R2013b)
            str = query(obj.interfaceobj,['OUTP', num2str(chnl), ':STAT?']);
            if strcmp(str(1), '1')
                val = true;
            elseif strcmp(str(1), '0')
                val = false;
            else
                error('AWG:GetChnlOnOff', 'an instrument query got unexpected result.');
            end
        case {'hp33120','agl33120','hp33220','agl33220'}
            val = obj.on;
        case {'ustc_da_v1'}
            waring('not implemented.');
            val = true;
        otherwise
            error('AWG:SendWaveError','Unsupported awg!');
    end
end