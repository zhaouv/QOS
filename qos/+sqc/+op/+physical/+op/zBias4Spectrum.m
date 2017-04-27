classdef zBias4Spectrum < sqc.op.physical.gate.Z_z_base
    % long z bias pulse for spectrum
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        % by 'ln', we actually actually modifies the 'operator' basic
        % property 'length', which by design is protected from user
        % modification which is resonable for most operator objects.
        ln
    end
    methods
        function obj = zBias4Spectrum(qubit)
			obj = obj@sqc.op.physical.gate.Z_z_base(qubit);
            obj.length = obj.qubits{1}.spc_driveLn+2*obj.qubits{1}.spc_zLonger;
            obj.amp = 0;
        end
        function set.ln(obj,val)
            obj.length = val;
        end
        function val = get.ln(obj)
            val = obj.length;
        end
    end
    methods (Hidden = true)
        function GenWave(obj) % Z_z_base GenWave method needs
							  % to be overwriten for this Z_z operation,
							  % for zBias4Spectrum, we use a diferent waveform
			obj.z_wv{1} = sqc.wv.rect_cos(obj.length);
            obj.z_wv{1}.amp = obj.amp;
            persistent da
            if isempty(da) || ~isvalid(da)
                da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                        'name',obj.qubits{1}.channels.z_pulse.instru);
            end
            obj.z_wv{1}.awg = da;
            obj.z_wv{1}.awgchnl = [obj.qubits{1}.channels.z_pulse.chnl];
        end
    end
end