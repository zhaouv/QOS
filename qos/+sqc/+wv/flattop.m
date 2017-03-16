classdef (Sealed = true) flattop < qes.waveform.waveform
    % A rectangular pulse convolved(multiplication in frequency domain) with a gaussian to have smooth rise and
    % fall.

% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties 
        amp = 1
        % rise and fall edges are integrals of gaussian(error function) with FWHM=edge_w/2
        % default, a very small value produces a shart rectangular pattern
        gaus_w = 1e-6; % float, half of the gaussian pulse length, unit: 1/sampling frequency
        overshoot = 0
        overshoot_w = 1; % float, half of the gaussian pulse length, unit: 1/sampling frequency
    end
    methods
        function obj = flattop(ln)
            if nargin == 0
                ln = 0;
            end
            obj = obj@qes.waveform.waveform(ln);
        end
        function set.gaus_w(obj,val)
            if val <= 0
                error('flattop:invalidinput','gaussian width should be positive.');
            end
            obj.gaus_w = val;
        end
        function set.overshoot_w(obj,val)
            if val <= 0
                error('flattop:invalidinput','overshoot width should be positive.');
            end
            obj.overshoot_w = val;
        end
    end
    methods (Static = true, Hidden=true)
        function v = TimeFcn(obj,t)     
            a = 2*sqrt(log(2))/obj.gaus_w;
            o_amp = 2*sqrt(log(2)/pi)/obj.overshoot_w;  % area == 1
            sigma = 0.4246*obj.overshoot_w;
            overshoot_amp = obj.overshoot*sign(obj.amp)*o_amp;
            tmin = obj.t0;
            tmax = obj.t0+obj.length;
            v = obj.amp*(erf(a*(tmax-t))-erf(a*(tmin-t)))/2 +...
                overshoot_amp*exp(-(t-tmin).^2/(2*sigma^2))+...
                overshoot_amp*exp(-(t-tmax).^2/(2*sigma^2));
        end
        function v = FreqFcn(obj,f)
%             v1 = obj.amp*abs(obj.length)*sinc(obj.length*f).*exp(-1j*2*pi*f*(obj.t0+(obj.length-1)/2));
            v1 = obj.amp*abs(obj.length)*sinc(obj.length*f).*exp(-1j*2*pi*f*(obj.t0+obj.length/2));  
            sigmaf = 1/(2*pi*0.4246*obj.gaus_w);
            v2 = exp(-f.^2/(2*sigmaf^2));
%             v3 = obj.overshoot*sign(obj.amp)*(exp(-1j*2*pi*f*obj.t0)+exp(-1j*2*pi*f*(obj.t0 + obj.length-1)));
            v3 = obj.overshoot*sign(obj.amp)*(exp(-1j*2*pi*f*obj.t0)+exp(-1j*2*pi*f*(obj.t0 + obj.length)));
            v = v1.*v2+v3;
        end
    end
end