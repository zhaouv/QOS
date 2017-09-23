function SetFreq(obj,val,chnl)
% set microwave source frequecy and power
%

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if val < obj.freqlimits(chnl,1) || val > obj.freqlimits(chnl,2)
        throw(MException('QOS_mwSource:freqOutOfLimit',...
            sprintf('Frequency value %0.3fGHz out of limits.',val/1e9)));
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
        case {'sinolink'}
            fwrite(obj.interfaceobj,['FREQ ',num2str(val(1)/1e9,'%0.9f'),' GHz']);
            obj.frequency(chnl) = val;
            pause(1)
        otherwise
            error('MWSource:SetError', ['Unsupported instrument: ',TYP]);
    end
    
%     % to have things flushing out on screen, keep for occassions like TV interviews 
%     disp(sprintf('setting frequency of mw src [%s] to %0.3fGHz on chnl %0.0f',...
%                 obj.name,val/1e9,chnl));
end