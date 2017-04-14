classdef prob_iq_ustc_ad_j < sqc.measure.prob_iq_ustc_ad
    % joint readout
	% data: 1 by 2^(number of qubits)
	% obj.data(n) is the probability of nth(count from left to right) state in
	% {|000...00>,|000...01>,...,|111...10>,|111...11>}
	% qubits labeled as |qn,qn-1,...,q2,q1>
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
    
    properties (SetAccess = private)
        stateNames
    end
    methods
        function obj = prob_iq_ustc_ad_j(iq_ustc_ad_obj,qs)
            obj = obj@sqc.measure.prob_iq_ustc_ad(iq_ustc_ad_obj,qs);
            obj.stateNames = cell(1,2^obj.num_qs);
            for ii = 0:2^obj.num_qs-1
                obj.stateNames{ii+1} = sprintf('|%s>',dec2bin(ii,obj.num_qs));
            end
        end
        function Run(obj)
			if obj.threeStates
				throw(MException('QOS_prob_iq_ustc_ad_j:jointReadoutThreeStates',...
					'joint readout of three states is not implemented.'));
			end
            Run@sqc.measure.prob_iq_ustc_ad(obj);
			d = 2.^(0:obj.num_qs-1)*obj.data;
			numStates = 2^obj.num_qs;
			obj.data = zeros(1,2^obj.num_qs);
			for ii = 0:numStates-1
				obj.data(ii+1) = sum(d==ii)/obj.n;
			end
        end
    end
end