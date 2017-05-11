classdef (Abstract = true) Z_z_base < sqc.op.physical.operator
    % base class for z gates implement by using the z line
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        % zpulse_amp % expose qubit setting g_Z<?>_z_amp for tunning
        amp
    end
    methods
        function obj = Z_z_base(qubit)
			assert(numel(qubit)==1);
            obj = obj@sqc.op.physical.operator(qubit);
        end
    end
    methods (Hidden = true)
        function GenWave(obj)
            obj.z_wv{1} = feval(['sqc.wv.',obj.qubits{1}.qr_z_wvTyp],obj.length);
            wvSettings = struct(obj.qubits{1}.qr_z_wvSettings); % use struct() so we won't fail in case of empty
			fnames = fieldnames(wvSettings);
			for ii = 1:numel(fnames)
				obj.z_wv{1}.(fnames{ii}) = wvSettings.(fnames{ii});
			end
            obj.z_wv{1}.amp = obj.zpulse_amp;
            
            persistent da
            if isempty(da)
                da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                        'name',obj.qubits{1}.channels.z_pulse.instru);
            end
            obj.z_wv{1}.awg = da;
            obj.z_wv{1}.awgchnl = [obj.qubits{1}.channels.z_pulse.chnl];
        end
    end
end