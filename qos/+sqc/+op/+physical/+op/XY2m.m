classdef XY2m < sqc.op.physical.gate.X2m
    % -pi/2 rotation at at an arbitary axis in the xy plane
	% Note: halfPiAmp for different rotation axis are not exactly the same,
	% use this operation for coarse application or tunning only.
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        phase % axis 
    end
    methods
        function obj = XY2m(qubit, phase)
            obj = obj@sqc.op.physical.gate.X2m(qubit);
			obj.phase = phase;
        end
    end
    methods (Hidden = true)
        function GenWave(obj)
            GenWave@sqc.op.physical.gate.X2p(obj)
            obj.xy_wv{1}.phase = obj.phase;
        end
    end
end