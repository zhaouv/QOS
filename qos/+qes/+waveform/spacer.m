classdef spacer < qes.waveform.waveform
    % a spacer waveform: a series of zeros for padding some space between
    % two waveforms, for example
    % S = @() spacer(); % this is just to alias the class name.
    % wv_squence = [X1 Y2 S(5) Y1 S(5) Y2 S(50) X2 S X1]; 
    % S is equal to S(0), that is a space of zero length(in points).
    % 

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = spacer(ln)
            if nargin == 0
                ln = 0; % default
            end
            obj = obj@qes.waveform.waveform(ln);
        end
    end
    methods (Static = true, Hidden=true)
        function v = TimeFcn(obj,t)
            v = zeros(1,length(t));
        end
        function v = FreqFcn(obj,f)
            v = zeros(1,length(f));
        end
    end
end