classdef cos < qes.waveform.waveform
    % cosine envelop
    %

% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        amp = 1
    end

    methods
        function obj = cos(ln)
            if nargin == 0
                ln = 0;
            end
            obj = obj@qes.waveform.waveform(ln);
            obj.iq = true;
        end
    end
    methods (Static = true, Hidden=true)
        function v = TimeFcn(obj,t)
            dt = t-obj.t0-obj.length/2;
            v = obj.amp*(cos(2*pi*dt/obj.length)+1)/2.*...
                (sign(dt+obj.length/2)+1)/2.*(sign(obj.length/2-dt)+1)/2;
        end
        function v = FreqFcn(obj,f)
            v = obj.amp/2.0*(obj.length/2.0*sinc(1-obj.length*f)+...
                obj.length/2.0*sinc(-1-obj.length*f)+obj.length*sinc(obj.length*f)).*...
                exp(-1j*2*pi*f*(obj.t0+obj.length/2));
        end
    end
end