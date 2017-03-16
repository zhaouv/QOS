classdef (Sealed = true) rect_acz < qes.waveform.waveform
    % adiabatic cz gate waveform

% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties 

    end
    methods
        function obj = rect_acz(ln)
            if nargin == 0
                ln = 0;
            end
            obj = obj@qes.waveform.waveform(ln);
            error('to be implemented');
        end
    end
    methods (Static = true, Hidden=true)
        function v = TimeFcn(obj,t)
            error('to be implemented');
            v = [];
        end
        function v = FreqFcn(obj,f)
            v = qes.waveform.wvfcn.FFT(obj,f);
        end
    end
end