classdef Z_phase < sqc.op.physical.Z_z_base
    % pi rotation around the z axis, implement by phase shift
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = Z_phase(qubit)
            obj = obj@sqc.op.physical.Z_z_base(qubit);
            obj.logical_op = sqc.op.logical.gate.Z;
			obj.length = obj.qubits{1}.g_Z_z_ln;
            obj.bias_amp = obj.qubits{1}.g_Z_z_amp;
        end
    end
end