classdef dcVoltage < qes.measurement.measurement
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = dcVoltage(InstrumentObject)
            if ~isa(InstrumentObject,'qes.hwdriver.sync.voltMeter') &&...
				~isa(InstrumentObject,'qes.hwdriver.async.voltMeter')
                throw(MException('QOS_dcVoltage:InvalidInput','Invalud input arguments.'));
            end
            obj = obj@qes.measurement.measurement(InstrumentObject);
            obj.timeout = 10; % default timeout 60 seconds.
        end
        
        function Run(obj)
            Run@qes.measurement.measurement(obj); % check object and its handle properties are isvalid or not
            obj.dataready = false;
            obj.data = obj.instrumentObject.voltage;
            obj.dataready = true;
        end
    end
end