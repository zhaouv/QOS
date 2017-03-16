classdef X12 < sqc.op.physical.operator
    % pi pulse between |1> and |2>
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        amp % expose qubit setting g_X_amp for tunning
        f02 % expose qubit setting f02 for tunning
    end
    methods
        function obj = X12(qubit)
			assert(numel(qubit) == 1);
            obj = obj@sqc.op.physical.operator(qubit);
			obj.length = obj.qubits{1}.g_XY_ln;
            obj.amp = obj.qubits{1}.g_X12_amp;
            obj.f01 = obj.qubits{1}.f02;
        end
    end
    methods (Hidden = true)
        function GenWave(obj)
            obj.xy_wv{1} = feval(['sqc.wv.',obj.qubits{1}.qr_xy_pulseTyp],obj.length);
            wvSettings = obj.qubits{1}.qr_xy_wvSettings;
            fnames = fieldnames(wvSettings);
			for ii = 1:numel(fnames)
				obj.xy_wv{1}.(fnames{ii}) = wvSettings.(fnames{ii});
			end
            obj.xy_wv{1}.amp = obj.amp;
            obj.xy_wv{1}.phase = 0;
            persistent da
            if isempty(da)
                da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                        'name',obj.qubits{1}.channels.xy_i.instru);
            end
            obj.xy_wv{1}.df = (obj.f02 - obj.qubits{1}.f01 - obj.mw_src_frequency(1))/da.sampling_rate;
            obj.xy_wv{1}.awg = da;
            obj.xy_wv{1}.awgchnl = [obj.qubits{1}.channels.xy_i.chnl,obj.qubits{1}.channels.xy_q.chnl];
        end
    end
end