classdef operator < handle & matlab.mixin.Copyable
    % base class of all physical quantum operators, logical operation
    % properties are 'inherited': a physical operator can be manipulated
    % like a logical operator provide that the number of qubits is not greater
	% than logical_op_max_qubit_num.
	% to avoid complication, in mtimes and times all operator properties
	% opened for tuning of the resulting operator are assigned with the according
	% values of the second operand, thus it is a rule to do mtimes and times before
	% tuning those property values.

% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties % output delays for synchronization tuning, do not confuse with waveform t0
        % xy wave output delay, value in settings 'syncDelay_xy' is automatically
		% added as a small calibration in wave generation, thus should
		% not be included in this value
        % size must be equal to number of qubits
        delay_xy_i
        delay_xy_q
        % z wave output delay, settings 'syncDelay_z' is automatically
		% added as a small calibration in wave generation, thus should
		% not be included in this value
        % size must be equal to number of qubits
		% operators with different delays are not allowed to do mtimes operation
        delay_z
    end
    properties (SetAccess = protected)
		length
    end
    properties (SetAccess = private)
        qubits
		mw_src % follow some implicit setting rules, must be private 
        zdc_src % follow some implicit setting rules, must be private
		% buffer time in sampling points between gates, loaded from settings: session#/global/g_buffer.key
		gate_buffer
    end
    properties (SetAccess = protected, GetAccess = protected)
%         isStatic = false;
%         wvGenerated = false;
		xy_wv       % order: first applied first to follow the pulse generation time order convention
        z_wv        % order: first applied first to follow the pulse generation time order convention
    end
    properties (SetAccess = protected, GetAccess = protected)
		zdc_amp
		% not updated to instrument till Run is called because setting up the instrument in the set methods
        % will leads to repeatedly setting or querying of the
        % instrument in building up long processes
        mw_src_power % will be removed in future versions, change power by mw_src directly
        mw_src_frequency % will be removed in future versions, change frequency by mw_src directly
    end
    properties (SetAccess = private, GetAccess = private)
		needs_mwpower_setup
		needs_mwfreq_setup
        needs_zdc_setup
    end
    properties (SetAccess = protected, GetAccess = protected,Dependent = true)
        all_qubits
        all_qubits_names
    end
	properties (GetAccess = protected, Constant = true)
        logical_op_max_qubit_num = 8 % when qubit number exceeds this number, we drop the logical_op
    end
    properties (SetAccess = protected, GetAccess = protected)
        logical_op  %
    end
	methods (Hidden = true) % we need to set the logical_op in building up some physical operators,
						    % yet logical_op should not be visible for endusers 
		function SetLogical_op(obj, lop)
		    % set by developers only, thus no checking
			obj.logical_op = lop;
		end
	end
    methods
        function obj = operator(qs)
			% qs: cell array of qubit objects or qubit names
			% to the future: keep a static qubit registry/cache
			% so the common resource like mw soure, dc source etc are not handled repeatedly
            if isa(qs,'sqc.op.physical.operator')
                obj = sqc.op.physical.operator(qs.qubits);
                obj.delay_xy_i = qs.delay_xy_i;
                obj.delay_xy_q = qs.delay_xy_q;
                obj.delay_z = qs.delay_z;
                obj.mw_src_power = qs.mw_src_power;
                obj.mw_src_frequency = qs.mw_src_frequency;
                obj.mw_src = qs.mw_src;
                obj.zdc_src = qs.zdc_src;
                obj.zdc_amp = qs.zdc_amp;
                obj.length = qs.length;
                obj.needs_mwpower_setup = qs.needs_mwpower_setup;
                obj.needs_mwfreq_setup = qs.needs_mwfreq_setup;
                obj.needs_zdc_setup = qs.needs_zdc_setup;
                obj.logical_op = qs.logical_op;
                qs.GenWave();
                obj.xy_wv = qs.xy_wv;
                obj.z_wv = qs.z_wv;
%                 obj.isStatic = true;
                return;
            end
            if ~iscell(qs)
                qs = {qs};
            end
            for ii = 1:numel(qs)
				if ischar(qs{ii})
					qs{ii} = obj.all_qubits{qes.util.find(qs{ii},obj.all_qubits)};
					if isempty(qs{ii})
						throw(MException('sqc_op_pysical_operator:invalidInput',...
							'at least one of qubits is not a sqc.qobj.qubit class object or not a valid qubit name.'));
					end
                elseif ~isa(qs{ii},'sqc.qobj.qubit')
                    throw(MException('sqc_op_pysical_operator:invalidInput',...
						'at least one of qubits is not a sqc.qobj.qubit class object.'));
                end
            end
            obj.qubits = qs;
            num_qubits = numel(obj.qubits);
            obj.xy_wv = cell(1,num_qubits);
            obj.z_wv = cell(1,num_qubits);
            obj.delay_xy_i = zeros(1,num_qubits);
            obj.delay_xy_q = zeros(1,num_qubits);
            obj.delay_z = zeros(1,num_qubits);
            mw_src_ = {};
            mw_src_power_ = [];
            mw_src_frequency_ = [];
            mw_src_names = {};
            zdc_src_ = {};
            zdc_amp_ = zeros(1,num_qubits);
            for ii = 1:num_qubits
                idx = find(strcmp(mw_src_names,obj.qubits{ii}.channels.xy_mw.instru));
                if ~isempty(idx)
                    if obj.qubits{ii}.qr_xy_uSrcPower ~= mw_src_power_(idx)
                        throw(MException('sqc_op_pysical_operator:settingsMismatch',...
							'some qubits has the same mw source but has different qr_xy_uSrcPower values.'));
                    elseif ~isempty(idx) && obj.qubits{ii}.qr_xy_fc ~= mw_src_frequency_(idx)
                        throw(MException('sqc_op_pysical_operator:settingsMismatch',...
							'some qubits has the same mw source but has different qr_xy_fc values.'));
                    end
                else
					uSrc = qes.qHandle.FindByClassProp(...
                        'qes.hwdriver.hardware','name',obj.qubits{ii}.channels.xy_mw.instru);
                    if isempty(uSrc)
                        throw(MException('sqc_op_pysical_operator:hwNotFound',...
							'mw source %s for qubit %s not found, make sure hardware settings exist and mw source hardware object already created.',...
                            obj.qubits{ii}.channels.xy_mw.instru, obj.qubits{ii}.name));
                    end
                    mw_src_{end+1} = uSrc.GetChnl(obj.qubits{ii}.channels.xy_mw.chnl);
                    mw_src_power_(end+1) = obj.qubits{ii}.qr_xy_uSrcPower;
                    mw_src_frequency_(end+1) = obj.qubits{ii}.qr_xy_fc;
                    mw_src_names{end+1} = uSrc.name;
                end
				dcSrc = qes.qHandle.FindByClassProp(...
                    'qes.hwdriver.hardware','name',obj.qubits{ii}.channels.z_dc.instru);
                if isempty(dcSrc)
                    throw(MException('sqc_op_pysical_operator:hwNotFound',...
							'dc source %s for qubit %s not found, make sure hardware settings exist and dc source hardware object already created.',...
                            obj.qubits{ii}.channels.z_dc.instru, obj.qubits{ii}.name));
                end
                zdc_src_{ii} = dcSrc.GetChnl(obj.qubits{ii}.channels.z_dc.chnl);
%                 zdc_amp2f01_ = obj.qubits{ii}.zdc_amp2f01;
%                 zdc_amp2f01_(end) = zdc_amp2f01_(end) - obj.qubits{ii}.f01(1)/obj.qubits{ii}.zdc_amp2f_freqUnit;
%                 r = roots(zdc_amp2f01_);
%                 r = sort(r(isreal(r)));
%                 if isempty(r)
%                     r = 0;
% %                     throw(MException('sqc_op_pysical_operator:invalidSetting',...
% % 						sprintf('zdc_amp2f01 for qubit %s has no root for f01 of %0.4fGHz.',...
% % 							obj.qubits{ii}.name,obj.qubits{ii}.f01)));
%                 end
%                 if isempty(obj.qubits{ii}.zdc_ampCorrection)
%                     zdc_amp_(ii) = r(1);
%                 else
%                     zdc_amp_(ii) = r(1)+obj.qubits{ii}.zdc_ampCorrection;
%                 end
                zdc_amp_(ii) = obj.qubits{ii}.zdc_amp;
            end
            obj.mw_src = mw_src_;
            obj.mw_src_power = mw_src_power_;
            obj.mw_src_frequency = mw_src_frequency_;
            obj.zdc_src = zdc_src_;
            obj.zdc_amp = zdc_amp_;
        end
		function set.length(obj,val)
			if numel(val) ~= 1 || val < 0 || round(val) ~= val
				throw(MException('sqc_op_pysical_operator:invalidInput',...
					'length not a non negative scalar interger.'));
            end
            obj.length = val;
		end
		function set.logical_op(obj,op)
			if obj.logical_op_max_qubit_num < numel(obj.qubits)
				return;
			end
			obj.logical_op = op;
		end
        function set.delay_xy_i(obj,val)
            if numel(val) ~= numel(obj.qubits)
                throw(MException('sqc_op_pysical_operator:invalidInput',...
					'delay_xy_i size must be equal to number of qubits.'));
            end
            if any(val < 0)
                throw(MException('sqc_op_pysical_operator:invalidInput',...
					'delay_xy_i must be non negative.'));
            end
            obj.delay_xy_i = val;
        end
        function set.delay_xy_q(obj,val)
            if numel(val) ~= numel(obj.qubits)
                throw(MException('sqc_op_pysical_operator:invalidInput',...
					'delay_xy_q size must be equal to number of qubits.'));
            end
            if any(val < 0)
                throw(MException('sqc_op_pysical_operator:invalidInput',...
					'delay_xy_q must be non negative.'));
            end
            obj.delay_xy_q = val;
        end
        function set.delay_z(obj,val)
            if numel(val) ~= numel(obj.qubits)
                throw(MException('sqc_op_pysical_operator:invalidInput',...
					'delay_z size must be equal to number of qubits.'));
            end
            if any(val < 0)
                throw(MException('sqc_op_pysical_operator:invalidInput',...
					'delay_z must be non negative.'));
            end
            obj.delay_z = val;
        end
		function set.mw_src(obj,val)
			% has some implicit rules, thus kept private
            numExistingMwSrc = numel(obj.mw_src);
			numMwSrc2Add = numel(val)-numExistingMwSrc;
			obj.mw_src = val;
			if numMwSrc2Add
				obj.needs_mwpower_setup = ...
					[obj.needs_mwpower_setup,...
					logical(zeros(1,numMwSrc2Add))];
				obj.mw_src_power = [obj.mw_src_power,...
					NaN*zeros(1,numMwSrc2Add)];
				obj.mw_src_frequency = [obj.mw_src_frequency,...
					NaN*zeros(1,numMwSrc2Add)];
			end
		end
        function set.mw_src_power(obj,val)
			% has some implicit rules, thus kept private
			numMwSrc = numel(obj.mw_src);
            if numel(val) ~= numMwSrc
                throw(MException('sqc_op_pysical_operator:invalidInput',...
					'size of mw_src_power not matching the numbers of mw_src.'));
            end
			numExistingMwSrc = numel(obj.mw_src_power);
			for ii = 1:numMwSrc
				if ii <= numExistingMwSrc && obj.mw_src_power(ii) == val(ii)
					obj.needs_mwpower_setup(ii) = false;
                else
					obj.needs_mwpower_setup(ii) = true;
				end
			end
			obj.mw_src_power = val;
        end
		function set.mw_src_frequency(obj,val)
			numMwSrc = numel(obj.mw_src);
            if numel(val) ~= numMwSrc
                throw(MException('sqc_op_pysical_operator:invalidInput',...
					'size of mw_src_frequency not matching the numbers of mw_src.'));
            end
			numExistingMwSrc = numel(obj.mw_src_frequency);
			for ii = 1:numMwSrc
				if ii <= numExistingMwSrc && obj.mw_src_frequency(ii) == val(ii)
					obj.needs_mwfreq_setup(ii) = false;
                else
					obj.needs_mwfreq_setup(ii) = true;
				end
			end
			obj.mw_src_frequency = val;
        end
		function set.zdc_src(obj,val)
			% has some implicit rules, thus kept private
            numExistingDCSrc = numel(obj.zdc_src);
			numDCSrc2Add = numel(val)-numExistingDCSrc;
            obj.zdc_src = val;
			if numDCSrc2Add
				obj.needs_zdc_setup = ...
					[obj.needs_zdc_setup,...
					logical(zeros(1,numDCSrc2Add))];
				obj.zdc_amp = [obj.zdc_amp,...
					NaN*zeros(1,numDCSrc2Add)];
			end
		end
		function set.zdc_amp(obj,val)
			numZdcSrc = numel(obj.zdc_src);
            if numel(val) ~= numZdcSrc
                throw(MException('sqc_op_pysical_operator:invalidInput',...
					'size of zdc_amp not matching the numbers of zdc_src.'));
            end
			
			numExistingDCSrc = numel(obj.zdc_amp);
			for ii = 1:numZdcSrc
				if ii <= numExistingDCSrc && obj.zdc_amp(ii) == val(ii)
					obj.needs_zdc_setup(ii) = false;
                else
					obj.needs_zdc_setup(ii) = true;
				end
			end
			obj.zdc_amp = val;
        end
%         function val = get.length(obj)
%             val = 0;
%             obj.GenWave(); % todo, get length in a more efficient way
%             for ii = 1:length(obj.xy_wv)
%                 if ~isempty(obj.xy_wv{ii})
%                     val = max(val,obj.xy_wv{ii}.length);
%                 end
%             end
%             for ii = 1:length(obj.z_wv)
%                 if ~isempty(obj.z_wv{ii})
%                     val = max(val,obj.z_wv{ii}.length);
%                 end
%             end
%         end
        function val = get.gate_buffer(obj)
            val = sqc.op.physical.operator.gateBuffer();
        end
        function val = get.all_qubits(obj)
            val = sqc.op.physical.operator.allQubits();
        end
        function val = get.all_qubits_names(obj)
            val = sqc.op.physical.operator.allQubitNames();
        end
        function Run(obj)
            obj.Prep();
            obj.GenWave();
            for ii = 1:numel(obj.xy_wv)
                if isempty(obj.xy_wv{ii})
                    continue;
                end
                obj.xy_wv{ii}.output_delay = [obj.delay_xy_i(ii),obj.delay_xy_q(ii)]...
                    + obj.qubits{ii}.syncDelay_xy;
                obj.xy_wv{ii}.SendWave();
            end
			zXTalkQubits2Add = {};
			xTalkSrcIdx = [];
			xTalkCoef = [];
			for ii = 1:numel(obj.z_wv) % correct z cross talk
                if isempty(obj.z_wv{ii})
                    continue;
                end
                xTalkData = reshape(obj.qubits{ii}.xTalk_z,3,[]);
                if isempty(xTalkData)
                    continue;
                end
				xTalk_zQubit_names = xTalkData(1,:);
				for jj = 1: numel(xTalk_zQubit_names)
                    idx = qes.util.find(xTalk_zQubit_names{jj},obj.all_qubits);
					if isempty(idx) %to future version: move all settings constraints into settings manager,
								% implemented as a database, phase out the necessity to do settings check
								% in operations.
						throw(MException('sqc_op_pysical_operator:invalidSetting',...
							sprintf('the crosstalk qubit %s of qubit %s dose not exist or not a selected/working qubit.',...
								xTalk_zQubit_names{jj},obj.qubits{ii}.name)));
                    end
                    xQ = obj.all_qubits{idx};
					xtalk = xTalkData{2,jj};
					q2c_idx = qes.util.find(xTalk_zQubit_names{jj},obj.qubits);
					if isempty(q2c_idx)
						zXTalkQubits2Add = [zXTalkQubits2Add,xQ];
						xTalkCoef = [xTalkCoef,xtalk];
						xTalkSrcIdx = [xTalkSrcIdx,ii];
						continue;
					end
					if isempty(obj.z_wv{q2c_idx})
						obj.z_wv{q2c_idx} = -xtalk*obj.z_wv{ii};
					else
						obj.z_wv{q2c_idx} = obj.z_wv{q2c_idx}-xtalk*obj.z_wv{ii};
					end
				end
            end   
            for ii = 1:numel(obj.z_wv)
                if isempty(obj.z_wv{ii})
                    continue;
                end
                obj.z_wv{ii}.output_delay = obj.delay_z(ii) + obj.qubits{ii}.syncDelay_z;
                obj.z_wv{ii}.SendWave();
            end
			zWv2Add = {};
			for ii = 1:numel(zXTalkQubits2Add)
				add2Idx = find(zXTalkQubits2Add{ii},zXTalkQubits2Add(1:ii-1));
				if ~isempty(add2Idx)
					awg_backup = zWv2Add{add2Idx}.awg;
					awgchnl_backup = zWv2Add{add2Idx}.awgchnl;
					zWv2Add{add2Idx} = zWv2Add{add2Idx} -xTalkCoef(ii)*obj.z_wv{xTalkSrcIdx(ii)}; 
					zWv2Add{add2Idx}.awg = awg_backup;
					zWv2Add{add2Idx}.awgchnl = awgchnl_backup;
				else
					zWv2Add{end+1} = -xTalkCoef(ii)*obj.z_wv{xTalkSrcIdx(ii)}; 
					da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                        'name',zXTalkQubits2Add{ii}.channels.z_pulse.instru);
					zWv2Add{end}.awg = da;
					zWv2Add{end}.awgchnl = [zXTalkQubits2Add{ii}.channels.z_pulse.chnl];
				end
			end
			for ii = 1:numel(zWv2Add)
				zWv2Add{ii}.SendWave();
			end
        end
        function delete(obj)
%			% relinquish occupied resources for them to be available for other applications
%             for ii = 1:numel(obj.zdc_src)	% obsolete, taken of dc and mw chnls are made non exclusive, 17/04/01
%                 if isvalid(obj.zdc_src{ii}) % can not do this: the zdc_src or mw_src reference might be used in another operator
%                     obj.zdc_src{ii}.delete();
%                 end
%             end
%             for ii = 1:obj.mw_src
%                 if isvalid(obj.mw_src{ii})
%                     obj.mw_src{ii}.delete();
%                 end
%             end
        end
    end
    methods (Hidden = true)
        function GenWave(obj)
            % to subclasses: redefine your own GenWave.
            % operator(base) objects must have empty GenWave methods, do not add any code!
            % pass
        end
        function Prep(obj)
            % do necessary preparations before run
			numMwSrc = numel(obj.mw_src);
			if numMwSrc ~= numel(obj.mw_src_power)
				throw(MException('QOS_operator:MwPowerNotSet','mw power of some channnels are not set.'));
			elseif numMwSrc ~= numel(obj.mw_src_frequency)
				throw(MException('QOS_operator:MwFreqNotSet','mw frequency of some channnels are not set.'));
			end
			for ii = 1:numMwSrc
				if obj.needs_mwpower_setup(ii)
					obj.mw_src{ii}.power = obj.mw_src_power(ii);
				end
				if obj.needs_mwfreq_setup(ii)
					obj.mw_src{ii}.frequency = obj.mw_src_frequency(ii);
				end
				if obj.needs_mwpower_setup(ii) || obj.needs_mwfreq_setup(ii)
					obj.mw_src{ii}.on = true;
				end
				obj.needs_mwpower_setup(ii) = false;
				obj.needs_mwfreq_setup(ii) = false;
			end
			
			numDCSrc = numel(obj.zdc_src);
			if numDCSrc ~= numel(obj.zdc_amp)
				throw(MException('QOS_operator:zdcAmpNotSet','dc value of some channnels are not set.'));
			end
			for ii = 1:numDCSrc
				if obj.needs_zdc_setup(ii)
					obj.zdc_src{ii}.dcval = obj.zdc_amp(ii);
					obj.zdc_src{ii}.on = true;
					obj.needs_zdc_setup(ii) = false;
				end
			end  
        end
		function obj = mtimes(obj2, obj1)
            % ordering changed from [right to left] to [left to right] for convinience
%        function obj = mtimes(obj1, obj2)
%            % implement regular matrix, scalar multiplication and gate operation on a quantum state
%            % order: second applied first to follow the quantum mechanics
%            % convention: U1U2|s>, U2 is applied to state |s> first

% checking removed for efficiency, the caller has to gaurante the validity
            if ~isa(obj1,'sqc.op.physical.operator') || ~isa(obj2,'sqc.op.physical.operator')
                throw(MException('sqc_op_pysical_operator:invalidInput',...
                    'at least one of obj1, obj2 is not a sqc.op.physical.operator class object.'));
            end

			if isempty(obj2)
				obj =  obj1;
				return;
			elseif isempty(obj1)
				obj = obj2;
				return;
			end

            GB = obj1.gate_buffer; % gate_buffer is global
            obj1.GenWave();
            obj = sqc.op.physical.operator(obj2);
            obj.length = obj.length + obj1.length + GB;
            addIdx = [];
            obj2ln = obj2.length;
            for ii = 1:numel(obj1.qubits)
				idx = qes.util.find(obj1.qubits{ii},obj2.qubits);
                if ~isempty(idx)
                    if ~isempty(obj1.xy_wv{ii})
                        if ~isempty(obj2.xy_wv{idx})
                            obj.xy_wv{idx} = [obj2.xy_wv{idx},...
                                    qes.waveform.spacer(GB),obj1.xy_wv{ii}];
                        else
                            obj.xy_wv{idx} = [qes.waveform.spacer(obj2ln+GB),...
                                obj1.xy_wv{ii}];
                        end
						obj.xy_wv{idx}.awg = obj1.xy_wv{ii}.awg; 
                        obj.xy_wv{idx}.awgchnl = obj1.xy_wv{ii}.awgchnl;
                    elseif ~isempty(obj2.xy_wv{idx})
						obj.xy_wv{idx} = [obj2.xy_wv{idx},...
                            qes.waveform.spacer(GB+obj1.length)];
						obj.xy_wv{idx}.awg = obj2.xy_wv{idx}.awg; 
                        obj.xy_wv{idx}.awgchnl = obj2.xy_wv{idx}.awgchnl;
					end
                    if ~isempty(obj1.z_wv{ii})
                        if ~isempty(obj2.z_wv{idx})
                            obj.z_wv{idx} = [obj2.z_wv{idx},...
                                    qes.waveform.spacer(GB),obj1.z_wv{ii}];
                        else
                            obj.z_wv{idx} = [qes.waveform.spacer(GB+obj2ln),...
                                obj1.z_wv{ii}];
                        end
						obj.z_wv{idx}.awg = obj1.z_wv{ii}.awg; 
                        obj.z_wv{idx}.awgchnl = obj1.z_wv{ii}.awgchnl;
                    elseif ~isempty(obj2.z_wv{idx})
						obj.z_wv{idx} = [obj2.z_wv{idx},...
                                    qes.waveform.spacer(GB+obj1.length)];
						obj.z_wv{idx}.awg = obj2.z_wv{idx}.awg;
                        obj.z_wv{idx}.awgchnl = obj2.z_wv{idx}.awgchnl;
					end
                else
                    addIdx = [addIdx, ii];
                end
            end
            obj.qubits = [obj.qubits,obj1.qubits(addIdx)];
            obj.delay_xy_i = [obj.delay_xy_i, obj1.delay_xy_i(addIdx)];
            obj.delay_xy_q = [obj.delay_xy_q, obj1.delay_xy_q(addIdx)];
            obj.delay_z = [obj.delay_z, obj1.delay_z(addIdx)];
            for ii = 1:numel(addIdx)
                if ~isempty(obj1.xy_wv{addIdx(ii)})
                    obj.xy_wv{end+1} = [qes.waveform.spacer(GB+obj2ln),...
                        obj1.xy_wv{addIdx(ii)}];
                    obj.xy_wv{end}.awg = obj1.xy_wv{addIdx(ii)}.awg;
                    obj.xy_wv{end}.awgchnl = obj1.xy_wv{addIdx(ii)}.awgchnl;
                end
                if ~isempty(obj1.z_wv{addIdx(ii)})
                    obj.z_wv{end+1} = [qes.waveform.spacer(GB+obj2ln),...
                        obj1.z_wv{addIdx(ii)}];
                    obj.z_wv{end}.awg = obj1.z_wv{addIdx(ii)}.awg;
                    obj.z_wv{end}.awgchnl = obj1.z_wv{addIdx(ii)}.awgchnl;
                end
            end

			mwSrcIdx2Add = [];
			for ii = 1:numel(obj1.mw_src)
				idx = qes.util.find(obj1.mw_src{ii},obj.mw_src);
				if ~isempty(idx)
					if obj.mw_src_power(idx) ~= obj1.mw_src_power(ii) ||...
						obj.mw_src_frequency(idx) ~= obj1.mw_src_frequency(ii)
						throw(MException('QOS_operator:confictingSettings',...
							'the two operators have conficting mw settings.'));
					end
					obj.needs_mwpower_setup(idx) =...
						obj.needs_mwpower_setup(idx)*obj1.needs_mwpower_setup(ii);
					obj.needs_mwfreq_setup(idx) =...
						obj.needs_mwfreq_setup(idx)*obj1.needs_mwfreq_setup(ii);
				else
					mwSrcIdx2Add = [mwSrcIdx2Add,ii];
				end
			end
			if ~isempty(mwSrcIdx2Add)
				obj.mw_src = [obj.mw_src, obj1.mw_src(mwSrcIdx2Add)];
				obj.mw_src_power(end-numel(mwSrcIdx2Add)+1:end) =...
                    obj1.mw_src_power(mwSrcIdx2Add);
				obj.needs_mwpower_setup(end-numel(mwSrcIdx2Add)+1:end) = ...
					obj1.needs_mwpower_setup(mwSrcIdx2Add);
				obj.mw_src_frequency(end-numel(mwSrcIdx2Add)+1:end) = ...
                    obj1.mw_src_frequency(mwSrcIdx2Add);
				obj.needs_mwfreq_setup(end-numel(mwSrcIdx2Add)+1:end) = ...
					obj1.needs_mwfreq_setup(mwSrcIdx2Add);
			end

			dcSrcIdx2Add = [];
			for ii = 1:numel(obj1.zdc_src)
				idx = qes.util.find(obj1.zdc_src{ii},obj.zdc_src);
				if ~isempty(idx)
					if obj.zdc_amp(idx) ~= obj1.zdc_amp(ii)
						throw(MException('QOS_operator:confictingSettings',...
							'the two operators have conficting dc settings.'));
					end
					obj.needs_zdc_setup(idx) =...
						obj.needs_zdc_setup(idx)*obj1.needs_zdc_setup(ii);
				else
					dcSrcIdx2Add = [dcSrcIdx2Add,ii];
				end
			end
			if ~isempty(dcSrcIdx2Add)
				obj.zdc_src = [obj.zdc_src, obj1.zdc_src(dcSrcIdx2Add)];
				obj.zdc_amp(end-numel(dcSrcIdx2Add)+1:end) = ...
                    obj1.zdc_amp(dcSrcIdx2Add);
				obj.needs_zdc_setup(end-numel(dcSrcIdx2Add)+1:end) = ...
					obj1.needs_zdc_setup(dcSrcIdx2Add);
			end
			
			% logical_op property will be removed
            % if ~isempty(obj1.logical_op) && ~isempty(obj2.logical_op)
                % obj.logical_op = obj1.logical_op*obj2.logical_op;
				% obj.logical_op = obj2.logical_op*obj1.logical_op;
            % end
        end
        function obj = times(obj1, obj2)
           % implement .* as Kronecker tensor product
           obj = [obj1, obj2];
        end
		function obj = vertcat(varargin)
			% implement [] as Kronecker tensor product
			obj = horzcat(varargin);
		end
%        function obj = times(obj1, obj2)
%            % implement .* as Kronecker tensor product
		function obj = horzcat(varargin)
            % implement [] as Kronecker tensor product
			
			numGates = numel(varargin);
			if numGates == 1
				obj = copy(varargin{1});
				return;
			end
			if numGates > 2
				obj = copy(varargin{1});
				for ii = 2:numGates
					obj = [obj,varargin{ii}];
				end
				return;
			end
			if isempty(varargin{1})
				obj =  varargin{2};
				return;
			elseif isempty(varargin{2})
				obj = varargin{1};
				return;
			end
			obj1 = varargin{2};
			obj2 = varargin{1};
            if ~isa(obj1,'sqc.op.physical.operator') || ~isa(obj2,'sqc.op.physical.operator')
                throw(MException('sqc_op_pysical_operator:invalidInput',...
					'at least one of obj1, obj2 is not a sqc.op.physical.operator class object.'));
            end
            obj1.GenWave();
            obj = sqc.op.physical.operator(obj2);
            addIdx = [];
			dln = obj2.length - obj1.length;
            if dln < 0
                obj.length = obj1.length;
                numQs = numel(obj.xy_wv);
                for ii = 1:numQs
                    if isempty(obj.xy_wv{ii})
                        continue;
                    end
                    awg_ = obj.xy_wv{ii}.awg;
                    awgChnl_ = obj.xy_wv{ii}.awgchnl;
                    obj.xy_wv{ii} = [obj.xy_wv{ii},qes.waveform.spacer(-dln)];
                    obj.xy_wv{ii}.awg = awg_; 
                    obj.xy_wv{ii}.awgchnl = awgChnl_;
                end
                for ii = 1:numQs
                    if isempty(obj.z_wv{ii})
                        continue;
                    end
                    awg_ = obj.z_wv{ii}.awg;
                    awgChnl_ = obj.z_wv{ii}.awgchnl;
                    obj.z_wv{ii} = [obj.z_wv{ii},qes.waveform.spacer(-dln)];
                    obj.z_wv{ii}.awg = awg_; 
                    obj.z_wv{ii}.awgchnl = awgChnl_;
                end
            end
            for ii = 1:numel(obj1.qubits)
				idx = qes.util.find(obj1.qubits{ii},obj.qubits);
                if ~isempty(idx)
                    if ~isempty(obj1.xy_wv{ii})
                        if ~isempty(obj2.xy_wv{idx})
                            obj.xy_wv{idx} = obj2.xy_wv{idx}+obj1.xy_wv{ii};
                        else
							if dln > 0
								obj.xy_wv{idx} = [obj1.xy_wv{ii},...
									qes.waveform.spacer(dln)];
							else
								obj.xy_wv{idx} = obj1.xy_wv{ii};
							end
                        end
                        obj.xy_wv{idx}.awg = obj1.xy_wv{ii}.awg;
                        obj.xy_wv{idx}.awgchnl = obj1.xy_wv{ii}.awgchnl; 
%                      elseif ~isempty(obj2.xy_wv{idx}) && dln < 0
% 							obj.xy_wv{idx} = [obj2.xy_wv{idx},...
% 									qes.waveform.spacer(-dln)];
%                         obj.xy_wv{idx}.awg = obj2.xy_wv{idx}.awg;
%                         obj.xy_wv{idx}.awgchnl = obj2.xy_wv{idx}.awgchnl; 
					end
                    if ~isempty(obj1.z_wv{ii})
                        if ~isempty(obj2.z_wv{idx})
                            obj.z_wv{idx} = obj2.z_wv{idx}+obj1.z_wv{ii};
                        else
							if dln > 0
								obj.z_wv{idx} = [obj1.z_wv{ii},...
									qes.waveform.spacer(dln)];
							else
								obj.z_wv{idx} = obj1.z_wv{ii};
							end
                        end
                        obj.z_wv{idx}.awg = obj1.z_wv{ii}.awg; 
                        obj.z_wv{idx}.awgchnl = obj1.z_wv{ii}.awgchnl; 
%                      elseif ~isempty(obj2.z_wv{idx}) && dln < 0
% 							obj.z_wv{idx} = [obj2.z_wv{idx},...
% 									qes.waveform.spacer(-dln)];
% 						obj.z_wv{idx}.awg = obj2.z_wv{idx}.awg; 
%                         obj.z_wv{idx}.awgchnl = obj2.z_wv{idx}.awgchnl;
					end
                else
                    addIdx = [addIdx, ii];
                end
            end
            obj.qubits = [obj.qubits,obj1.qubits(addIdx)];
            obj.delay_xy_i = [obj.delay_xy_i, obj1.delay_xy_i(addIdx)];
            obj.delay_xy_q = [obj.delay_xy_q, obj1.delay_xy_q(addIdx)];
            obj.delay_z = [obj.delay_z, obj1.delay_z(addIdx)];
            obj2numQ = numel(obj.xy_wv);
            obj.xy_wv = [obj.xy_wv,cell(1,numel(addIdx))];
            obj.z_wv = [obj.z_wv,cell(1,numel(addIdx))];
            for ii = 1:numel(addIdx)
                wvInd = obj2numQ+ii;
                if ~isempty(obj1.xy_wv{addIdx(ii)})
					if dln > 0
						obj.xy_wv{wvInd} = [obj1.xy_wv{addIdx(ii)},...
									qes.waveform.spacer(dln)];
                        obj.xy_wv{wvInd}.awg = obj1.xy_wv{addIdx(ii)}.awg;
                        obj.xy_wv{wvInd}.awgchnl = obj1.xy_wv{addIdx(ii)}.awgchnl;
					else
						obj.xy_wv{wvInd} = obj1.xy_wv{addIdx(ii)};
                    end
                end
                if ~isempty(obj1.z_wv{addIdx(ii)})
					if dln > 0
						obj.z_wv{wvInd} = [obj1.z_wv{addIdx(ii)},...
									qes.waveform.spacer(dln)];
                        obj.z_wv{end}.awg = obj1.z_wv{addIdx(ii)}.awg;
                        obj.z_wv{end}.awgchnl = obj1.z_wv{addIdx(ii)}.awgchnl;
					else
						obj.z_wv{wvInd} = obj1.z_wv{addIdx(ii)};
                    end
                end
            end
			
			mwSrcIdx2Add = [];
			for ii = 1:numel(obj1.mw_src)
				idx = qes.util.find(obj1.mw_src{ii},obj.mw_src);
				if ~isempty(idx)
					if obj.mw_src_power(idx) ~= obj1.mw_src_power(ii) ||...
						obj.mw_src_frequency(idx) ~= obj1.mw_src_frequency(ii)
						throw(MException('QOS_operator:confictingSettings',...
							'the two operators have conficting mw settings.'));
					end
					obj.needs_mwpower_setup(idx) =...
						obj.needs_mwpower_setup(idx)*obj1.needs_mwpower_setup(ii);
					obj.needs_mwfreq_setup(idx) =...
						obj.needs_mwfreq_setup(idx)*obj1.needs_mwfreq_setup(ii);
				else
					mwSrcIdx2Add = [mwSrcIdx2Add,ii];
				end
			end
			if ~isempty(mwSrcIdx2Add)
				obj.mw_src = [obj.mw_src, obj1.mw_src(mwSrcIdx2Add)];
				obj.mw_src_power(end-numel(mwSrcIdx2Add)+1:end) = ...
                    obj1.mw_src_power(mwSrcIdx2Add);
				obj.needs_mwpower_setup(end-numel(mwSrcIdx2Add)+1:end) = ...
					obj1.needs_mwpower_setup(mwSrcIdx2Add);
				obj.mw_src_frequency(end-numel(mwSrcIdx2Add)+1:end) = ...
                    obj1.mw_src_frequency(mwSrcIdx2Add);
				obj.needs_mwfreq_setup(end-numel(mwSrcIdx2Add)+1:end) = ...
					obj1.needs_mwfreq_setup(mwSrcIdx2Add);
			end

			dcSrcIdx2Add = [];
			for ii = 1:numel(obj1.zdc_src)
				idx = qes.util.find(obj1.zdc_src{ii},obj.zdc_src);
				if ~isempty(idx)
					if obj.zdc_amp(idx) ~= obj1.zdc_amp(ii)
						throw(MException('QOS_operator:confictingSettings',...
							'the two operators have conficting dc settings.'));
					end
					obj.needs_zdc_setup(idx) =...
						obj.needs_zdc_setup(idx)*obj1.needs_zdc_setup(ii);
				else
					dcSrcIdx2Add = [dcSrcIdx2Add,ii];
				end
			end
			if ~isempty(dcSrcIdx2Add)
				obj.zdc_src = [obj.zdc_src, obj1.zdc_src(dcSrcIdx2Add)];
				obj.zdc_amp(end-numel(dcSrcIdx2Add)+1:end) =...
                    obj1.zdc_amp(dcSrcIdx2Add);
				obj.needs_zdc_setup(end-numel(dcSrcIdx2Add)+1:end) = ...
					obj1.needs_zdc_setup(dcSrcIdx2Add);
			end
			
%             if ~isempty(obj1.logical_op) && ~isempty(obj2.logical_op)
%                  % operators acting on the same qubits set(or partially) can not form Kronecker tensor product
%                  % intersect for objects has to be re implemented
%                  if isempty(intersect(obj1.qubits,obj2.qubits))
%                      % by the identity kron(A,B) = kron(A,I)*kron(I,B) we
%                      % have:
%                      obj.logical_op = obj1.logical_op*obj2.logical_op;
%                  end
%              end
        end
		function obj = mpower(obj1,n)
            % power of operator object
            if n < 0 || round(n) ~= n
                error('waveform:PowerError','power of a waveform object should be a non negative integer.');
            end
            if n == 0
				numQ = numel(obj1.qubits);
				obj = sqc.op.physical.gate.I(obj1.qubits{1});
				for ii = 2:numQ
					obj = sqc.op.physical.gate.I(obj1.qubits{ii}).*obj;
				end
            elseif n == 1
                obj = copy(obj1);
            else
                obj = obj1;
                for ii = 2:n
                    obj = obj1*obj;
                end
            end
        end
    end
    methods (Static = true)
        function gate_buffer = gateBuffer(reload)
            persistent gate_buffer_
            if isempty(gate_buffer_) || (nargin && reload)
                QS = qes.qSettings.GetInstance();
                gate_buffer_ = QS.loadSSettings({'public','gateBuffer'});
            end
            gate_buffer = gate_buffer_;
        end
        function all_qubits_ = allQubits(reload)
            persistent all_qubits
            if isempty(all_qubits) || (nargin && reload)
                all_qubits = sqc.util.loadQubits();
            end
            all_qubits_ = all_qubits;
        end
        function all_qubit_names_ = allQubitNames(reload)
            persistent all_qubit_names
            if isempty(all_qubit_names) || (nargin && reload)
                all_qubit_names = sqc.util.loadQubitNames();
            end
            all_qubit_names_ = all_qubit_names;
        end
        
        function PlotReal(obj,ax)
            % plot the real part of the operator matrix
            if isempty(obj.logical_op)
                error('this physical operator has no logical operator');
            end
            if nargin > 1
                obj.logical_op.PlotReal(obj.logical_op,ax);
            else
                obj.logical_op.PlotReal(obj.logical_op);
            end
        end
        function PlotImag(obj,ax)
            % plot the imaginary part of the operator matrix
            if isempty(obj.logical_op)
                error('this physical operator has no logical operator');
            end
            if nargin > 1
                obj.logical_op.PlotImag(obj.logical_op,ax);
            else
                obj.logical_op.PlotImag(obj.logical_op);
            end
        end
    end
%     enumeration % type enumeration
%         
%     end
end