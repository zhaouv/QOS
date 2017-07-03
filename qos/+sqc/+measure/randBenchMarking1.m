classdef randBenchMarking < qes.measurement.measurement
    % randomized benchmarking
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = private)
        process
        qubits % qubit objects or qubit names
        numGates
    end
    properties (GetAccess = private, SetAccess = private)
        processIdx
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
        function obj = randBenchMarking(qubits, process,numGates)
            if ~isa(process,'sqc.op.physical.operator')
				throw(MException('QOS_randBenchMarking:invalidInput',...
						'the input is not a valid quantum operator.'));
			end
			import sqc.op.physical.gate.*
			if ~iscell(qubits)
                qubits = {qubits};
            end
            numQs = numel(qubits);
            if numQs > 2
				throw(MException('QOS_randBenchMarking:invalidInput',...
						'randBenchMarking on more than 2 qubits is not supported.'));
			end
            for ii = 1:numQs
                if ischar(qubits{ii})
                    qs = sqc.util.loadQubits();
                    qubits{ii} = qs{qes.util.find(qubits{ii},qs)};
				end
            end
            obj = obj@qes.measurement.measurement([]);
            obj.process = process;
			obj.qubits = qubits;
            obj.numericscalardata = false;
            obj.numGates = numGates;
            
            
            className = class(process);
            className = strsplit(className,'.');
            className = className{end};
            switch className
                case 'I'
                    obj.processIdx = 1;
                case 'X'
                    obj.processIdx = 2;
                case 'Y'
                    obj.processIdx = 3;
                case 'X2p'
                    obj.processIdx = 13;
                case 'X2m'
                    obj.processIdx = 14;
                case 'Y2p'
                    obj.processIdx = 15;
                case 'Y2m'
                    obj.processIdx = 16;
            end
        end
        function Run(obj)
            Run@qes.measurement.measurement(obj);
            [gs,gf_ref,gf_i] = obj.randGates();
            PR = gs{1};
            for ii = 2:obj.numGates
                PR = PR*gs{ii};
            end
            PR = PR*gf_ref;
            Pi = gs{1};
            for ii = 2:obj.numGates
                Pi = Pi*obj.process*gs{ii};
            end
            Pi = Pi*obj.process*gf_i;
            
            R = sqc.measure.resonatorReadout_ss(obj.qubits);
            R.state = 1;
            
			R.delay = PR.length;
			PR.Run();
            pa = R();
            
            R.delay = Pi.length;
			Pi.Run();
            pb = R();
            
            obj.data = [pa, pb];
        end
    end
	methods (Access = private)
		function [gs,gf_ref,gf_i] = randGates(obj)
            numQs = numel(obj.qubits);
            gs = cell(1,obj.numGates);
			switch numQs
                case 1
                    ridx = randi(obj.numSingleQGates,1,obj.numGates);
                    gn = obj.singleQGateSet(ridx);
                    for ii = 1:obj.numGates
                        g_ = feval(str2func(['@(q)sqc.op.physical.gate.',gn{ii}{1},'(q)']),obj.qubits);
                        for jj = 2:numel(gn{ii})
                            g_ = g_*feval(str2func(['@(q)sqc.op.physical.gate.',gn{ii}{jj},'(q)']),obj.qubits);
                        end
                        gs{ii} = g_;
                    end
                case 2
                    error('todo');
            end
            gf_ref = obj.finalGate(ridx);
            iidx = reshape([ridx; obj.processIdx*ones(1,obj.numGates)],1,[]);
            gf_i = obj.finalGate(iidx);
        end
		function g = finalGate(obj,gidx)

            mI = [1,0;0,1];
            mX = [0,1;1,0];
            mY = [0,-1i;1i,0];

            mX2p = expm(-1j*(pi/2)*mX/2);
            mX2m = expm(-1j*(-pi/2)*mX/2);

            mY2p = expm(-1j*(pi/2)*mY/2);
            mY2m = expm(-1j*(-pi/2)*mY/2);

            singleQGateSet_m = {mI, mX, mY, mX*mY,...
                                mY2p*mX2p, mY2m*mX2p, mY2p*mX2m, mY2m*mX2m,...
                                mX2p*mY2p, mX2m*mY2p, mX2p*mY2m, mX2m*mY2m,...
                                mX2p, mX2m, mY2p, mY2m,...
                                mX2p*mY2p*mX2m, mX2p*mY2m*mX2m,...
                                mY2p*mX, mY2m*mX, mX2p*mY, mX2m*mY,...
                                mX2p*mY2p*mX2p, mX2m*mY2p*mX2m};
                            
            gm = singleQGateSet_m(gidx);
            gm_ = gm{1};
            for ii = 2:numel(gm)
                gm_ = gm{ii}*gm_;
            end
            D = ones(1,24);
            
            for ii = 1:24
                mi = singleQGateSet_m{ii}*gm_;
                if abs(mi(1,2)) + abs(mi(2,1)) < 0.001 &&...
                        (abs(angle(mi(1,1)) - angle(mi(2,2))) < 0.001 ||...
                        abs(abs(angle(mi(1,1)) - angle(mi(2,2)))- 2*pi) < 0.001)
                    break;
                end
                if ii == 24
                    error('error!');
                end
            end
            
            gfn = obj.singleQGateSet{ii};
            g = feval(str2func(['@(q)sqc.op.physical.gate.',gfn{1},'(q)']),obj.qubits);
            for jj = 2:numel(gfn)
                g = g*feval(str2func(['@(q)sqc.op.physical.gate.',gfn{jj},'(q)']),obj.qubits);
            end
        end
        function gs = cNotGates(obj)
            % 5184 gates
            
        end
	end
end