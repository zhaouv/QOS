classdef stateTomography < qes.measurement.measurement
    % state tomography
	% data: 3^n by 2^n, n, number of qubits
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

	properties
		showProgress@logical scalar = true; % print measurement progress to command window or not
		progInfoPrefix = ''
	end
	properties (SetAccess = private)
		qubits
    end
    properties (GetAccess = private, SetAccess = private)
		readoutGates
		process % for process tomography
    end
    methods
        function obj = stateTomography(qubits)
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
			obj.qubits = qubits;
			obj.readoutGates = cell(numTomoQs);
			for ii = 1:numTomoQs
				obj.readoutGates{ii} = {I(obj.qubits{ii}),...
										Y2p(obj.qubits{ii}),...
										X2m(obj.qubits{ii})};
            end
            obj.numericscalardata = false;
        end
        function Run(obj)
            Run@qes.measurement.measurement(obj);
			numTomoQs = numel(obj.qubits);
			lpr = qes.util.looper_(obj.readoutGates);
			data = nan*ones(3^numTomoQs,2^numTomoQs);
			numShots = 3^numTomoQs;
			idx = 0;
			while true
				idx = idx + 1;
				if obj.showProgress
					home;
					disp(sprintf('%sSate tomography: %0.0f of %0.0f',...
						obj.progInfoPrefix, idx, numShots));
				end
				rGates = lpr();
				if isempty(rGates)
					break;
				end
				P = rGates{1};
				for ii = 2:numTomoQs
					P = P.*rGates{ii};
				end
				if ~isempty(obj.process)
					P = P*obj.process;
				end
				R = sqc.measure.resonatorReadout(obj.qubits);
				R.delay = P.length;
				P.Run();
				data(idx,:) = R();
			end
            obj.data = data;
			obj.dataready = true;
        end
    end
	methods(Hidden = true)
		function setProcess(obj,p)
			% for process tomography
			if ~isa(p,'sqc.op.physical.operator')
				throw(MException('QOS_stateTomography:invalidInput',...
						'the input is not a valid quantum operator.'));
			end
			if ~qes.util.identicalArray(p.qubits,obj.qubits)
				throw(MException('QOS_stateTomography:differentQubtSet',...
						'the input process acts on a different qubit set than the state tomography qubits.'));
			end
			obj.process = p;
		end
	end
end