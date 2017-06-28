classdef voltMeter < qes.hwdriver.sync.instrument
    % dc voltage meter

% Copyright 2017 Yulin Wu, USTC, China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
		range
		numAvg = 1; % number of averages
    end
	properties (SetAccess = private)
		voltage
    end
    methods
        function set.numAvg(obj,val)
            if isempty(val) || ~isnumeric(val) || ~isreal(val) ||val <= 0
                error('voltMeter:InvalidInput','Invalid numAvg value.');
            end
            obj.numAvg = ceil(val);
        end
    end
    methods (Access = private,Hidden = true)
        function obj = voltMeter(name,interfaceobj,drivertype)
            ErrMsg = '';
            if isempty(interfaceobj)
                error('voltMeter:InvalidInput',...
                    'Input ''%s'' can not be empty!',...
                    'interfaceobj');
            end
            if nargin < 3
                drivertype = [];
            end
            obj = obj@qes.hwdriver.sync.instrument(name,interfaceobj,drivertype);
            obj.InitializeInstr();
            if ~isempty(ErrMsg)
                error('voltMeter:InstSetError',[obj.name, ': %s'], ErrMsg);
            end
        end
        function InitializeInstr(obj)
			TYP = lower(obj.drivertype);
			try
				switch TYP
					case {'keysight_multimeter'}
						fwrite(obj.interfaceobj,'TRIG:SOUR BUS');
					otherwise
						error('voltMeter:unsupportedInstrument', ['Unsupported instrument: ',TYP]);
				end
			catch
				error('voltMeter:iniInstruErr', 'Setting instrument failed.');
			end
		end
    end
    methods (Static)	
		function obj = GetInstance(name,interfaceobj,drivertype)
			persistent objlst;
			if isempty(objlst)
				if nargin == 0 || isempty(name) 
					error('voltMeter:GetInstanceError',...
						'No existing instance, all input paramenters should be specified!');
				end
				if nargin > 2
					obj = qes.hwdriver.sync.voltMeter(name,interfaceobj,drivertype);
				else
					obj = qes.hwdriver.sync.voltMeter(name,interfaceobj);
				end
				objlst = obj;
				return;
			end
			nexistingobj = numel(objlst);
			ii = 1;
			while ii <= nexistingobj
				if isvalid(objlst(ii))
					if nargin == 0 || isempty(name)
						obj = objlst(ii);
						return;
					end
					if strcmp(objlst(ii).name,name) % instance exit already, return the handle
						obj = objlst(ii);
						break;
					end
				else
					objlst(ii) = [];  % remove invalid handles(handles of delete objects)
					nexistingobj = nexistingobj -1;
					ii = ii - 1;
				end
				if ii >= nexistingobj  % instance not exit, create one
					if nargin == 0 || isempty(name) 
						error('voltMeter:GetInstanceError',...
							'No existing instance, all input paramenter should be specified!');
					end
					if nargin > 2
						obj = qes.hwdriver.sync.voltMeter(name,interfaceobj,drivertype);
					else
						obj = qes.hwdriver.sync.voltMeter(name,interfaceobj);
					end
					objlst(end+1) = obj;
				end
				ii = ii + 1;
			end
		end
    end
    methods
		function set.range(obj,val)
			TYP = lower(obj.drivertype);
			try
				switch TYP
					case {'keysight_multimeter'}
                        % 100V, 10V, 1V, 0.2V, 0.02V
                        if val > 100
                            error('range exceeding maximum(100V)');
                        elseif val > 10
                            val = '100';
                        elseif val > 1
                            val  = '10';
                        elseif val > 0.2
                            val = '1';
                        elseif val > 0.02
                            val = '0.2';
                        else
                            val = '0.02';
                        end
						fwrite(obj.interfaceobj,['CONF:VOLT:DC ',val]);
%						fwrite(obj.interfaceobj,'VOLT:DC:NPLC 10');
%             			fwrite(obj.interfaceobj,'RES:NPLC 1');
%             			fwrite(obj.interfaceobj,'CONF:RES 100');
					otherwise
						error('voltMeter:unsupportedInstrument', ['Unsupported instrument: ',TYP]);
				end
			catch
				error('voltMeter:iniInstruErr', 'Setting instrument failed.');
			end
		end
		function val = get.voltage(obj)
            TYP = lower(obj.drivertype);
			try
				switch TYP
					case {'keysight_multimeter'}
						fwrite(obj.interfaceobj,['SAMP:COUN ',num2str(obj.numAvg,'%0.0f')]);
                        fwrite(obj.interfaceobj,'INIT');
                        fwrite(obj.interfaceobj,'*TRG');
                        X = query (obj.interfaceobj,'FETC?');
                        X = regexp(X,',','split');
                        val = mean(str2double(X));
					otherwise
						error('voltMeter:unsupportedInstrument', ['Unsupported instrument: ',TYP]);
				end
			catch
				error('voltMeter:iniInstruErr', 'Setting instrument failed.');
			end
		end
        
    end
	
end