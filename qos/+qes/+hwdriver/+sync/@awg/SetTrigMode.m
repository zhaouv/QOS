function SetTrigMode(obj)
    % Set trigger mode, internal or external
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    switch TYP
        case {'tek5000','tek5k',...
              'tek7000','tek7k',...
              'tek70000','tek70k'}
            % AWG: Tecktronix AWG 5000,7000,70000
            if obj.trigmode == 1
                fprintf(obj.interfaceobj,'TRIG:SEQ:SOUR INT'); 
            elseif obj.trigmode == 2
                fprintf(obj.interfaceobj,'TRIG:SEQ:SOUR EXT'); 
            else
                error('AWG:SetTirgModeError','Unrecognized trig mode!');
            end
        case {'ustc_da_v1'}
        otherwise
            error('AWG:SetTirgModeError','Unsupported awg!');
    end
end
