classdef CZ < sqc.op.physical.operator
    % controled Z gate
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

	properties
		swapTime
		swapAmp
		swapW
		paddingLn
	end
    methods
        function obj = CZ(control_q, target_q)
            obj = obj@sqc.op.physical.operator({control_q, target_q});
            
            error('to be implemeted');
			% use sqc.op.physical.op.Detune to detune other qubits
        end
    end
	methods (Hidden = true)
        function GenWave(obj)
            obj.z_wv{1} = sqc.wv.rect_acz(obj.length,obj.qubits{1}.);
            persistent da1
            if isempty(da1)
                da1 = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                        'name',obj.qubits{1}.channels.z_pulse.instru);
            end
            obj.z_wv{1}.awg = da1;
            obj.z_wv{1}.awgchnl = [obj.qubits{1}.channels.z_pulse.chnl];
			
			obj.z_wv{2} = sqc.wv.flattop(obj.length,obj.qubits{2}.);
            persistent da2
            if isempty(da2)
                da2 = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                        'name',obj.qubits{2}.channels.z_pulse.instru);
            end
            obj.z_wv{2}.awg = da2;
            obj.z_wv{2}.awgchnl = [obj.qubits{2}.channels.z_pulse.chnl];
			
			% apply detune to other qubits
			% todo...
        end
    end
end