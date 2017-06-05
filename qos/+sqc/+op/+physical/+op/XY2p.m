classdef XY2p < sqc.op.physical.gate.X2p
    % +pi/2 pulse at at an arbitary axis in the xy plane
	% Note: halfPiAmp for different rotation axis are not exactly the same,
	% use this operation for coarse application or tunning only.
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        phase % axis
    end
    methods
        function obj = XY2p(qubit,phase)
            obj = obj@sqc.op.physical.gate.X2p(qubit);
			obj.phase = phase;
        end
    end
    methods (Hidden = true)
        function GenWave(obj)
            GenWave@sqc.op.physical.gate.X2p(obj)
            obj.xy_wv{1}.phase = obj.qubits{1}.g_XY_phaseOffset+obj.phase;
        end
    end
end