classdef dc < qes.waveform.waveform
    % dc

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

	properties
		dcval = 0
        balance = 1; % = Q/I. add by GM. 20170418
	end
    methods
        function obj = dc(ln)
            if nargin == 0
                ln = 0; % default
            end
            obj = obj@qes.waveform.waveform(ln);
        end
    end
    methods (Static = true, Hidden=true)
        function v = TimeFcn(obj,t)
            v = obj.dcval*ones(1,length(t));
        end
        function v = FreqFcn(obj,f)
            v = zeros(1,length(f));
			v(f==0) = Inf;
        end
    end
end