classdef tomography < qes.measurement.measurement
    % process tomography, use a empty process to do state tomography
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
    properties (GetAccess = private, SetAccess = private)
        process
		tomoQubits
		readoutGates
    end
    methods
        function obj = tomography(process,tomoQubits)
            % process tomography, use a empty process to do state tomography
			assert(isa(process,'sqc.op.physical.operator'));
			import sqc.op.physical.gate.*
            obj.process = process;
			if ~iscell(tomoQubits)
				if ischar(tomoQubits) % single qubit name
					tomoQubits = {tomoQubits};
				else
					throw(MException('tomography:invalidInput',...
						'the input tomoQubits should be a cell array of qubit objects or qubit names.'));
				end
			end
			obj.tomoQubits = tomoQubits;
			numTomoQs = numel(obj.tomoQubits);
			obj.readoutGates = cell(numTomoQs);
			for ii = 1:numTomoQs
				obj.readoutGates{ii} = {I(obj.tomoQubits{ii}),...
										Y2p(obj.tomoQubits{ii}),...
										X2m(obj.tomoQubits{ii})};
            end
            obj.numericscalardata = false;
        end
        function Run(obj)
            Run@qes.measurement.measurement(obj);
			numTomoQs = numel(obj.tomoQubits);
			lpr = qes.util.looper_(obj.readoutGates);
			data = nan*ones(1,3^numTomoQs);
			idx = 0;
			while true
				idx = idx + 1;
				rGates = lpr();
				if isempty(rGates)
					break;
				end
				rOp = rGates{1};
				for ii = 2:numTomoQs
					rOp = rOp.*rGates{ii};
				end
				P = rOp*obj.process;
				R = sqc.measure.resonatorReadout(obj.tomoQubits);
				R.delay = P.length;
				P.Run();
				data(idx) = R();
			end
            obj.data = data;
			obj.dataready = true;
        end
    end
end