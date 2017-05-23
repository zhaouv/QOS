classdef processTomography < qes.measurement.measurement
    % process tomography
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
	properties
		showProgress@logical scalar = true; % print measurement progress to command window or not
	end
	properties (SetAccess = private)
		qubits
    end
    properties (GetAccess = private, SetAccess = private)
		stateTomoObj
		statePrepGates
        process
    end
    methods
        function obj = processTomography(qubits, process)
			if ~isa(process,'sqc.op.physical.operator')
				throw(MException('QOS_processTomography:invalidInput',...
						'the input is not a valid quantum operator.'));
			end
			import sqc.op.physical.gate.*
            obj.process = process;
			if ~iscell(qubits)
				if ischar(qubits) % single qubit name
					qubits = {qubits};
				else
					throw(MException('QOS_processTomography:invalidInput',...
						'the input qubits should be a cell array of qubit objects or qubit names.'));
				end
			end
			obj.qubits = qubits;
			numTomoQs = numel(obj.tomoQubits);
			obj.statePrepGates = cell(numTomoQs);
			for ii = 1:numTomoQs
				% gates that prepares the qubit onto states: {|0>,|0>-i|1>,|0>+|1>,|1>}
				obj.statePrepGates{ii} = {I(obj.tomoQubits{ii}),...
										X2p(obj.tomoQubits{ii}),...
										Y2p(obj.tomoQubits{ii}),...
										X(obj.tomoQubits{ii})};
            end
			obj.stateTomoObj = sqc.measure.stateTomography(qubits);
            obj.numericscalardata = false;
        end
        function Run(obj)
            Run@qes.measurement.measurement(obj);
			numTomoQs = numel(obj.tomoQubits);
			lpr = qes.util.looper_(obj.statePrepGates);
			data = NaN*ones(2^numTomoQs,3^numTomoQs,2^numTomoQs);
			numShots = 2^numTomoQs;
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
				obj.stateTomoObj.setProcess(P);
				data(idx,:,:) = obj.stateTomoObj();
			end
            obj.data = data;
			obj.dataready = true;
        end
    end
end