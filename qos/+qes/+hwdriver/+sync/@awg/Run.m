function Run(obj,N)
    % Run awg to output waveform N times, wave data should be already transfered
    % to AWG. N < 1, stop

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    N = round(N);
    TYP = lower(obj.drivertype);
    switch TYP
        case {'tek5000','tek5k',...
              'tek7000','tek7k',...
              'tek70000','tek70k'}
            % AWG: Tecktronix AWG 5000,7000,70000
            if N >= 1 
                for ii = 1:length(obj.nchnls)
                    try
                        fprintf(obj.interfaceobj,['OUTP', num2str(ii), ':STAT ON']);
                    catch
                    end
                end
                fprintf(obj.interfaceobj,'AWGC:RUN');
%                 while 1 % checking takes time, this is
%                         % drags downs measurement time considerably when
%                         % a lot of channels are used
%                     bol = obj.GetChnlOnOff(chnl);
%                     if ~islogical(bol)
%                         warnning('AWG:SetAWG','query instrument status failed, on status unknown');
%                         break;
%                     elseif bol
%                         break;
%                     elseif isprop(obj,'timeout') && toc > obj.timeout
%                         warnning('AWG:SetAWG','query instrument status timed out, on status unknown');
%                         break;
%                     end
%                     pause(0.1);
%                 end
            else
                for ii = 1:length(obj.nchnls)
                    try
                        fprintf(obj.interfaceobj,['OUTP', num2str(ii), ':STAT OFF']);
                    catch
                    end
                end
            end
        case {'ustc_da_v1'}
             obj.interfaceobj.Run(N);
        otherwise
            error('AWG:OffError','Unsupported awg!');
    end
end