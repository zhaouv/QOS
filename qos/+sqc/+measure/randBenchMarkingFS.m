classdef randBenchMarkingFS < sqc.measure.randBenchMarking
    % randomized benchmarking, run one fixed random gate sequence
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = private, GetAccess = private)
        ridx
    end
    methods
        function obj = randBenchMarkingFS(qubits, numGates)
            obj = obj@sqc.measure.randBenchMarking(qubits, [], numGates, 1, false);
            if numel(qubits) == 1
                obj.ridx = randi(24,1,obj.numGates);
            elseif numel(qubits) == 2
                obj.ridx = randi(11520,1,obj.numGates);
            else
                error('randBenchMarking on more than 2 qubits is not implemented.');
            end
        end
        function Run(obj)
            Run@qes.measurement.measurement(obj);
            [gs,gf_ref,gf_i,gref_idx,gint_idx] = obj.randGates(obj.ridx);
            
            PR = gs{1,1};
            for ii = 2:numGates
                PR = PR*gs{1,ii};
            end
            PR = PR*gf_ref;

            obj.R.state = 1;
            obj.R.delay = PR.length;
            PR.Run();
			obj.data = obj.R();
            obj.extradata(nn,:) = gref_idx;
            obj.dataready = true;
        end
    end
end