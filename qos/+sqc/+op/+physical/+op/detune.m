classdef detune < sqc.op.physical.gate.Z_z_base
    % detune pulse
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
	
	properties
		ln=0 % length
		df=0 % detune amplitude
	end
    methods
        function obj = detune(qubit)
            obj = obj@sqc.op.physical.gate.Z_z_base(qubit);
        end
		function set.ln(obj,ln)
			obj.ln = ln;
			obj.length = ln;
		end
    end
	methods (Hidden = true)
        function GenWave(obj)
            obj.z_wv{1} = feval(['sqc.wv.',obj.qubits{1}.g_detune_wvTyp],obj.length);          
			wvSettings = struct(obj.qubits{1}.g_detune_wvSettings); % use struct() so we won't fail in case of empty
			fnames = fieldnames(wvSettings);
			for ii = 1:numel(fnames)
				obj.z_wv{1}.(fnames{ii}) = wvSettings.(fnames{ii});
            end
            if false  % temperory
%             if ~isempty(obj.qubits{1}.zpls_amp2f01Df)
%                 p = obj.qubits{1}.zpls_amp2f01Df;
%                 p(end) = p(end) - obj.df/obj.qubits{1}.zpls_amp2df_freqUnit;
%                 r = roots(p);
%                 r = sort(r(isreal(r)));
%                 if isempty(r) %
%                     throw(MException('QOS_op:illegalzplsamp2f01',...
%                         sprintf('zpls_amp2f01Df setting for qubit %s has no root for the required detunning %0.2f MHz.',...
%                         obj.qubits{1}.name, obj.df/1e6)));
%     %				throw(MException('QOS_op_illegalzplsamp2f01',...
%     %					sprintf('zpls_amp2f01Df setting for qubit %s is not a real polynomial of degree 1.',...
%     %					obj.qubits{1}.name)));
%                 end
%                 [~,idx] = min(abs(r));
%                 obj.z_wv{1}.amp = r(idx);
            else
                if obj.df
                     throw(MException('QOS_op:zplsamp2f01NotSet',...
                        sprintf('zpls_amp2f01Df setting for qubit %s not set yet, can not generate non zero detuning pulse.',...
                        obj.qubits{1}.name, obj.df/1e6)));
                else
                    obj.z_wv{1}.amp = 0;
                end
            end
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