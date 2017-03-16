function SetSmplRate(obj)
    % Set sampling rate
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    switch TYP
        case {'tek5000','tek5k',...
              'tek7000','tek7k',...
              'tek70000','tek70k'}
            % AWG: Tecktronix AWG 5000,7000,70000
            switch TYP
                case {'tek5000','tek5k'}
                    if obj.sampling_rate > 1.2e9 || obj.sampling_rate < 10e6
                        error('AWG:SetSmplRateError','TekAWG5000: Sampling freqeuncy out of range(max:1.2GHz, min:10MHz)!');
                    end
                case {'tek7000','tek7k'}
                    if obj.sampling_rate > 12e9 || obj.sampling_rate < 10e6
                        error('AWG:SetSmplRateError','TekAWG7000: Sampling freqeuncy out of range(max:12GHz, min:10MHz)!');
                    end
                case {'tek70000','tek70k'}
                    if obj.sampling_rate > 50e9 || obj.sampling_rate < 1.49e3
                        error('AWG:SetSmplRateError','TekAWG70000: Sampling freqeuncy out of range(max:50GHz, min:1.49kHz)!');
                    end
            end
            % Set sampling frequency. Note: 'SOUR1' dose not mean it's
            % the sampling frequency of chnl1/source1!
            fprintf(obj.interfaceobj,['SOUR1', [':FREQ ', num2str(obj.sampling_rate/1e9,'%0.9f'), 'GHZ']]); 
        case {'ustc_da_v1'}
			% warning('AWG:SetSmplRateError','sampling rate of ustc da can not be set.');
        otherwise
            error('AWG:SetSmplRateError','Unsupported awg!');
    end
end
