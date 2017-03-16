classdef (Sealed = true) gaussian < qes.waveform.waveform
    % gaussian

% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties 
        amp = 1         % pulse amplitude 
        rsigma = 0.2123;   % sigma/length, by default, rsigma = 0.2123 (FWHM = length/2)
    end
    methods
        function obj = gaussian(ln)
            if nargin == 0
                ln = 0;
            end
            obj = obj@qes.waveform.waveform(ln);
            obj.iq = true;
        end
    end
    methods (Static = true, Hidden=true)
        function v = TimeFcn(obj,t)
            % if the IQ mixer mixes as I*cos(2*pi*flo*t)-Q*sin(2*pi*flo*t); flo
            % is the lo frequency, then:
            % real part of v is wavedata for I channel and imaginary part of v is
            % wavedata for Q channel.
%             v = obj.amp*exp(-(t- obj.t0 -(obj.length-1)/2).^2/(2*(obj.rsigma*obj.length)^2))...
%                 .*exp(1j*2*pi*obj.freq*t-1j*obj.phase); % this is just frequency mixing
%             v = obj.amp*exp(-(t- obj.t0 -(obj.length-1)/2).^2/(2*(obj.rsigma*obj.length)^2));
            v = obj.amp*exp(-(t- obj.t0 -obj.length/2).^2/(2*(obj.rsigma*obj.length)^2));
        end
        function v = FreqFcn(obj,f)
            sigma = obj.rsigma*obj.length;
            sigmaf = 1/(2*pi*sigma);
            ampf = obj.amp*sqrt(2*pi*sigma^2);
%             v = ampf*exp(-(f-obj.freq).^2/(2*sigmaf^2)-1j*2*pi*(f-obj.freq)*(obj.t0+(obj.length-1)/2)-1j*obj.phase);
%             v = ampf*exp(-f.^2/(2*sigmaf^2)-1j*2*pi*f*(obj.t0+(obj.length-1)/2));
            v = ampf*exp(-f.^2/(2*sigmaf^2)-1j*2*pi*f*(obj.t0+obj.length/2));
        end
    end
end