classdef Uxy < sqc.op.physical.operator
    % implement arbitary unitary operator with xy rotation
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    % properties (SetAccess = private)
    %    U % the unitary operator to implement
    % end
    methods
        function obj = Uxy(U)
			% todo..
			% check U
			error('this class is not ready');
            obj = obj@sqc.op.physical.operator(qubit);
        end
    end
    methods (Hidden = true)
        function GenWave(obj)
            % todo
        end
    end
end