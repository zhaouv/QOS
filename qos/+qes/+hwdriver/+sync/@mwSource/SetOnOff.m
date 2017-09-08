function SetOnOff(obj,On,chnl)
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
		case {'sc5511a','simulatedmwsrc'}
			obj.interfaceobj.setOnOff(On,chnl);
        case {'sinolink'}
            if On
                fprintf(obj.interfaceobj,'LEVEL:STATE ON');
            else
                fprintf(obj.interfaceobj,'LEVEL:STATE OFF');
            end
            pause(0.1)
        otherwise
              error('MWSource:SetOnOff', ['Unsupported instrument: ',TYP]);
    end
end