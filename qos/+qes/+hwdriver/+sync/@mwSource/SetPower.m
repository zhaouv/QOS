function SetPower(obj,val,chnl)
% set microwave source frequecy and power
%

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if val < obj.powerlimits(chnl,1) || val > obj.powerlimits(chnl,2)
        error('mwSource:OutOfLimit',[obj.name, ': Power value out of limits!']);
    end
            
    TYP = lower(obj.drivertype);
    switch TYP
        case {'agilent e82xx','agilent e8200','agle82xx','agle8200','agl e82xx','agl e8200',...
                'anritsu_mg3692c'}
            fprintf(obj.interfaceobj,[':SOUR:POWER ',num2str(val(1),'%0.2f'),'DBM']);
            obj.power(chnl) = val;
        case {'rohde&schwarz sma100', 'r&s sma100','rssma100'}
            fprintf(obj.interfaceobj,[':SOUR:POW ',num2str(val(1),'%0.2f')]);
            obj.power(chnl) = val;
		case {'sc5511a','simulatedmwsrc'}
			obj.interfaceobj.setPower(val,chnl);
			obj.power(chnl) = val;
        otherwise
             error('MWSource:SetError', ['Unsupported instrument: ',TYP]);
    end
    
%     % to have things flushing out on screen, keep for occassions like TV interviews 
%     disp(sprintf('setting power of mw src [%s] to %0.3fdBm on chnl %0.0f',...
%                 obj.name,val,chnl));
end