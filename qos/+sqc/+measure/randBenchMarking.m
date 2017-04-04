classdef randBenchMarking < qes.measurement.measurement
    % randomized benchmarking
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        qubits % qubit objects or qubit names
    end
	properties (SetAccess = private, GetAccess = privatem, Constant = true)
        gateSetNames
		gateSet
		numGate
    end
    properties (SetAccess = private, GetAccess = private)
        
    end
    methods
        function obj = randBenchMarking()
            obj = obj@qes.measurement.measurement([]);
            obj.gateSetNames = {'I','X','Y','X/2','Y/2',...
					'-X','-Y','-X/2','-Y/2'};
			obj.gateSet = {'I','X','Y','X2p','Y2p',...
					'X','Y','X2m','Y2m'};
					
			obj.gateSet = [{'I'},{'X'},{'Y'},{'Y','X'},...
					'X2p','Y2p',...
					'X','Y','X2m','Y2m'];
			obj.numGate = numel(obj.gateSetNames);
			error('todo...');
            
            obj.numericscalardata = false;
        end
		function finalGate()
		end
        
    end
	methods (Access = private)
		function gs = randGates(m)
			
		end
		function g = finalGate(gs);
		end
	end
end