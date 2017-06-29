classdef spectrumAnalyzer < qes.hwdriver.sync.instrument
    % spectrumAnalyzer source driver, basic.
    % basic properties and functions of a spectrumAnalyzer source
    % currently only support Keysight Technologies, N9030B
    
    % Copyright 2016 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
    % mail4ywu@gmail.com/mail4ywu@icloud.com
    
    properties
        startfreq % Hz
        stopfreq % Hz
        bandwidth % Hz
        reflevel = 0 % reference level, dBm
        numpts % number of points
        avgnum = 1 % number of averge times, set to 1 to disable average
        trigmod = 1  %Angilent 1/2/3/4 for 'IMM'/'VID'/'LINE'/'EXT'
        %TEK 1/4 'INPUT\EXTERNAL'
        extref = 1 % 1/2 for 'INT'/'EXT' 10MHz reference
        on % true/false, set/query operating status
        
        
    end
    
    methods (Access = private)
        function obj = spectrumAnalyzer(name,interfaceobj,drivertype)
            if isempty(interfaceobj)
                throw(MException('QOS_spectrumAnalyzer:InvalidInput',...
                    sprintf('Input ''%s'' can not be empty!','interfaceobj')));
            end
            set(interfaceobj,'Timeout',10);
            if nargin < 3
                drivertype = [];
            end
            obj = obj@qes.hwdriver.sync.instrument(name,interfaceobj,drivertype);
            ErrMsg = obj.InitializeInstr();
            if ~isempty(ErrMsg)
                throw(MException('QOS_spectrumAnalyzer:InstSetError',sprintf('%s: %s',obj.name, ErrMsg)));
            end
            TYP = lower(obj.drivertype);
            switch TYP
                case{'agilent_N9030B'}
                fprintf(interfaceobj,':POW:RF:ATT 20dB');
                fprintf(interfaceobj,':INIT:CONT ON');
            %%% uiinfoobj to be implemented
            case{'tek_rsa607a'}
            end
        end
        [varargout] = InitializeInstr(obj)
    end
    methods (Static)
        obj = GetInstance(name,interfaceobj,drivertype)
    end
    methods
        function val = avg_amp(obj)
            % Gets the average amplitude of the entire trace
            
            % the following lines are necessary, without what one got is
            % history: avg_amp returns data even if the instrument is not
            % running(waiting for trigger for example).
            TYP = lower(obj.drivertype);
            switch TYP
                case{'agilent_N9030B'}
                fprintf(obj.interfaceobj,'*CLS');
                fprintf(obj.interfaceobj,'*ESE 1');
                fprintf(obj.interfaceobj,':INIT:IMM');
                fprintf(obj.interfaceobj,'*OPC');
                while ~str2double(query(obj.interfaceobj,'*STB?'))
                    pause(0.005);
                end

                val = str2double(query(obj.interfaceobj, ':TRAC:MATH:MEAN? TRACE1'));
            case{'tek_rsa607a'}
                get_trace(obj);
                val = str2double(peak_amp(obj));
            end
        end
        
        function val = peak_amp(obj)
            TYP = lower(obj.drivertype);
            switch TYP
                case{'agilent_N9030B'}
                    % Gets the current amplitude from the peak detector
                    val = num2str(query(obj.interfaceobj, ':CALC:MARK:Y?'));
                case{'tek_rsa607a'}
                    
                    fprintf(obj.interfaceobj, 'CALCULATE:MARKER:ADD');
                    fprintf(obj.interfaceobj, 'CALCULATE:SPECTRUM:MARKER1:MAXIMUM');
                    val = num2str(query(obj.interfaceobj,'CALCulate:SPECtrum:MARKer1:Y?'));
                    fprintf(obj.interfaceobj, 'CALCULATE:MARKER:DELETE');
            end
        end
        
        function val = peak_freq(obj)
            TYP = lower(obj.drivertype);
            switch TYP
                case{'agilent_N9030B'}
                    % Gets the current frequency from the peak detector
                    val = num2str(query(obj.interfaceobj, ':CALC:MARK:X?'));
                case{'tek_rsa607a'}
                    fprintf(obj.interfaceobj, 'CALCULATE:MARKER:ADD');
                    
                    fprintf(obj.interfaceobj, 'CALCULATE:SPECTRUM:MARKER1:MAXIMUM');
                    val = num2str(query(obj.interfaceobj,'CALCulate:SPECtrum:MARKer1:X?'));
            end
        end
        function val = get_trace(obj)
            % Gets the current amplitude from the peak detector
            TYP = lower(obj.drivertype);
            switch TYP
                case{'agilent_N9030B'}
                    fprintf(obj.interfaceobj,'*CLS');
                    fprintf(obj.interfaceobj,'*ESE 1');
                    fprintf(obj.interfaceobj,':INIT:IMM');
                    fprintf(obj.interfaceobj,'*OPC');
                    while ~str2double(query(obj.interfaceobj,'*STB?'))
                        pause(0.005);
                    end
                    
                    fprintf(obj.interfaceobj,':FORM ASC,8');
                    fprintf(obj.interfaceobj,':FORM:BORD NORM'); % big endian
                    resp = query(obj.interfaceobj,':TRAC? TRACE1');
                    val = str2double(strsplit(resp,','));
                    
                case{'tek_rsa607a'}
                    fprintf(obj.interfaceobj,'*CLS');
                    fprintf(obj.interfaceobj,'*ESE 1');
                    
                    fprintf(obj.interfaceobj, 'display:general:measview:new spectrum');
                    
                    fprintf(obj.interfaceobj,'initiate:immediate');
                    response=query(obj.interfaceobj,'*OPC?');
                    
%                     while ~str2double(query(obj.interfaceobj,'*STB?'))
%                         pause(0.05);
%                     end
%                     fprintf(obj.interfaceobj,'DISPLAY:SPECTRUM:FREQUENCY:AUTO');
%                     fprintf(obj.interfaceobj,'DISPLAY:SPECTRUM:Y:SCALE:AUTO');
                    
                    
                    fprintf(obj.interfaceobj,'FETCH:SPECTRUM:TRACE1?');
                    val = binblockread(obj.interfaceobj,'single');
                    response=query(obj.interfaceobj,'*OPC?');
                    
            end
        end
        
        function set.avgnum(obj,val)
            TYP = lower(obj.drivertype);
            switch TYP
                case{'agilent_N9030B'}
                    if isempty(val) || val <= 0 || ceil(val) ~=val
                        throw(MException('QOS_spectrumAnalyzer:SetAverage','average number value should be positive integer.'));
                    end
                    obj.avgnum = val;
                    fprintf(obj.interfaceobj,[':AVER:COUN ', num2str(val,'%0.0f')]);
                    if val > 1
                        fprintf(obj.interfaceobj,':AVER:TYPE LOG'); % LOG/MAX/MIN/RMS
                        fprintf(obj.interfaceobj,':AVER ON');
                    else
                        fprintf(obj.interfaceobj,':AVER OFF');
                    end
                case{'tek_rsa607a'}
                    if isempty(val) || val <= 0 || ceil(val) ~=val
                        throw(MException('QOS_spectrumAnalyzer:SetAverage','average number value should be positive integer.'));
                    end
                    obj.avgnum = val;
                    if val > 1
                        fprintf(obj.interfaceobj,'TRACe1:SPECtrum:FUNCtion AVERage');
                        fprintf(obj.interfaceobj,['TRACe1:SPECtrum:AVERage:COUNt ' num2str(val)]);
                    else
                        fprintf(obj.interfaceobj,'TRACe1:SPECtrum:AVERage:RESet');
                        fprintf(obj.interfaceobj,'TRACe1:SPECtrum:FUNCtion NONE');
                    end
            end
        end
        
        function val = get.avgnum(obj)
            TYP = lower(obj.drivertype);
            switch TYP
                case{'agilent_N9030B'}
                    val = str2double(query(obj.interfaceobj,':AVER:COUN?'));
                case{'tek_rsa607a'}
                    val = str2double(query(obj.interfaceobj,'TRACe1:SPECtrum:AVERage:COUNt?'));
            end
        end
        
        function set.startfreq(obj,val)
            TYP = lower(obj.drivertype);
            switch TYP
                case{'agilent_N9030B'}
                    if isempty(val) || ~isnumeric(val) || ~isreal(val) || val < 0
                        throw(MException('QOS_spectrumAnalyzer:SetError','Invalid frequency value.'));
                    end
                    if val < 0 || val > 8.4e9 %  Keysight Technologies, N9030B
                        warning('spectrumAnalyzer:OutOfLimit','Frequency value out of limits.');
                        return;
                    end
                    fprintf(obj.interfaceobj,[':FREQ:STAR ', num2str(val/1e6,'%0.6f'),'MHz']);
                case{'tek_rsa607a'}
                    if isempty(val) || ~isnumeric(val) || ~isreal(val) || val < 0
                        throw(MException('QOS_spectrumAnalyzer:SetError','Invalid frequency value.'));
                    end
                    if val < 0 || val > 7.5e9 %  Keysight Technologies, N9030B
                        warning('spectrumAnalyzer:OutOfLimit','Frequency value out of limits.');
                        return;
                    end
                    fprintf(obj.interfaceobj,['spectrum:frequency:start ',num2str(val/1e6,'%0.6f'),'MHz']);
            end
        end
        
        function val = get.startfreq(obj)
            TYP = lower(obj.drivertype);
            switch TYP
                case{'agilent_N9030B'}
                    val = str2double(query(obj.interfaceobj,':FREQ:STAR?'));
                case{'tek_rsa607a'}
                    val = str2double(query(obj.interfaceobj,'spectrum:frequency:start?'));
            end
        end
        
        function set.stopfreq(obj,val)
            TYP = lower(obj.drivertype);
            switch TYP
                case{'agilent_N9030B'}
                    if isempty(val) || ~isnumeric(val) || ~isreal(val) || val <= 0
                        throw(MException('QOS_spectrumAnalyzer:SetError','Invalid frequency value.'));
                    end
                    if val < 3 || val > 8.4e9 %  Keysight Technologies, N9030B
                        warning('spectrumAnalyzer:OutOfLimit','Frequency value out of limits.');
                        return;
                    end
                    fprintf(obj.interfaceobj,[':FREQ:STOP ', num2str(val/1e6,'%0.6f'),'MHz']);
                    
                case{'tek_rsa607a'}
                    if isempty(val) || ~isnumeric(val) || ~isreal(val) || val <= 0
                        throw(MException('QOS_spectrumAnalyzer:SetError','Invalid frequency value.'));
                    end
                    if val < 3 || val > 7.5e9 % TEK RSA607A
                        warning('spectrumAnalyzer:OutOfLimit','Frequency value out of limits.');
                        return;
                    end
                    fprintf(obj.interfaceobj,['spectrum:frequency:stop ',num2str(val/1e6,'%0.6f'),'MHz']);
            end
            
        end
        
        function val = get.stopfreq(obj)
            TYP = lower(obj.drivertype);
            switch TYP
                case{'agilent_N9030B'}
                    val = str2double(query(obj.interfaceobj,':FREQ:STOP?'));
                case{'tek_rsa607a'}
                    val = str2double(query(obj.interfaceobj,'spectrum:frequency:stop?'));
            end
        end
        
        function set.trigmod(obj,val)
            TYP = lower(obj.drivertype);
            switch TYP
                case{'agilent_N9030B'}
                    switch val
                        case 1
                            fprintf(obj.interfaceobj,':TRIG:SOUR IMM');
                        case 2
                            fprintf(obj.interfaceobj,':TRIG:SOUR VID');
                        case 3
                            fprintf(obj.interfaceobj,':TRIG:SOUR LINE');
                        case 4
                            fprintf(obj.interfaceobj,':TRIG:SOUR EXT');
                        otherwise
                            throw(MException('QOS_spectrumAnalyzer:SetTrigMode','Invalid trig mode.'));
                    end
                case{'tek_rsa607a'}
                    switch val
                        case 0
                            fprintf(obj.interfaceobj,'TRIGGER:SEQUENCE:STATUS OFF');
                        case 1
                            fprintf(obj.interfaceobj,'TRIGGER:SEQUENCE:STATUS ON');
                            fprintf(obj.interfaceobj,'TRIGGER:EVENT:SOURCE INPUT');
                        case 4
                            fprintf(obj.interfaceobj,'TRIGGER:SEQUENCE:STATUS ON');
                            fprintf(obj.interfaceobj,'TRIGGER:EVENT:SOURCE EXTERNAL');
                    end
            end
        end
        
        function val = get.trigmod(obj)
            TYP = lower(obj.drivertype);
            switch TYP
                case{'agilent_N9030B'}
                    resp = query(obj.interfaceobj,':TRIG:SOUR?');
                    resp((resp == 10) | (resp == 13)) = [];
                    switch resp
                        case 'IMM'
                            val = 1;
                        case 'VID'
                            val = 2;
                        case 'LINE'
                            val = 3;
                        case {'EXT1','EXT2'}
                            val = 4;
                        otherwise
                            throw(MException('QOS_spectrumAnalyzer:GetTrigModMode','query instrument failed.'));
                    end
                    
                case{'tek_rsa607a'}
                    resp = num2str(query(obj.interfaceobj,'TRIGGER:EVENT:SOURCE?'));
                    switch resp
                        case 'INT'
                            val = 1;
                        case 'EXT'
                            val = 4;
                    end
            end
        end
        
        function set.extref(obj,val)
            TYP = lower(obj.drivertype);
            switch TYP
                case{'agilent_N9030B'}
                    switch val
                        case 1
                            fprintf(obj.interfaceobj,':SENS:ROSC:SOUR INT');
                        case 2
                            fprintf(obj.interfaceobj,':SENS:ROSC:SOUR EXT');
                        otherwise
                            throw(MException('QOS_spectrumAnalyzer:SetExtRefMode','Invalid trig mode.'));
                    end
                case{'tek_rsa607a'}
                    switch val
                        case 1
                            fprintf(obj.interfaceobj,'SENSE:ROSCILLATOR:SOURCE INTernal');
                        case 2
                            fprintf(obj.interfaceobj,'SENSE:ROSCILLATOR:SOURCE EXTernal');
                        otherwise
                            throw(MException('QOS_spectrumAnalyzer:SetExtRefMode','Invalid trig mode.'));
                    end
                    
            end
        end
        
        function val = get.extref(obj)
            TYP = lower(obj.drivertype);
            switch TYP
                case{'agilent_N9030B'}
                    resp = query(obj.interfaceobj,'SENSE:ROSCILLATOR:SOURCE?');
                    resp((resp == 10) | (resp == 13)) = [];
                    switch resp
                        case 'INT'
                            val = 1;
                        case 'EXT'
                            val = 2;
                        otherwise
                            throw(MException('QOS_spectrumAnalyzer:GetExtRefMode','query instrument failed.'));
                    end
                case{'tek_rsa607a'}
                    resp = query(obj.interfaceobj,':SENS:ROSC:SOUR?');
                    switch resp
                        case 'INT'
                            val = 1;
                        case 'EXT'
                            val = 2;
                        otherwise
                            throw(MException('QOS_spectrumAnalyzer:GetExtRefMode','query instrument failed.'));
                    end
            end
            
        end
        
        function set.reflevel(obj,val)
            TYP = lower(obj.drivertype);
            switch TYP
                case{'agilent_N9030B'}
                    if isempty(val) || ~isnumeric(val) || ~isreal(val) || val < -150 || val > 30
                        throw(MException('QOS_spectrumAnalyzer:SetError','Invalid reference level value.'));
                    end
                    fprintf(obj.interfaceobj,['DISP:WIND:TRAC:Y:RLEV ', num2str(val, '%0.1f'),'dBm']);
                    
                case{'tek_rsa607a'}
                    if isempty(val) || ~isnumeric(val) || ~isreal(val) || val < -150 || val > 30
                        throw(MException('QOS_spectrumAnalyzer:SetError','Invalid reference level value.'));
                    end
                    fprintf(obj.interfaceobj,['DISPLAY:SPECTRUM:Y:SCALE:OFFSET ', num2str(val, '%0.1f'),'dBm']);
                    
                    
            end
        end
        
        function val = get.reflevel(obj)
            val = str2double(query(obj.interfaceobj,'DISPLAY:SPECTRUM:Y:SCALE:OFFSET?'));
        end
        
        function set.bandwidth(obj,val)
            TYP = lower(obj.drivertype);
            switch TYP
                case{'agilent_N9030B'}
                    if isempty(val) || ~isnumeric(val) || ~isreal(val) || val <= 0
                        throw(MException('QOS_spectrumAnalyzer:SetError','Invalid bandwith value.'));
                    elseif val > 8e6 %  Keysight Technologies, N9030B
                        warning('spectrumAnalyzer:SetError','bandwith value exceeds maximum.');
                        val = 8e6;
                    end
                    fprintf(obj.interfaceobj,[':BAND ', num2str(val/1e6, '%0.6f'),'MHz']);
                    
                case{'tek_rsa607a'}
                    if isempty(val) || ~isnumeric(val) || ~isreal(val) || val <= 0
                        throw(MException('QOS_spectrumAnalyzer:SetError','Invalid bandwith value.'));
                    elseif val > 8e6
                        warning('spectrumAnalyzer:SetError','bandwith value exceeds maximum.');
                        val = 8e6;
                    end
                    fprintf(obj.interfaceobj,['SENSE:SPECTRUM:BANDWIDTH:RESOLUTION ',num2str(val)]);
            end
        end
        
        function val = get.bandwidth(obj)
            TYP = lower(obj.drivertype);
            switch TYP
                case{'agilent_N9030B'}
                    val = str2double(query(obj.interfaceobj,':BAND?'));
                    
                case{'tek_rsa607a'}
                    val = str2double(query(obj.interfaceobj,'SENSE:SPECTRUM:BANDWIDTH:RESOLUTION?'));
            end
        end
        
        function set.numpts(obj,val)
            TYP = lower(obj.drivertype);
            switch TYP
                case{'agilent_N9030B'}
                    if isempty(val) || val <= 0 || ceil(val) ~=val
                        throw(MException('QOS_spectrumAnalyzer:SetNumPts','numpts value should be positive integer.'));
                    end
                    fprintf(obj.interfaceobj,[':SWE:POIN ', num2str(val, '%0.0f')]);
                case{'tek_rsa607a'}
                    if isempty(val) || val <= 0 || ceil(val) ~=val
                        throw(MException('QOS_spectrumAnalyzer:SetNumPts','numpts value should be positive integer.'));
                    end
                    if val~=801 && val~=2401 && val~=4001 && val~=8001 && val~=10401 && val~=16001 && val~=32001 && val~=64001
                        throw(MException('QOS_spectrumAnalyzer:SetNumPts','numpts value should be one of {801,2401,4001,8001,10401,16001,32001,64001}.'));
                    end
                    fprintf(obj.interfaceobj,['SENSE:SPECTRUM:POINTS:COUNT ','p',num2str(val)]);
            end
        end
        
        function val = get.numpts(obj)
            TYP = lower(obj.drivertype);
            switch TYP
                case{'agilent_N9030B'}
                    val = str2double(query(obj.interfaceobj,':SWE:POIN?'));
                    
                case{'tek_rsa607a'}
                    points=(query(obj.interfaceobj,'SENSE:SPECTRUM:POINTS:COUNT?'));
                    val=str2double(points(2:end));
            end
        end
        
        function set.on(obj,val)
            if isempty(val)
                throw(MException('QOS_spectrumAnalyzer:SetOnOff', 'value of ''on'' must be a bolean.'));
            end
            if ~islogical(val)
                if val == 0 || val == 1
                    val = logical(val);
                else
                    throw(MException('QOS_spectrumAnalyzer:SetOnOff', 'value of ''on'' must be a bolean.'));
                end
            end
            if val
                fprintf(obj.interfaceobj,'*CLS');
                fprintf(obj.interfaceobj,'*ESE 1');
                fprintf(obj.interfaceobj,'*OPC');
            else
                throw(MException('QOS_spectrumAnalyzer:SetOnOff', 'off not implemeted.'));
            end
            obj.on = val;
        end
        function val = get.on(obj)
            if logical(str2double(query(obj.interfaceobj,'*OPC?')))
                val = true;
            else
                val = false;
            end
        end
        function On(obj)
            % set on, this method is introduced for functional
            % programming.
            obj.on = true;
        end
        function Off(obj)
            % set off, this method is introduced for functional
            % programming.
            obj.on = false;
        end
        
    end
end