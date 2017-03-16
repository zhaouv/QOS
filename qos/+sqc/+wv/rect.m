classdef (Sealed = true) rect < qes.waveform.waveform
    % rectangular pulse with two delta function at the rising and full edge
    % as overshoot. As delta funciton can not be properly represented in
    % time domain, the TimeFcn is just a rectangular pulse with two 
    % guassians at the edges to give a sense what the real waveform
    % would looks after DA pulse generation(with filters), or to say just
    % for display, it is not used for real DA data generation. 
    % only frequency domain funciton is used in pulse generation, thus
    % overshoot_w is not important as far as DA waveform generation is
    % considered.
    % overshoot defines the overshoot amplitude in frequecy domain.

% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties 
        amp = 1
        overshoot = 0;  % amplitude of overshoot in frequency domain
        % float, half of the gaussian pulse length, unit: 1/sampling frequency
        % only used in time domain function for display.
        overshoot_w = 1; 
    end
    methods
        function obj = rect(ln)
            if nargin == 0
                ln = 0;
            end
            obj = obj@qes.waveform.waveform(ln);
        end
        function set.overshoot_w(obj,val)
            if val <= 0
                % if no overshoot is needed, set overshoot = 0;
                error('Wv_Rect:invalidinput','overshoot width should be positive.');
            end
            obj.overshoot_w = val;
        end
    end
    methods (Static = true, Hidden=true)
        function v = TimeFcn(obj,t)
            o_amp = 2*sqrt(log(2)/pi)/obj.overshoot_w;  % area == 1
            sigma = 0.4246*obj.overshoot_w; % 2*FWHM = total gaussian pulse length which is 2*obj.overshoot_w
            overshoot_amp = obj.overshoot*sign(obj.amp)*o_amp;
%             v = obj.amp*(t > obj.t0).*(t < obj.t0 + obj.length-1) +...
%                 obj.overshoot*o_amp*exp(-(t-(obj.t0+1)).^2/(2*sigma^2))+...
%                 obj.overshoot*o_amp*exp(-(t-(obj.t0+obj.length-2)).^2/(2*sigma^2));
            
%             rise_ln = round(obj.overshoot_w); 
%             v = obj.amp*(t >= obj.t0 + rise_ln).*(t <= obj.t0 + obj.length-1-rise_ln) +...
%                 overshoot_amp*exp(-(t-(obj.t0+rise_ln)).^2/(2*sigma^2))+...
%                 overshoot_amp*exp(-(t-(obj.t0+obj.length-1-rise_ln)).^2/(2*sigma^2));

            v = obj.amp*(t >= obj.t0).*(t < obj.t0 + obj.length) +...
                overshoot_amp*exp(-(t-obj.t0).^2/(2*sigma^2))+...
                overshoot_amp*exp(-(t-(obj.t0+obj.length)).^2/(2*sigma^2));
        end
        function v = FreqFcn(obj,f)
%             v = obj.amp*abs(obj.length)*sinc(obj.length*f).*exp(-1j*2*pi*f*(obj.t0+(obj.length-1)/2))+...
%                 oa*(exp(-1j*2*pi*f*(obj.t0+1))+exp(-1j*2*pi*f*(obj.t0 + obj.length-2)));

%             v = obj.amp*abs(obj.length-2*rise_ln)*sinc((obj.length-2*rise_ln)*f).*exp(-1j*2*pi*f*(obj.t0+(obj.length-1)/2))+...
%                 oa*(exp(-1j*2*pi*f*(obj.t0+rise_ln))+exp(-1j*2*pi*f*(obj.t0 + obj.length-1-rise_ln)));
            
            v = obj.amp*abs(obj.length)*sinc(obj.length*f).*exp(-1j*2*pi*f*(obj.t0+obj.length/2))+...
                 obj.overshoot*sign(obj.amp)*(exp(-1j*2*pi*f*obj.t0)+exp(-1j*2*pi*f*(obj.t0 + obj.length)));
        end
    end
end