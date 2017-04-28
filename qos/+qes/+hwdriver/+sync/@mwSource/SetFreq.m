function SetFreq(obj,val,chnl)
% set microwave source frequecy and power
%

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if val < obj.freqlimits(chnl,1) || val > obj.freqlimits(chnl,2)
        error('mwSource:OutOfLimit','Frequency value out of limits.');
    end

    TYP = lower(obj.drivertype);
    switch TYP
        case {'agilent e82xx','agilent e8200','agle82xx','agle8200','agl e82xx','agl e8200',...
                'anritsu_mg3692c'}
            fprintf(obj.interfaceobj,[':SOUR:FREQ:FIX ',num2str(val(1),'%0.3f'),'Hz']);
            obj.frequency(chnl) = val;
        case {'rohde&schwarz sma100', 'r&s sma100','rssma100'}
            fprintf(obj.interfaceobj,[':SOUR:FREQ ',num2str(val(1),'%0.3f'),'Hz']);
            obj.frequency(chnl) = val;
		case {'sc5511a','simulatedmwsrc'}
			obj.interfaceobj.setFrequency(val,chnl);
			obj.frequency(chnl) = val;
        otherwise
            error('MWSource:SetError', ['Unsupported instrument: ',TYP]);
    end
end