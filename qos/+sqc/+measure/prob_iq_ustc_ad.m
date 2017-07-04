classdef (Abstract = true)prob_iq_ustc_ad < qes.measurement.prob
    %
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
    properties
        n
        threeStates = false; % {|0>, |1>} system or {|0>, |1>, |2>} system
    end
    properties (SetAccess = private)
        qubits % qubit objects or qubit names
    end
    properties (SetAccess = private, GetAccess = protected)
        num_qs
		center0
		center1
		center2
%        ref_angle % r_iq2prob_01rAngle
%        ref_point % r_iq2prob_01rPoint
%        threshold % r_iq2prob_01threshold
%        polarity % r_iq2prob_01polarity
    end
    methods
        function obj = prob_iq_ustc_ad(iq_ustc_ad_obj,qs)
            obj = obj@qes.measurement.prob(iq_ustc_ad_obj);
            obj.n = iq_ustc_ad_obj.n;
            obj.numericscalardata = false;
            obj.qubits = qs;
        end
        function set.qubits(obj,val)
            if ~iscell(val) && ischar(val)
                val = {val};
            end
            selected_qubits = sqc.util.loadQubits();
            num_qs_ = numel(val);
			obj.num_qs = num_qs_;
            qs = cell(1,num_qs_);
            for ii = 1:num_qs_
                if ~ischar(val{ii})
                    if ~isa(val{ii},'sqc.qobj.qobject')
                        error('input not a qubit.');
                    else
                        qs{ii} = val{ii}; % accepts qubit objects, typically virtual qubits
                        continue;
                    end
                end
                if ~qes.util.ismember(val{ii},selected_qubits)
                    if ischar(val{ii})
                        error('%s is not one of the selected qubits.',val{ii});
                    else
                        error('%s is not one of the selected qubits.',val{ii}.name);
                    end
                end
                qs{ii} = selected_qubits{qes.util.find(val{ii},selected_qubits)};
            end
            obj.qubits = qs;
			center0_ = zeros(1,num_qs_);
            center1_ = zeros(1,num_qs_);
            center2_ = zeros(1,num_qs_);
            for ii = 1:num_qs_ 
                center0_(ii) = obj.qubits{ii}.r_iq2prob_center0;
                center1_(ii) = obj.qubits{ii}.r_iq2prob_center1;
                center2_(ii) = obj.qubits{ii}.r_iq2prob_center2;
            end
            obj.center0 = center0_;
            obj.center1 = center1_;
            obj.center2 = center2_;
			
%            ref_angle_ = zeros(1,num_qs);
%            ref_point_ = zeros(1,num_qs);
%            threshold_ = zeros(1,num_qs);
%            polarity_ = zeros(1,num_qs);
%            for ii = 1:num_qs
%                ref_angle_(ii) = obj.qubits{ii}.r_iq2prob_01angle;
%                ref_point_(ii) = obj.qubits{ii}.r_iq2prob_01rPoint;
%                threshold_(ii) = obj.qubits{ii}.r_iq2prob_01threshold;
%                polarity_(ii) = obj.qubits{ii}.r_iq2prob_01polarity;
%            end
%            obj.ref_angle = ref_angle_;
%            obj.ref_point = ref_point_;
%            obj.threshold = threshold_;
%            obj.polarity = polarity_;
        end
        function set.n(obj,val)
            if isempty(val) || ceil(val) ~=val || val <=0
                error('n should be a positive integer!');
            end
            obj.instrumentObject.n = val;
            obj.n = val;
        end
        function Run(obj)
            Run@qes.measurement.prob(obj);
            obj.instrumentObject.Run();
            iq_raw = obj.instrumentObject.extradata;
			if obj.threeStates
				p = zeros(obj.num_qs,obj.n);
                for ii = 1:obj.num_qs
                    d0 = abs(iq_raw(ii,:) - obj.center0);
                    d1 = abs(iq_raw(ii,:) - obj.center1);
                    d2 = abs(iq_raw(ii,:) - obj.center2);
                    [~,minIdx] = min([d0; d1; d2],[],1);
					p(ii,:) = minIdx-1;
                end
%                 p1 = zeros(1,obj.num_qs);
%                 for ii = 1:obj.num_qs
%                     if obj.polarity(ii) <0
%                         p1(ii) = mean((iq_raw{ii} - obj.ref_point(ii))*exp(-1j*obj.ref_angle(ii)) > obj.threshold(ii));
%                     else
%                         p1(ii) = mean((iq_raw{ii} - obj.ref_point(ii))*exp(-1j*obj.ref_angle(ii)) < obj.threshold(ii));
%                     end
%                 end
            else
				p = zeros(obj.num_qs,obj.n);
                for ii = 1:obj.num_qs
                    d0 = abs(iq_raw(ii,:) - obj.center0(ii));
                    d1 = abs(iq_raw(ii,:) - obj.center1(ii));
                    [~,minIdx] = min([d0; d1],[],1);
					p(ii,:) = minIdx-1;
                end
            end
            obj.data = p;
            obj.extradata = iq_raw;
            obj.dataready = true;
        end
    end
end