classdef (Sealed = true) arithmetic < qes.waveform.waveform
    % Implements waveform object arithmetics.
    % arithmetic is not intended for direct instanciation:
    % a arithmetic object is automatically created when performing Waveform
    % arithmetics (+,-,*,/), do not directly create a arithmetic classe
    % object.
    % example:
    % Wv = (Wv1/2+Wv2)*Wv3 - 0.6*Wv4^3
    %
    % arithmetic is an IQ waveform if any of its constituent waveform is an IQ waveform

% Copyright 2015 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    
    properties (SetAccess = private,GetAccess = private)
		waveform1
        waveform2
    end
    properties (SetAccess = immutable, GetAccess = private)
		optype % 1/2/3/4: addition/subtraction/multiplication/division
    end
    
    methods
        function obj = arithmetic(OpType,waveform1,waveform2)
            % checking removed for speed
%             OpType = round(OpType);
%             if OpType <1 || OpType > 4
%                 error('arithmetic:invalidinput',...
%                 'OpType can only be 1,2,3,4');
%             end
            waveform1 = copy(waveform1); % make a copy is important
            waveform2 = copy(waveform2); % make a copy is important
            t = [waveform1.t0,waveform1.t0+waveform1.length,waveform2.t0,waveform2.t0+waveform2.length];
            ln = max(t) - min(t);
            obj = obj@qes.waveform.waveform(ln);
            obj.waveform1 = waveform1;
            obj.waveform2 = waveform2;
            
            obj.t0 = min(t);
            obj.waveform1.t0 = obj.waveform1.t0 - obj.t0;
            obj.waveform2.t0 = obj.waveform2.t0 - obj.t0; 

            obj.optype = OpType;
            
            if ~isempty(obj.waveform1.fc) && ~isempty(obj.waveform2.fc)...
                    && obj.waveform1.fc ~= obj.waveform2.fc
				throw(MException('QOS_waveform:propMisMatch',...
					'do arithmetic between two iq waveforms with different carrier frequency(fc) is not posibble.'));
			end
            
            if obj.waveform1.iq || obj.waveform2.iq
                obj.df = 0;
                obj.fc = unique([obj.waveform1.fc,obj.waveform2.fc]);
            end
            if ~isempty(obj.waveform1.awg)
                obj.awg = obj.waveform1.awg;
            elseif ~isempty(obj.waveform1.awg)
                obj.awg = obj.waveform1.awg;
            end
            if ~isempty(obj.waveform1.awgchnl) &&...
                    numel(obj.waveform2.awgchnl) <= numel(obj.waveform1.awgchnl)
                obj.awgchnl = obj.waveform1.awgchnl;
            elseif ~isempty(obj.waveform2.awgchnl)
                obj.awgchnl = oobj.waveform2.awgchnl;
            end
        end
%         function newobj = deepcopy(obj)
%             newobj = deepcopy@qes.waveform.waveform(obj);
%             if isa(newobj, 'qes.waveform.arithmetic')
%                 newobj.waveform1 = copy(obj.waveform1); % here deep copy is not used to avoid possible looping
%             else
%                 newobj.waveform1 = deepcopy(obj.waveform1);
%             end
%             qes.qHandle.SetId(newobj.waveform1); % we need a nwe id
%             if isa(newobj, 'qes.waveform.arithmetic')
%                 newobj.waveform2 = copy(obj.waveform2); % here deep copy is not used to avoid possible looping
%             else
%                 newobj.waveform2 = deepcopy(obj.waveform2);
%             end
%             qes.qHandle.SetId(newobj.waveform2);
%         end
    end
	methods (Access = protected)
		function newobj = copyElement(obj)
            newobj = copyElement@qes.waveform.waveform(obj);
            newobj.waveform1 = copy(newobj.waveform1);
            newobj.waveform2 = copy(newobj.waveform2);
			% newobj = qes.waveform.arithmetic(obj.optype,obj.waveform1,obj.waveform2);
		end
	end
    methods (Static = true, Hidden=true)
        function v = TimeFcn(obj,t)
            t = t-obj.t0;
            if isempty(obj.waveform1.df) % no frequency mixing
                v1 = obj.waveform1.TimeFcn(obj.waveform1,t);
            else
                v1 = exp(2j*pi*obj.waveform1.df*t-1j*obj.waveform1.phase)...
                    .*obj.waveform1.TimeFcn(obj.waveform1,t);
            end
            if isempty(obj.waveform2.df) % no frequency mixing
                v2 = obj.waveform2.TimeFcn(obj.waveform2,t);
            else
                v2 = exp(2j*pi*obj.waveform2.df*t-1j*obj.waveform2.phase)...
                    .*obj.waveform2.TimeFcn(obj.waveform2,t);
            end
            switch obj.optype
                case 1
                    v = v1+v2;
                case 2
                    v = v1-v2;
                case 3
                    v = v1.*v2;
                case 4
                    v = v1./v2;
            end
        end
        function v = FreqFcn(obj,f)
            if isempty(obj.waveform1.df) % no frequency mixing
                v1 = obj.waveform1.FreqFcn(obj.waveform1,f);
            else
                v1 = exp(-1j*obj.waveform1.phase)*obj.waveform1.FreqFcn(obj.waveform1,f-obj.waveform1.df);
            end
            if isempty(obj.waveform2.df) % no frequency mixing
                v2 = obj.waveform2.FreqFcn(obj.waveform2,f);
            else
                v2 = exp(-1j*obj.waveform2.phase)*obj.waveform2.FreqFcn(obj.waveform2,f-obj.waveform2.df);
            end
            switch obj.optype
                case 1
                    v = exp(-1j*2*pi*f*obj.t0).*(v1+v2);
                case 2
                    v = exp(-1j*2*pi*f*obj.t0).*(v1-v2);
                case {3, 4}
                    v = qes.waveform.fcns.FFT(obj,f);
            end
        end
    end
end