classdef mwDrive4Spectrum < sqc.op.physical.operator
    % mw drive for spectrum, a long mw driving pulse with very weak amplitude
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
    
    properties
        amp % expose qubit setting spc_driveAmp for tunning
    end
    methods
        function obj = mwDrive4Spectrum(qubit)
			assert(numel(qubit)==1);
            obj = obj@sqc.op.physical.operator(qubit);
            obj.mw_src_power = obj.qubits{1}.qr_xy_uSrcPower;
            obj.amp = obj.qubits{1}.spc_driveAmp;
			obj.length = obj.qubits{1}.spc_driveLn++2*obj.qubits{1}.spc_zLonger;
        end
    end
    methods (Hidden = true)
        function GenWave(obj)
            obj.xy_wv{1} = sqc.wv.rect_cos(obj.qubits{1}.spc_driveLn);
            obj.xy_wv{1}.amp = obj.amp;
            obj.xy_wv{1}.rise_time = obj.qubits{1}.spc_driveRise;
			persistent da
            if isempty(da) || ~isvalid(da)
				da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                    'name',obj.qubits{1}.channels.xy_i.instru);
			end
            obj.xy_wv{1}.df = obj.qubits{1}.spc_sbFreq/da.samplingRate;
			obj.xy_wv{1}.phase = 0;
			S = qes.waveform.spacer(obj.qubits{1}.spc_zLonger);
			obj.xy_wv{1} = [S,obj.xy_wv{1},S];
            obj.xy_wv{1}.awg = da;
            obj.xy_wv{1}.awgchnl = [obj.qubits{1}.channels.xy_i.chnl,obj.qubits{1}.channels.xy_q.chnl];
        end
    end
end