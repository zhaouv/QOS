classdef awgZeroCalibrator < qes.measurement.measurement
	% measure awg zero offset
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = private, GetAccess = private)
        awg
		chnl
        volt
    end
    methods
        function obj = awgZeroCalibrator(awgObj,awgchnls,voltM)
			if ~isa(awgObj,'qes.hwdriver.sync.awg') ||...
				~isa(awgObj,'qes.hwdriver.async.awg') ||...
                ~isa(voltM,'qes.measurement.dcVoltage') ||...
				numel(awgchnls) ~= 1
				throw(MException('QOS_iqMixerCalibrator:InvalidInput','Invalud input arguments.'));
			end
            obj = obj@qes.measurement.measurement([]);
			obj.awg = awgObj;
			obj.chnl = awgchnls(1);
            obj.volt = voltM;
            obj.numericscalardata = true;
        end
        function Run(obj)
			Run@qes.measurement.measurement(obj);
            I = qes.waveform.dc(obj.pulse_ln);
            I.awg = obj.awg;
            I.awgchnl = obj.chnl;
            p1 = qes.expParam(I,'dcval');
            p1.callbacks = {@(x_) obj.awg.StopContinousRun(), @(x_) I.SendWave(),...
					@(x_) obj.awg.awg.StartContinousRun()};
            f = qes.expFcn(p1,obj.volt);
            x = 0;
            precision = obj.awg.vpp/10;
            stopPrecision = obj.awg.vpp/1e5;
            while precision <= stopPrecision
                l = f(x-precision);
                c = f(x);
                r = f(x+precision);
                dx = precision*qes.util.minPos(l, c, r);
                x = x+dx;
            end
			obj.awg.StopContinousRun();
            obj.data = x;
        end
    end
end