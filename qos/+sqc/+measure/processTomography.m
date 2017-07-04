classdef processTomography < qes.measurement.measurement
    % process tomography
    % data: 4^n by 3^n by 2^n, n, number of qubits
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

	properties
		showProgress@logical scalar = true; % print measurement progress to command window or not
	end
	properties (SetAccess = private)
		qubits
        process
    end
    properties (GetAccess = private, SetAccess = private)
		stateTomoObj
		statePrepGates
    end
    methods
        function obj = processTomography(qubits, process)
			if ~isa(process,'sqc.op.physical.operator')
				throw(MException('QOS_processTomography:invalidInput',...
						'the input is not a valid quantum operator.'));
			end
			import sqc.op.physical.gate.*
			if ~iscell(qubits)
                qubits = {qubits};
            end
            numTomoQs = numel(qubits);
            for ii = 1:numTomoQs
                if ischar(qubits{ii})
                    qs = sqc.util.loadQubits();
                    qubits{ii} = qs{qes.util.find(qubits{ii},qs)};
				end
            end
            obj = obj@qes.measurement.measurement([]);
            obj.process = process;
			obj.qubits = qubits;
			numTomoQs = numel(obj.qubits);
			obj.statePrepGates = cell(1,numTomoQs);
			for ii = 1:numTomoQs
				% gates that prepares the qubit onto states: {|0>, |1>, |0>+|1>, |0>+i|1>}
				obj.statePrepGates{numTomoQs-ii+1} = {I(obj.qubits{ii}),...
										X(obj.qubits{ii}),...
										Y2p(obj.qubits{ii}),...
										X2m(obj.qubits{ii}),...
										};
%                 obj.statePrepGates{ii} = {I(obj.qubits{ii}),...
% 										X(obj.qubits{ii}),...
% 										Y2p(obj.qubits{ii}),...
% 										X2m(obj.qubits{ii}),...
% 										};
            end
			obj.stateTomoObj = sqc.measure.stateTomography(qubits);
            obj.numericscalardata = false;
        end
        function Run(obj)
            Run@qes.measurement.measurement(obj);
			numTomoQs = numel(obj.qubits);
			lpr = qes.util.looper_(obj.statePrepGates);
			data = NaN*ones(4^numTomoQs,3^numTomoQs,2^numTomoQs);
			numShots = 4^numTomoQs;
			idx = 0;
			while true
				idx = idx + 1;
				if obj.showProgress
					obj.stateTomoObj.progInfoPrefix =...
						sprintf('Process tomography: %0.0f of %0.0f | ',idx,numShots);
				end
				pGates = lpr();
				if isempty(pGates)
					break;
				end
				P = pGates{1};
				for ii = 2:numTomoQs
					P = P.*pGates{ii};
                end
                P = P*obj.process;
				obj.stateTomoObj.setProcess(P);
				data(idx,:,:) = obj.stateTomoObj();
			end
            obj.data = data;
			obj.dataready = true;
        end
    end
end