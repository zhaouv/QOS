classdef (Abstract = true) XY_base < sqc.op.physical.operator
    % base class of XY group gates
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        amp
        f01 % expose qubit setting f01 for tunning
    end
    properties (SetAccess = private, GetAccess = private)
        phase
    end
    methods
        function obj = XY_base(qubit)
			assert(numel(qubit)==1);
            obj = obj@sqc.op.physical.operator(qubit);
            obj.f01 = obj.qubits{1}.f01;
            obj.phase = obj.qubits{1}.g_XY_phaseOffset;
        end
    end
    methods(Access = protected)
        function addPhase(obj,val)
            obj.phase = obj.phase + val;
        end
    end
    methods (Hidden = true)
        function GenWave(obj)
            obj.xy_wv{1} = feval(['sqc.wv.',obj.qubits{1}.qr_xy_wvTyp],obj.length);
            wvSettings = struct(obj.qubits{1}.qr_xy_wvSettings); % use struct() so we won't fail in case of empty
            fnames = fieldnames(wvSettings);
			for ii = 1:numel(fnames)
				obj.xy_wv{1}.(fnames{ii}) = wvSettings.(fnames{ii});
            end
            obj.xy_wv{1}.amp = obj.amp;
            if obj.qubits{1}.qr_xy_dragPulse
                obj.xy_wv{1} = qes.waveform.fcns.DRAG(obj.xy_wv{1},...
                                            obj.qubits{1}.qr_xy_dragAlpha,...
                                            obj.qubits{1}.f01,...
                                            obj.qubits{1}.f02);
            end
            persistent da
            if isempty(da) || ~isvalid(da)
                da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                        'name',obj.qubits{1}.channels.xy_i.instru);
            end
            obj.xy_wv{1}.df = (obj.f01-obj.mw_src_frequency(1))/da.samplingRate;
            obj.xy_wv{1}.awg = da;
            obj.xy_wv{1}.awgchnl = [obj.qubits{1}.channels.xy_i.chnl,obj.qubits{1}.channels.xy_q.chnl];
            obj.xy_wv{1}.phase = obj.phase;
        end
    end
end