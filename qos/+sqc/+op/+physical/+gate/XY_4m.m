classdef XY_4m < sqc.op.physical.gate.X
    % pi rotation around -pi/4 axis in the XY plane
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = XY_4m(qubit)
            obj = obj@sqc.op.physical.gate.X(qubit);
        end
    end
    methods (Hidden = true)
        function GenWave(obj)
            GenWave@sqc.op.physical.gate.X(obj)
            obj.xy_wv{1}.phase = obj.qubits{1}.g_XY_phaseOffset-pi/4;
        end
    end
end