function SetTrigInterval(obj)
    % Set trigger interval, internal trigger only
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if obj.trigmode ~= 1  % external trig
        warning('AWG:SetTrigInterval',...
            'AWG has been set to external trigger mode, set trig interval is for internal trigger mode only!');
        return;
    end
    TYP = lower(obj.drivertype);
    switch TYP
        case {'tek5000','tek5k',...
              'tek7000','tek7k',...
              'tek70000','tek70k'}
            % AWG: Tecktronix AWG 5000,7000,70000
            fprintf(obj.interfaceobj,['TRIG:SEQ:TIM ', num2str(1e3*obj.triginterval,'%0.3f'),'MS']); 
        case {'ustc_da_v1'}
            % can not set trigger interval on ustc_da_v1, defined in
            % registry
        otherwise
            error('AWG:SetTrigIntervalError','Unsupported awg!');
    end
end
