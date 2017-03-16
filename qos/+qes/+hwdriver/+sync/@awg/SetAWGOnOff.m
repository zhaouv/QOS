function SetAWGOnOff(obj,On)
   % Run or Stop AWG
   % 

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    switch TYP
        case {'tek5000','tek5k',...
              'tek7000','tek7k',...
              'tek70000','tek70k'}
            % AWG: Tecktronix AWG 5000,7000,70000
            if On
                if isempty(cell2mat(obj.waveforms))
                    error('AWG:SetAWG','no waveform');
                end
                fprintf(obj.interfaceobj,'AWGC:RUN');
                tic
                while 1
                    if obj.on
                        break;
                    elseif isprop(obj,'timeout') && toc > obj.timeout
                        warnning('AWG:SetAWG','query instrument status timed out, on status unknown');
                        break;
                    end
                    pause(0.5);
                end
            else
                fprintf(obj.interfaceobj,'AWGC:STOP');
            end
        case {'ustc_da_v1'}
        otherwise
            error('AWG:StopError','Unsupported awg!');
    end
end