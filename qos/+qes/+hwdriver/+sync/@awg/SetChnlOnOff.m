function SetChnlOnOff(obj,chnl,on,N)
    % Set the specified awg channel output on/off.
    % on = true/false, output on/off
    % this method is intended to be called within
    % the method Off of class waveform only.
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    switch TYP
        case {'tek5000','tek5k',...
              'tek7000','tek7k',...
              'tek70000','tek70k'}
            % AWG: Tecktronix AWG 5000,7000,70000
            if on
                fprintf(obj.interfaceobj,['OUTP', num2str(chnl), ':STAT ON']);
%                 while 1 % checking takes time, this is drags
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
                fprintf(obj.interfaceobj,['OUTP', num2str(chnl), ':STAT OFF']);
            end
        case {'ustc_da_v1'}
        otherwise
            error('AWG:OffError','Unsupported awg!');
    end
end