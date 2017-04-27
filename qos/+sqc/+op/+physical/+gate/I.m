classdef I < sqc.op.physical.operator
    % I, single qubit
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (Dependent = true)
        ln
    end
    methods
        function obj = I(qubit)
			assert(numel(qubit) == 1);
            obj = obj@sqc.op.physical.operator(qubit);
            obj.logical_op = sqc.op.logical.gate.I;
			obj.length = obj.qubits{1}.g_I_ln;
        end
        function set.ln(obj,val)
            obj.length = val;
        end
        function val = get.ln(obj)
            val = obj.length;
        end
    end
    methods (Hidden = true)
        function GenWave(obj)
            obj.xy_wv{1} = qes.waveform.spacer(obj.length);
            obj.z_wv{1} = qes.waveform.spacer(obj.length);
            persistent da_xy
            if isempty(da_xy) || ~isvalid(da_xy)
                da_xy = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                        'name',obj.qubits{1}.channels.xy_i.instru);
            end
            obj.xy_wv{1}.iq = true;
            obj.xy_wv{1}.awg = da_xy;
            obj.xy_wv{1}.awgchnl = [obj.qubits{1}.channels.xy_i.chnl,obj.qubits{1}.channels.xy_q.chnl];
            persistent da_z
            if isempty(da_z) || ~isvalid(da_z)
                da_z = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                    'name',obj.qubits{1}.channels.z_pulse.instru);
            end
            obj.z_wv{1}.awg = da_z;
            obj.z_wv{1}.awgchnl = [obj.qubits{1}.channels.z_pulse.chnl];
        end
    end
end