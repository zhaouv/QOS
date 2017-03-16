function DelWave(obj,wavename)
   % Run or Stop AWG
   % 

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    switch TYP
        case {'tek5000','tek5k',...
              'tek7000','tek7k',...
              'tek70000','tek70k'}
          if nargin == 1
              fprintf(obj.interfaceobj, 'WLIS:WAV:DEL ALL');
          else
              fprintf(obj.interfaceobj, ['WLIS:WAV:DEL "',wavename, '"']);
          end
        case {'ustc_da_v1'}
        otherwise
            error('AWG:StopError','Unsupported awg!');
    end
end