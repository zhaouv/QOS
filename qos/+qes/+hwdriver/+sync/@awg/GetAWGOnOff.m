function val = GetAWGOnOff(obj)
   % Get awg running status
   % 

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    switch TYP
        case {'tek5000','tek5k',...
              'tek7000','tek7k',...
              'tek70000','tek70k'}
            flushinput(obj.interfaceobj); % query dose not flush input butter(R2013b)
            temp = query(obj.interfaceobj,'AWGControl:RSTate?');
            if isempty(temp(1))
                error('AWG:GetAWGOnOff','unrecognized qurery result!');
            end
            status = str2double(temp(1));
            if status == 0
                val = false;
            elseif status >= 1
                val = true;
            else
                error('AWG:GetAWGOnOff','unrecognized qurery result!');
            end
        case {'hp33120','agl33120','hp33220','agl33220'} % not tested
            flushinput(obj.interfaceobj); % query dose not flush input butter(R2013b)
            temp = query(obj.interfaceobj,'BM:STAT?');
            if strcmp(temp(1),'0')
                val = false;
            elseif strcmp(temp(1),'1')
                val = true;
            else
                error('AWG:GetAWGOnOff','unrecognized qurery result!');
            end
        case {'ustc_da_v1'}
            warning('AWG:GetAWGOnOff','Not implemented!');
            val = true;
        otherwise
            error('AWG:StopError','Unsupported awg!');
    end
end