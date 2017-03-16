function SetOnOff(obj,On)
   % set instrument output to on or off

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    TYP = lower(obj.drivertype);
    switch TYP
        case {'agle82xx','agle8200','agl e82xx','agl e8200',...
                'rohde&schwarz sma100', 'r&s sma100',...
                'anritsu_mg3692c'}
            if On
                fprintf(obj.interfaceobj,':OUTP ON ');
            else
                fprintf(obj.interfaceobj,':OUTP OFF ');
            end
        otherwise
              error('MWSource:SetOnOff', ['Unsupported instrument: ',TYP]);
    end
end