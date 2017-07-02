classdef ACZ < sqc.op.physical.operator
    % adiabatic controled Z gate
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

	properties
        ln % by ln, you can change the protected property length
        
        amp
        thf
        thi
        lam2
        lam3
    end
    properties (SetAccess = private)
        padLn
        meetUpDetuneFreq
    end
    properties (SetAccess = private, GetAccess = private)
        tuneDown
    end
    methods
        function obj = ACZ(control_q, target_q, scz)
            obj = obj@sqc.op.physical.operator({control_q, target_q});
            obj.amp = scz.amp;
            obj.thf = scz.thf;
            obj.thi = scz.thi;
            obj.lam2 = scz.lam2;
            obj.lam3 = scz.lam3;
            obj.padLn = scz.padLn;
            obj.length = scz.length;
            if obj.qubits{1}.f01 > obj.qubits{2}.f01
                obj.tuneDown = true;
            else
                obj.tuneDown = false;
            end
            obj.ln = scz.length;
        end
        function set.ln(obj,val)
            obj.ln = val;
            obj.length = val;
        end
    end
	methods (Hidden = true)
        function GenWave(obj)
            obj.z_wv{1} = sqc.wv.acz(obj.length);
            obj.z_wv{1}.amp = obj.amp;
            obj.z_wv{1}.thf = obj.thf;
            obj.z_wv{1}.thi = obj.thi;
            obj.z_wv{1}.lam2 = obj.lam2;
            obj.z_wv{1}.lam3 = obj.lam3;
            
            if obj.tuneDown
                acz_q = obj.qubits{1};
                meetUp_q = obj.qubits{2};
            else
                acz_q = obj.qubits{2};
                meetUp_q = obj.qubits{1};
            end
            persistent da1
            if isempty(da1)
                da1 = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                        'name',acz_q.channels.z_pulse.instru);
            end
            obj.z_wv{1}.awg = da1;
            obj.z_wv{1}.awgchnl = [acz_q.channels.z_pulse.chnl];
			
            persistent da2
            if obj.meetUpDetuneFreq
                obj.z_wv{2} = feval(['sqc.wv.',meetUp_q.g_detune_wvTyp],obj.length);
                wvSettings = struct(meetUp_q.g_detune_wvSettings);
                fnames = fieldnames(wvSettings);
                for ii = 1:numel(fnames)
                    obj.z_wv{2}.(fnames{ii}) = wvSettings.(fnames{ii});
                end
                obj.z_wv{2}.amp = sqc.util.detune2zpa(meetUp_q,obj.meetUpDetuneFreq);
                if isempty(da2)
                    da2 = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                            'name',meetUp_q.channels.z_pulse.instru);
                end
                obj.z_wv{2}.awg = da2;
                obj.z_wv{2}.awgchnl = [meetUp_q.channels.z_pulse.chnl];
            end
        end
    end
end