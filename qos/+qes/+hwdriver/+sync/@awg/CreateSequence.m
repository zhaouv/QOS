function CreateSequence(obj,chnlnum,wvfrmnamelst)
    % Create a squence for channel chnlnum whith waveforms specified by
    % names in wvfrmnamelst(cell).Waveforms to form the sequence should 
    % already exit in the awg, if not, send them by SendWave before 
    % creating the sequence.
    % example:
    % AWG1.CreateSequence(2,{'wv1','wv5','untitled1','wv5',''wv3'})
    % creates a sequence for channel 2 of AWG1, whith 'wv1' at the head
    % of the sequence.
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    N = numel(wvfrmnamelst);
    if N < 2
        error('AWG:CreateSequenceError','zero or one waveform can not form a sequence');
    end
    switch TYP
        case {'tek5000','tek5k','tek7000','tek7k','tek70000','tek70k'}
            % AWG: Tecktronix AWG 5000. The following code could also work
            % for Tecktronix AWG 7000 and 70000(not tested).
            if isempty(chnlnum) || round(chnlnum)~=chnlnum || chnlnum <=0 || chnlnum > obj.nchnls 
                error('AWG:CreateSequenceError','invalid chnlnum!');
            end
            switch TYP
                case{'tek5000','tek5k'}
                    if N > 7998
                        error('AWG:CreateSequenceError','sequence waveform  number bigger than Tek awg 7998 maximum 16000');
                    end
                case{'tek7000','tek7k'}
                    if N > 16000
                        error('AWG:CreateSequenceError','sequence waveform  number bigger than Tek awg 7000 maximum 16000');
                    end
                case{'tek70000','tek70k'}
                    
            end
            fprintf(obj.interfaceobj,'AWGC:RMOD SEQuence');
            fprintf(obj.interfaceobj, ['SEQUENCE:LENGTH ', num2str(N)]);
            for ii = 1:N
                WvfrmName = wvfrmnamelst{ii};
                if isempty(WvfrmName) || ~ischar(WvfrmName) || ~isvarname(WvfrmName)
                    error('AWG:CreateSequenceError','Invalid waveform name!');
                end
            end
            for ii = 1:N
                fprintf(obj.interfaceobj, ['SEQUENCE:ELEMENT', num2str(ii,'%d'),...
                                ':WAVEFORM', num2str(chnlnum,'%d'), ' "', wvfrmnamelst{ii}, '"']);
                fprintf(obj.interfaceobj, ['SEQUENCE:ELEMENT', num2str(ii,'%d'), ':GOTO:STATE 1']);
                if ii ~= N
                    fprintf(obj.interfaceobj, ['SEQUENCE:ELEMENT', num2str(ii,'%d'), ':GOTO:INDEX ', num2str(ii+1)]);
                else
                    fprintf(obj.interfaceobj, ['SEQUENCE:ELEMENT', num2str(ii,'%d'), ':GOTO:INDEX 1']);
                end
                if obj.trigmode == 1 % internal
                    fprintf(obj.interfaceobj, ['SEQUENCE:ELEMENT', num2str(ii,'%d'), ':TWAIT 0']);
                else
                    fprintf(obj.interfaceobj, ['SEQUENCE:ELEMENT', num2str(ii,'%d'), ':TWAIT 1']);
                end
            end
        case {'ustc_da_v1'}
            error('AWG:CreateSequenceError','Not implemented!');
        otherwise
            error('AWG:CreateSequenceError','Unsupported awg!');
    end
end
