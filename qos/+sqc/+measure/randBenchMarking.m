classdef randBenchMarking < qes.measurement.measurement
    % randomized benchmarking
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        qubits % qubit objects or qubit names
    end
    properties (GetAccess = private, SetAccess = private)
    end
	properties (GetAccess = private, Constant = true)
		singleQGateSet = {{'I'},{'X'},{'Y'},{'Y','X'},...
					{'X2p','Y2p'},{'X2p','Y2m'},{'X2m','Y2p'},{'X2m','Y2m'},...
                    {'Y2p','X2p'},{'Y2p','X2m'},{'Y2m','X2p'},{'Y2m','X2m'},...
					{'X2p'},{'X2m'},{'Y2p'},{'Y2m'},...
                    {'X2m','Y2p','X2p'},{'X2m','Y2m','X2p'},...
                    {'X','Y2p'},{'X','Y2m'},{'Y','X2p'},{'Y','X2m'},...
                    {'X2p','Y2p','X2p'},{'X2m','Y2p','X2m'}}
        numSingleQGates = 24
        s1Gates = {{'I'},{'Y2p','X2p'},{'X2m','Y2m'}}
        numS1Gates = 3;
        s1X2pGates = {{'X2p'},{'X2p','Y2p','X2p'},{'Y2m'}}
        numS1X2pGates = 3;
        s1Y2pGates = {{'Y2p'},{'Y','X2p'},{'Y2p','X2m','Y2m'}}
        numS1Y2pGates = 3;
    end
    properties (SetAccess = private, GetAccess = private)
        
    end
    methods
        function obj = randBenchMarking()
            obj = obj@qes.measurement.measurement([]);
            obj.numericscalardata = false;
        end
		function finalGate()
		end
        
    end
	methods (Access = private)
		function gs = randGates(m)
			
		end
		function g = finalGate(gs)
            
        end
        function g = getRndSingleQGate(obj,q)
            gc = obj.singleQGateSet{randi(obj.numSingleQGates)};
            g = feval(gc{1},q);
            for ii = 2:numel(gc)
                g = feval(gc{ii},q)*g;
            end
        end
        function gs = cNotGates(obj)
            % 5184 gates
            
        end
	end
end