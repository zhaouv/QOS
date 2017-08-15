classdef ACZ < sqc.op.physical.operator
    % adiabatic controled Z gate
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

	properties
        aczLn % length of the acz pulse, pad length and meetup longer not included
        
        amp
        thf
        thi
        lam2
        lam3
    end
    properties (SetAccess = private)
        meetUpLonger % must be private
        padLn % must be private
        meetUpDetuneFreq
        dynamicPhase
    end
    properties (SetAccess = private, GetAccess = private)
        aczQ
        meetUpQ
    end
    methods
        function obj = ACZ(control_q, target_q, scz)
            obj = obj@sqc.op.physical.operator({control_q, target_q});
            obj.amp = scz.amp;
            obj.thf = scz.thf;
            obj.thi = scz.thi;
            obj.lam2 = scz.lam2;
            obj.lam3 = scz.lam3;
            
            
            obj.meetUpLonger = scz.meetUpLonger;
            obj.padLn = cell2mat(scz.padLn);
            obj.aczLn = scz.aczLn; % must be after the setting of meetUpLonger and padLn
            if scz.aczFirstQ
                obj.aczQ = 1;
                obj.meetUpQ = 2;
            else
                obj.aczQ = 2;
                obj.meetUpQ = 1;
            end
            obj.dynamicPhase = cell2mat(scz.dynamicPhase);
        end
        function set.aczLn(obj,val)
            obj.aczLn = val;
            obj.length = val+sum(obj.padLn)+2*obj.meetUpLonger;
        end
    end
	methods (Hidden = true)
        function GenWave(obj)
            aczWv = sqc.wv.acz(obj.aczLn);
            aczWv.amp = obj.amp;
            aczWv.thf = obj.thf;
            aczWv.thi = obj.thi;
            aczWv.lam2 = obj.lam2;
            aczWv.lam3 = obj.lam3;
            padWv1 = qes.waveform.spacer(obj.padLn(1)+obj.meetUpLonger);
            padWv2 = qes.waveform.spacer(obj.padLn(2)+obj.meetUpLonger);
            obj.z_wv{1} = [padWv1, aczWv, padWv2];
            
            acz_q = obj.qubits{obj.aczQ};
            meetUp_q = obj.qubits{obj.meetUpQ};
            persistent da1
            if isempty(da1)
                da1 = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                        'name',acz_q.channels.z_pulse.instru);
            end
            obj.z_wv{1}.awg = da1;
            obj.z_wv{1}.awgchnl = [acz_q.channels.z_pulse.chnl];
			
            persistent da2
            if obj.meetUpDetuneFreq
                meetupWv = feval(['sqc.wv.',meetUp_q.g_detune_wvTyp],obj.aczLn+2*obj.meetUpLonger);
                wvSettings = struct(meetUp_q.g_detune_wvSettings);
                fnames = fieldnames(wvSettings);
                for ii = 1:numel(fnames)
                    meetupWv.(fnames{ii}) = wvSettings.(fnames{ii});
                end
                meetupWv.amp = sqc.util.detune2zpa(meetUp_q,obj.meetUpDetuneFreq);
                padWv3 = qes.waveform.spacer(obj.padLn(1));
                padWv4 = qes.waveform.spacer(obj.padLn(2));
                obj.z_wv{2} = [padWv3,meetupWv,padWv4];
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