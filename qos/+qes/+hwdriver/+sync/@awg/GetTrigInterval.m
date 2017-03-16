function val  = GetTrigInterval(obj)
    % Get trigger interval
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    switch TYP
        case {'tek5000','tek5k',...
              'tek7000','tek7k',...
              'tek70000','tek70k'}
            % AWG: Tecktronix AWG 5000,7000,70000
            warnning('todo...');
            val = NaN;
        case {'ustc_da_v1'}
            val = obj.interfaceobj.trigInterval;
        otherwise
            error('AWG:SetTrigIntervalError','Unsupported awg!');
    end
end
