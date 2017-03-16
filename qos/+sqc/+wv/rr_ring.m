classdef rr_ring < qes.waveform.waveform
    % resonator readout with ring

% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        amp = 1;
        gaus_w = 1e-6;
        ring_w = 1 % half of the gaussian ring pulse length, integer, minimum 1, unit: 1/sampling frequency
        ring_amp = 0
    end
    properties(SetAccess = private, GetAccess = private)
        flattopwv
        gauswv
    end
    methods
        function obj = rr_ring(ln)
            if nargin == 0
                ln = 0;
            end
            obj = obj@qes.waveform.waveform(ln);
            obj.flattopwv = sqc.wv.flattop(ln);
            obj.gauswv = sqc.wv.gaussian(obj.ring_w);
            obj.iq = true;
        end
    end
    methods (Static = true, Hidden=true)
        function v = TimeFcn(obj,t)
            t = t - obj.t0;
            obj.flattopwv.length = obj.length;
            obj.flattopwv.amp = obj.amp;
            obj.flattopwv.gaus_w = obj.gaus_w;
            if obj.ring_w < 1
                obj.gauswv.length = 1;
                obj.gauswv.amp = 0;
            else
                obj.gauswv.length = obj.ring_w;
                obj.gauswv.amp = obj.ring_amp;
            end
            v = obj.flattopwv(t)+obj.gauswv(t);
        end
        function v = FreqFcn(obj,f)
            obj.flattopwv.length = obj.length;
            obj.flattopwv.amp = obj.amp;
            obj.flattopwv.gaus_w = obj.gaus_w;
            if obj.ring_w < 1
                obj.gauswv.length = 1;
                obj.gauswv.amp = 0;
            else
                obj.gauswv.length = obj.ring_w;
                obj.gauswv.amp = obj.ring_amp;
            end
            v = (obj.flattopwv(f)+obj.ring_amp*obj.gauswv(f)).*exp(-1j*2*pi*f*obj.t0);
        end
    end
end