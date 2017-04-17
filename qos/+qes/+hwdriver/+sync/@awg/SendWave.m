function SendWave(obj,WaveformObj)
    % send waveform to awg. this method is intended to be called within
    % the method SendWave of class waveform only.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    TYP = lower(obj.drivertype);
    switch TYP
        case {'tek5000','tek5k'}
            % AWG: Tecktronix AWG 5000
            % tek awgs dose not support hardware delay
            software_delay = WaveformObj.output_delay;
            WaveformData = obj.PrepareWvData_Tek5k7k(WaveformObj,0.6,14,software_delay);
            if WaveformObj.iq
                if isempty(WaveformObj.name)
                    WvfrmName = ['Untitled_',datestr(now,'yymmdd_HHMMSS'),'_',num2str(10000*rand(1),'%0.0f'),'_I'];
                else
                    WvfrmName = [WaveformObj.name,'_I'];
                end
                startidx = 0;
                wvdatasize = WaveformObj.length;
                fprintf(obj.interfaceobj, ['WLIS:WAV:DEL "',WaveformObj.name, '"']);
                WvfrmNameStr = ['WLIS:WAV:NEW "', WvfrmName, '"'];
                WvfrmWriteStr = ['WLIS:WAV:DATA "', WvfrmName, '"',',',num2str(startidx),',',num2str(wvdatasize),...
                        ',#', num2str(length(num2str(2*wvdatasize))), num2str(2*wvdatasize)];
                % create a waveform in the AWG waveform list
                % send by integer is 2.5 times faster than send by float.
                fprintf(obj.interfaceobj,[WvfrmNameStr,',', num2str(wvdatasize), ',INT']);
                % send waveform data to the newly created waveform
                fwrite(obj.interfaceobj,WvfrmWriteStr);
                fwrite(obj.interfaceobj,WaveformData{1}(startidx+1:startidx+wvdatasize),'uint16');  % 'uint16'! NOT 'int16'
                fwrite(obj.interfaceobj, 10);
                
                if isempty(WaveformObj.name)
                    WvfrmName = ['Untitled_',datestr(now,'yymmdd_HHMMSS'),'_',num2str(10000*rand(1),'%0.0f'),'_Q'];
                else
                    WvfrmName = [WaveformObj.name,'_Q'];
                end
                startidx = 0;
                wvdatasize = WaveformObj.length;
                fprintf(obj.interfaceobj, ['WLIS:WAV:DEL "',WaveformObj.name, '"']);
                WvfrmNameStr = ['WLIS:WAV:NEW "', WvfrmName, '"'];
                WvfrmWriteStr = ['WLIS:WAV:DATA "', WvfrmName, '"',',',num2str(startidx),',',num2str(wvdatasize),...
                        ',#', num2str(length(num2str(2*wvdatasize))), num2str(2*wvdatasize)];
                % create a waveform in the AWG waveform list
                % send by integer is 2.5 times faster than send by float.
                fprintf(obj.interfaceobj,[WvfrmNameStr,',', num2str(wvdatasize), ',INT']);
                % send waveform data to the newly created waveform
                fwrite(obj.interfaceobj,WvfrmWriteStr);
                fwrite(obj.interfaceobj,WaveformData{2}(startidx+1:startidx+wvdatasize),'uint16');  % 'uint16'! NOT 'int16'
                fwrite(obj.interfaceobj, 10);
            else
                if isempty(WaveformObj.name)
                    WvfrmName = ['Untitled_',datestr(now,'yymmdd_HHMMSS'),'_',num2str(10000*rand(1),'%0.0f')];
                else
                    WvfrmName = WaveformObj.name;
                end
                startidx = 0;
                wvdatasize = WaveformObj.length;
                fprintf(obj.interfaceobj, ['WLIS:WAV:DEL "',WaveformObj.name, '"']);
                WvfrmNameStr = ['WLIS:WAV:NEW "', WvfrmName, '"'];
                WvfrmWriteStr = ['WLIS:WAV:DATA "', WvfrmName, '"',',',num2str(startidx),',',num2str(wvdatasize),...
                        ',#', num2str(length(num2str(2*wvdatasize))), num2str(2*wvdatasize)];
                % create a waveform in the AWG waveform list
                % send by integer is 2.5 times faster than send by float.
                fprintf(obj.interfaceobj,[WvfrmNameStr,',', num2str(wvdatasize), ',INT']);
                % send waveform data to the newly created waveform
                fwrite(obj.interfaceobj,WvfrmWriteStr);
                fwrite(obj.interfaceobj,WaveformData{1}(startidx+1:startidx+wvdatasize),'uint16');  % 'uint16'! NOT 'int16'
                fwrite(obj.interfaceobj, 10);
            end
        case {'tek7000','tek7k'}
            % AWG: Tecktronix awg 7000
            WaveformData = qes.hwdriver.sync.awg.PrepareWvData_Tek5k7k(WaveformObj,0.5,10);
            if WaveformObj.iq
                if isempty(WaveformObj.name)
                    WvfrmName = ['Untitled_',datestr(now,'yymmdd_HHMMSS'),'_',num2str(10000*rand(1),'%0.0f'),'_I'];
                else
                    WvfrmName = [WaveformObj.name,'_I'];
                end
                startidx = 0;
                wvdatasize = WaveformObj.length;
                WvfrmNameStr = ['WLIS:WAV:NEW "', WvfrmName, '"'];
                WvfrmWriteStr = ['WLIS:WAV:DATA "', WvfrmName, '"',',',num2str(startidx),',',num2str(wvdatasize),...
                        ',#', num2str(length(num2str(2*wvdatasize))), num2str(2*wvdatasize)];
                % create a waveform in the AWG waveform list
                % send by integer is 2.5 times faster than send by float.
                fwrite(obj.interfaceobj,[WvfrmNameStr,',', num2str(wvdatasize), ',INT',10]); 
                % send waveform data to the newly created waveform
                fwrite(obj.interfaceobj,WvfrmWriteStr);
                fwrite(obj.interfaceobj,WaveformData{1}(startidx+1:startidx+wvdatasize),'uint16');  % 'uint16'! NOT 'int16'
                fwrite(obj.interfaceobj, 10);
                
                if isempty(WaveformObj.name)
                    WvfrmName = ['Untitled_',datestr(now,'yymmdd_HHMMSS'),'_',num2str(10000*rand(1),'%0.0f'),'_Q'];
                else
                    WvfrmName = [WaveformObj.name,'_Q'];
                end
                startidx = 0;
                wvdatasize = WaveformObj.length;
                WvfrmNameStr = ['WLIS:WAV:NEW "', WvfrmName, '"'];
                WvfrmWriteStr = ['WLIS:WAV:DATA "', WvfrmName, '"',',',num2str(startidx),',',num2str(wvdatasize),...
                        ',#', num2str(length(num2str(2*wvdatasize))), num2str(2*wvdatasize)];
                % create a waveform in the AWG waveform list
                % send by integer is 2.5 times faster than send by float.
                fwrite(obj.interfaceobj,[WvfrmNameStr,',', num2str(wvdatasize), ',INT',10]); 
                % send waveform data to the newly created waveform
                fwrite(obj.interfaceobj,WvfrmWriteStr);
                fwrite(obj.interfaceobj,WaveformData{2}(startidx+1:startidx+wvdatasize),'uint16');  % 'uint16'! NOT 'int16'
                fwrite(obj.interfaceobj, 10);
            else
                if isempty(WaveformObj.name)
                    WvfrmName = ['Untitled_',datestr(now,'yymmdd_HHMMSS'),'_',num2str(10000*rand(1),'%0.0f')];
                else
                    WvfrmName = [WaveformObj.name];
                end
                startidx = 0;
                wvdatasize = WaveformObj.length;
                WvfrmNameStr = ['WLIS:WAV:NEW "', WvfrmName, '"'];
                WvfrmWriteStr = ['WLIS:WAV:DATA "', WvfrmName, '"',',',num2str(startidx),',',num2str(wvdatasize),...
                        ',#', num2str(length(num2str(2*wvdatasize))), num2str(2*wvdatasize)];
                % create a waveform in the AWG waveform list
                % send by integer is 2.5 times faster than send by float.
                fwrite(obj.interfaceobj,[WvfrmNameStr,',', num2str(wvdatasize), ',INT',10]); 
                % send waveform data to the newly created waveform
                fwrite(obj.interfaceobj,WvfrmWriteStr);
                fwrite(obj.interfaceobj,WaveformData{1}(startidx+1:startidx+wvdatasize),'uint16');  % 'uint16'! NOT 'int16'
                fwrite(obj.interfaceobj, 10);
            end
        case {'tek70000','tek70k'}
            % AWG: Tecktronix AWG 70000
            if WaveformObj.length < 4800
                error('AWG:SendWaveError','Waveform length short than Tek 70000 minimum: 4800 points!');
            end
            WaveformData = qes.hwdriver.sync.awg.PrepareWvData_Tek70k(WaveformObj);
            if WaveformObj.iq
                if isempty(WaveformObj.name)
                    WvfrmName = ['Untitled_',datestr(now,'yymmdd_HHMMSS'),'_',num2str(10000*rand(1),'%0.0f'),'_I'];
                else
                    WvfrmName = [WaveformObj.name,'_I'];
                end
                startidx = 0;
                wvdatasize = WaveformObj.length;
                if isprop(WaveformObj,'uploadstartidx') && isprop(WaveformObj,'uploadendidx') &&...
                        ~isempty(WaveformObj.uploadstartidx) && ~isempty(WaveformObj.uploadendidx)
                    startidx = WaveformObj.uploadstartidx - 1;
                    wvdatasize = WaveformObj.uploadendidx - WaveformObj.uploadstartidx + 1;
                end
                WvfrmNameStr = ['WLIS:WAV:NEW "', WvfrmName, '"'];
                WvfrmWriteStr = ['WLIS:WAV:DATA "', WvfrmName, '"',',',num2str(startidx),',',num2str(wvdatasize),...
                        ',#', num2str(length(num2str(4*wvdatasize))), num2str(4*wvdatasize)];  % float point, 4 bytes per data point
                % create a waveform in the AWG waveform list
                fprintf(obj.interfaceobj,[WvfrmNameStr,',', num2str(wvdatasize)]);
                % send waveform data to the newly created waveform
                fwrite(obj.interfaceobj,WvfrmWriteStr);
                fwrite(obj.interfaceobj,WaveformData{1}(startidx+1:startidx+wvdatasize),'float'); % awg 70k only support floating point waveform data points
                fwrite(obj.interfaceobj, 10);
                
                if isempty(WaveformObj.name)
                    WvfrmName = ['Untitled_',datestr(now,'yymmdd_HHMMSS'),'_',num2str(10000*rand(1),'%0.0f'),'_Q'];
                else
                    WvfrmName = [WaveformObj.name,'_Q'];
                end
                startidx = 0;
                wvdatasize = WaveformObj.length;
                if isprop(WaveformObj,'uploadstartidx') && isprop(WaveformObj,'uploadendidx') &&...
                        ~isempty(WaveformObj.uploadstartidx) && ~isempty(WaveformObj.uploadendidx)
                    startidx = WaveformObj.uploadstartidx - 1;
                    wvdatasize = WaveformObj.uploadendidx - WaveformObj.uploadstartidx + 1;
                end
                WvfrmNameStr = ['WLIS:WAV:NEW "', WvfrmName, '"'];
                WvfrmWriteStr = ['WLIS:WAV:DATA "', WvfrmName, '"',',',num2str(startidx),',',num2str(wvdatasize),...
                        ',#', num2str(length(num2str(4*wvdatasize))), num2str(4*wvdatasize)];  % float point, 4 bytes per data point
                % create a waveform in the AWG waveform list
                fprintf(obj.interfaceobj,[WvfrmNameStr,',', num2str(wvdatasize)]);
                % send waveform data to the newly created waveform
                fwrite(obj.interfaceobj,WvfrmWriteStr);
                fwrite(obj.interfaceobj,WaveformData{2}(startidx+1:startidx+wvdatasize),'float'); % awg 70k only support floating point waveform data points
                fwrite(obj.interfaceobj, 10);
            else
                if isempty(WaveformObj.name)
                    WvfrmName = ['Untitled_',datestr(now,'yymmdd_HHMMSS'),'_',num2str(10000*rand(1),'%0.0f')];
                else
                    WvfrmName = [WaveformObj.name];
                end
                startidx = 0;
                wvdatasize = WaveformObj.length;
                if isprop(WaveformObj,'uploadstartidx') && isprop(WaveformObj,'uploadendidx') &&...
                        ~isempty(WaveformObj.uploadstartidx) && ~isempty(WaveformObj.uploadendidx)
                    startidx = WaveformObj.uploadstartidx - 1;
                    wvdatasize = WaveformObj.uploadendidx - WaveformObj.uploadstartidx + 1;
                end
                WvfrmNameStr = ['WLIS:WAV:NEW "', WvfrmName, '"'];
                WvfrmWriteStr = ['WLIS:WAV:DATA "', WvfrmName, '"',',',num2str(startidx),',',num2str(wvdatasize),...
                        ',#', num2str(length(num2str(4*wvdatasize))), num2str(4*wvdatasize)];  % float point, 4 bytes per data point
                % create a waveform in the AWG waveform list
                fprintf(obj.interfaceobj,[WvfrmNameStr,',', num2str(wvdatasize)]);
                % send waveform data to the newly created waveform
                fwrite(obj.interfaceobj,WvfrmWriteStr);
                fwrite(obj.interfaceobj,WaveformData{1}(startidx+1:startidx+wvdatasize),'float'); % awg 70k only support floating point waveform data points
                fwrite(obj.interfaceobj, 10);
            end
        case {'hp33120','agl33120','hp33220','agl33220'}
            % todo
        case {'ustc_da_v1'} % for ustc_da_v1, waveform vpp is -32768, 32768
            if WaveformObj.hw_delay
                outputDelayStep = obj.interfaceobj.outputDelayStep;
                output_delay_count = min(floor(WaveformObj.output_delay/outputDelayStep));
                hardware_delay = output_delay_count*outputDelayStep;
                software_delay = WaveformObj.output_delay - hardware_delay;
                output_delay_count = output_delay_count*ones(size(WaveformObj.output_delay));
            else
                output_delay_count = zeros(size(WaveformObj.output_delay));
                software_delay = WaveformObj.output_delay;
            end
            
            t = WaveformObj.t0:ceil(WaveformObj.t0+WaveformObj.length);
            y = WaveformObj(t);
            if WaveformObj.iq
                mzeros = obj.MixerZeros(WaveformObj.awgchnl,WaveformObj.fc);
                WaveformData = {[zeros(1,software_delay(1)),real(y),0];...
                    [zeros(1,software_delay(2)),imag(y),0]}; 
                WaveformData{1} = uint16((WaveformData{1} + mzeros(1))+32768);
                WaveformData{2} = uint16(WaveformData{2} + mzeros(2)+32768);
            else
				WaveformData = {uint16([zeros(1,software_delay),real(y),0]+32768)};
            end
            % setChnlOutputDelay before SendWave, otherwise output delay
            % will not take effect till next next Run:
            % SendWave(...); setChnlOutputDelay(...,100);
            % Run(...); % oops, delay not 100*4 ns
            % SendWave(...); setChnlOutputDelay(...,200);
            % Run(..); % now delay is 100*4 ns, not 200*4 ns,
            % 200*4 ns will be the delay amount of next Run.
            % this is a da driver bug, might be corrected in a future version. 
            if WaveformObj.iq
                obj.interfaceobj.setChnlOutputDelay(WaveformObj.awgchnl(1),output_delay_count(1));
                obj.interfaceobj.setChnlOutputDelay(WaveformObj.awgchnl(2),output_delay_count(2));
                obj.interfaceobj.SendWave(WaveformObj.awgchnl(1),WaveformData{1});
                obj.interfaceobj.SendWave(WaveformObj.awgchnl(2),WaveformData{2});
            else
                obj.interfaceobj.setChnlOutputDelay(WaveformObj.awgchnl,output_delay_count);
                obj.interfaceobj.SendWave(WaveformObj.awgchnl,WaveformData{1});
            end
        otherwise
            throw(MException('QOS_awg:unsupportedAWG','Unsupported awg.'));
    end
    
end