function SetRunMode(obj)
    % Set run mode, triggered of continues
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    switch TYP
        case {'tek5000','tek5k',...
              'tek7000','tek7k'}
            % AWG: Tecktronix AWG 5000, 7000
            switch obj.runmode
                case 1 % triggered mode
                    fprintf(obj.interfaceobj,'AWGC:RMOD TRIG'); 
                    fprintf(obj.interfaceobj,'TRIG:WVAL FIRS'); 
                case 2 % sequence  mode
                    fprintf(obj.interfaceobj,'AWGC:RMOD SEQuence'); 
                case 3 % gated  mode
                    fprintf(obj.interfaceobj,'AWGC:RMOD GAT'); 
                    fprintf(obj.interfaceobj,'TRIG:WVAL FIRS'); 
                case 4 % continues  mode
                    fprintf(obj.interfaceobj,'AWGC:RMOD CONT'); 
                otherwise
                    error('AWG:InvalidPoperty','Invalid runmode value for Tecktronix AWG 5000/7000(valid: 0/1/2/3 for triggered/sequence/gated/continues)');
            end
        case {'tek70000','tek70k'}
            % AWG: Tecktronix AWG 70000
            switch obj.runmode
                case 0 % triggered mode
                    fprintf(obj.interfaceobj,'AWGC:RMOD TRIG'); 
                    fprintf(obj.interfaceobj,'TRIG:WVAL FIRS'); 
                case 1 % sequence  mode
                    fprintf(obj.interfaceobj,'AWGC:RMOD SEQuence'); 
                otherwise
                    error('AWG:InvalidPoperty','Invalid runmode value for Tecktronix AWG 70000(valid: 0/1 for triggered/sequence)');
            end
        case {'ustc_da_v1'}
            return;
%             disp('Set Run Mmode Not implemented!');
        otherwise
            error('AWG:SetRunModeError','Unsupported awg!');
    end
end
