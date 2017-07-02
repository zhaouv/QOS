classdef resonatorReadout < qes.measurement.prob
    % a resonator readout multiple qubits
% 	% data: 1 by 2^(number of qubits)
    
% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
    
    properties
        n
        delay = 0 % syncDelay is added automatically, this is just a logical dely
        r_amp % expose qubit setting r_amp for tunning
        mw_src_power % expose qubit setting r_uSrcPower for tunning
        mw_src_frequency % expose qubit setting r_fc for tunning
        
        startWv % wave object to be added before the start of readout waveform
    end
    properties (SetAccess = protected)
        qubits
		jpa
		adDelayStep
    end
    properties (SetAccess = private, GetAccess = protected)
        da
        da_i_chnl
        da_q_chnl
		mw_src
        setupRMWSrc = false;
		
		r_wv

        stateNames
        
        iq_obj
        adSamplingRate
        daSamplingRate
        adRecordLength
        
        jpaRunner
    end
    methods
        function obj = resonatorReadout(qubits)
            if ~iscell(qubits)
                if ~ischar(qubits) && ~isa(qubits,'sqc.qobj.qubit')
                    throw(MException('resonatorReadout:invalidInput',...
						'the input qubits should be a cell array of qubit objects or qubit names.'));
                else
                    qubits = {qubits};
                end
            end
			for ii = 1:numel(qubits)
				if ischar(qubits{ii})
					qubits{ii} = sqc.util.qName2Qubit(qubits{ii});
				end
			end
            prop_names = {'syncDelay_r','r_avg','syncDelay_z','r_fc','r_ln','r_truncatePts','r_uSrcPower',...
                {'channels','r_da_i','instru'},{'channels','r_da_q','instru'},...
                {'channels','r_da_i','chnl'},{'channels','r_da_q','chnl'},...
                {'channels','r_ad_i','instru'},{'channels','r_ad_q','instru'},...
                {'channels','r_ad_i','chnl'},{'channels','r_ad_q','chnl'},...
                {'channels','r_mw','instru'},{'channels','r_mw','chnl'},...
                'r_jpa'};
            b = sqc.util.samePropVal(qubits,prop_names);
            for ii = 1:numel(prop_names)
                if b(ii)
                    continue;
                end
				if iscell(prop_names{ii})
					str = cell2mat(cellfun(@(s_)strcat(s_,'.'),prop_names{ii}, 'UniformOutput', false));
					str(end) = [];
					throw(MException('resonatorReadout:settingsMismatch',...
						'the qubits to readout has different %s setting.',str));
				else
					throw(MException('resonatorReadout:settingsMismatch',...
						'the qubits to readout has different %s setting.',prop_names{ii}));
				end
            end
            
            num_qubits = numel(qubits);

            da_i_names = qubits{1}.channels.r_da_i.instru;
            da_q_names = qubits{1}.channels.r_da_q.instru;
            if ~strcmp(da_q_names,da_i_names)
                throw(MException('resonatorReadout:daMismatch',...
					'can not output I and Q on different awgs.'));
            end

            da_i_chnls = qubits{1}.channels.r_da_i.chnl;
            da_q_chnls = qubits{1}.channels.r_da_q.chnl;
            if da_i_chnls == da_q_chnls
                throw(MException('resonatorReadout:daChnlSettingError',...
					'can not output I and Q on the same channel.'));
            end

            ad_i_names = qubits{1}.channels.r_ad_i.instru;
            ad_q_names = qubits{1}.channels.r_ad_q.instru;
            if ~strcmp(ad_q_names,ad_i_names)
                throw(MException('resonatorReadout:adMismatch',...
					'can not digitize I and Q on different ADs.'));
            end
             
            ad_i_chnls = qubits{1}.channels.r_ad_i.chnl;
            ad_q_chnls = qubits{1}.channels.r_ad_q.chnl;
            if ad_i_chnls == ad_q_chnls
                throw(MException('resonatorReadout:adChnlSettingError',...
					'can not digitize I and Q with the same channel.'));
            end
            
            ad = qes.qHandle.FindByClassProp('qes.hwdriver.hardware','name',ad_i_names);
            da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware','name',da_i_names);
            rs = ad.samplingRate/da.samplingRate;
            ad.recordLength = ceil(rs*(qubits{1}.r_ln+ad.delayStep)); % maximum startidx increment is ad.delayStep
            iq_obj = sqc.measure.iq_ustc_ad(ad);
            iq_obj.n = qubits{1}.r_avg;
            iq_obj.upSampleNum = lcm(ad.samplingRate,da.samplingRate)/ad.samplingRate;
            demod_freq = zeros(1,num_qubits);
            for ii = 1:num_qubits
                demod_freq(ii) = qubits{ii}.r_freq- qubits{1}.r_fc;
            end
            iq_obj.freq = demod_freq;
%             iq_obj.startidx = qubits{1}.r_truncatePts(1)+1;
%             iq_obj.endidx = ad.recordLength-qubits{1}.r_truncatePts(2);
            prob_obj = sqc.measure.prob_iq_ustc_ad_j(iq_obj,qubits);

            obj = obj@qes.measurement.prob(prob_obj);
            obj.n = prob_obj.n;
            obj.qubits = qubits;
            obj.stateNames = prob_obj.stateNames;
            obj.iq_obj = iq_obj;
            obj.adSamplingRate = ad.samplingRate;
            obj.daSamplingRate = da.samplingRate;
			uSrc = qes.qHandle.FindByClassProp('qes.hwdriver.hardware','name',qubits{1}.channels.r_mw.instru);
            if isempty(uSrc)
                throw(MException('QOS_resonatorReadout:hwNotFound',...
                    '%s not found in hardware pool, make sure it is selected in hardware settings and seccessfully created.',...
                    qubits{1}.channels.r_mw.instru));
            end
            obj.mw_src = uSrc.GetChnl(qubits{1}.channels.r_mw.chnl);
            obj.mw_src_power = qubits{1}.r_uSrcPower;
            obj.mw_src_frequency = qubits{1}.r_fc;
            obj.da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware','name',da_i_names);
            obj.da_i_chnl = da_i_chnls;
            obj.da_q_chnl = da_q_chnls;
            r_amp_ = zeros(1,num_qubits);
            for ii = 1:num_qubits
                r_amp_(ii) = obj.qubits{ii}.r_amp;
            end
            obj.r_amp = r_amp_;
            obj.adRecordLength = ad.recordLength;
            obj.adDelayStep = ad.delayStep;

            if ~isempty(qubits{1}.r_jpa)
				prop_names = {'r_jpa_biasAmp','r_jpa_pumpFreq','r_jpa_pumpPower','r_jpa_pumpAmp','r_jpa_longer'};
				b = sqc.util.samePropVal(qubits,prop_names);
				for ii = 1:numel(prop_names)
					if b(ii)
						continue;
					end
					throw(MException('resonatorReadout:settingsMismatch',...
						'the qubits to readout has different %s settings.',prop_names{ii}));
                end
                jpa = sqc.util.qName2Obj(qubits{1}.r_jpa);
                jpa.pumpAmp = qubits{1}.r_jpa_pumpAmp; % 
				jpa.pumpFreq = qubits{1}.r_jpa_pumpFreq; % 
				jpa.pumpPower = qubits{1}.r_jpa_pumpPower; % 
				jpa.biasAmp = qubits{1}.r_jpa_biasAmp; %
                jpa.opDuration = qubits{1}.r_ln + 2*qubits{1}.r_jpa_longer;
                obj.jpaRunner = sqc.util.jpaRunner(jpa);
            end
            obj.delay = 0;
            obj.numericscalardata = false;
        end
        function set.qubits(obj,val)
            if ~iscell(val)
                val = {val};
            end
            for ii = 1:numel(val)
                if ~isa(val{ii},'sqc.qobj.qubit')
                    throw(MException('resonatorReadout:invalidInput',...
						'at least one of qubits is not a sqc.qobj.qubit class object.'));
                end
            end
            obj.qubits = val;
        end
        function set.mw_src_power(obj,val)
            if numel(val) ~= numel(obj.mw_src)
                throw(MException('resonatorReadout:invalidInput',...
					'size of mw_src_power not matching the numbers of mw_src.'));
            end
            obj.mw_src_power = val;
            obj.setupRMWSrc = true;
        end
        function set.mw_src_frequency(obj,val)
            if numel(val) ~= numel(obj.mw_src)
                throw(MException('resonatorReadout:invalidInput',...
					'size of mw_src_frequency not matching the numbers of mw_src.'));
            end
            obj.mw_src_frequency = val;
            obj.setupRMWSrc = true;
        end
        function set.r_amp(obj,val)
            if numel(val) ~= numel(obj.qubits)
                throw(MException('resonatorReadout:invalidInput',...
					'size of r_amp not matching the numbers of qubits.'));
            end
            obj.r_amp = val;
        end
		function set.delay(obj,val)
            if isempty(val) || val < 0
                throw(MException('resonatorReadout:invalidInput',...
					'delay value empty or negative.'));
            end
            if ~isempty(obj.startWv) && wvObj.length > val
                throw(MException('QOS_resonatorReadout:delayTooShort',...
                    sprintf('startWv length(%0.0f) exceeding delay(%0.0f).',...
                    wvObj.length,val)));
            end
 			obj.delay = val;
            vSamplingRate = lcm(obj.adSamplingRate,obj.daSamplingRate);
            dd = (obj.delay - obj.adDelayStep*floor(obj.delay/obj.adDelayStep))*...
                vSamplingRate/obj.daSamplingRate;
            obj.iq_obj.startidx = obj.qubits{1}.r_truncatePts(1)*obj.iq_obj.upSampleNum+dd+1;
            obj.iq_obj.endidx = (obj.adRecordLength-obj.qubits{1}.r_truncatePts(2))*...
                obj.iq_obj.upSampleNum...
                -obj.adDelayStep*vSamplingRate/obj.daSamplingRate+dd;
            
            if ~isempty(obj.qubits{1}.r_jpa)
                obj.jpaRunner.jpa.startDelay = obj.delay-obj.qubits{1}.r_jpa_longer; % all qubits has the same r_jpa_longer value, asserted during object construction.
            end
        end
        function set.startWv(obj,wvObj)
            % append a waveform to the start of the readout waveform
            if ~isa(wvObj,'qes.waveform.waveform')
                throw(MException('QOS_resonatorReadout:invalidInput',...
                    sprintf('startWv should be a waveform object, %s given',...
                    class(wvObj))));
            elseif wvObj.length > obj.delay
                throw(MException('QOS_resonatorReadout:startWvTooLong',...
                    sprintf('startWv length(%0.0f) exceeding delay(%0.0f).',...
                    wvObj.length,obj.delay)));
            end
            obj.startWv = wvObj;
        end
        function Run(obj)
            obj.GenWave();
            obj.Prep();
            Run@qes.measurement.prob(obj); % important
            wvObj = obj.r_wv;

            delay_ = obj.adDelayStep*floor((obj.delay)/obj.adDelayStep);
            wvObj.awg.SetTrigOutDelay(obj.r_wv.awgchnl,delay_);
            
% 			obj.r_wv.awg.SetTrigOutDelay(obj.r_wv.awgchnl,obj.delay);
            obj.r_wv.SendWave();
            if ~isempty(obj.jpaRunner)
                obj.jpaRunner.Run();
            end
            obj.data = obj.instrumentObject();
            % extradata: 1 by numQubits cell
            obj.extradata = obj.instrumentObject.extradata;
            obj.dataready = true;
        end
    end
    methods (Access = private)
        function GenWave(obj)
            num_qubits = numel(obj.qubits);
			for ii = 1:num_qubits
                wv_{ii} = feval(['sqc.wv.',obj.qubits{ii}.r_wvTyp],obj.qubits{ii}.r_ln);
                wvSettings = obj.qubits{ii}.r_wvSettings;
                if ~isempty(wvSettings)
                    fnames = fieldnames(wvSettings);
                    for jj = 1:numel(fnames)
                        wv_{ii}.(fnames{jj}) = wvSettings.(fnames{jj});
                    end
                end
                wv_{ii}.amp = obj.r_amp(ii);
                wv_{ii}.df = (obj.qubits{ii}.r_freq - obj.qubits{ii}.r_fc)/obj.da.samplingRate;
                if ~isempty(obj.startWv)
                    df = (obj.qubits{ii}.r_freq - obj.qubits{ii}.r_fc)/obj.da.samplingRate;
                    wv_{ii}.phase = 2*pi*df*obj.startWv.length;
                end
            end
            obj.r_wv = wv_{1};
            for ii = 2:num_qubits
                obj.r_wv = obj.r_wv + wv_{ii};
            end
            if ~isempty(obj.startWv)
                obj.r_wv = [obj.startWv, obj.r_wv];
            end
            obj.r_wv.awg = obj.da;
            obj.r_wv.awgchnl = [obj.da_i_chnl,obj.da_q_chnl];
            obj.r_wv.hw_delay = true; % important
            obj.r_wv.output_delay = obj.delay+obj.qubits{1}.syncDelay_r; % syncDelay_z is added as a small calibration.
            if ~isempty(obj.startWv)
                obj.r_wv.output_delay = obj.r_wv.output_delay-obj.startWv.length;
            end
        end

        function Prep(obj)
            % do necessary preparations before run
            if obj.setupRMWSrc
                obj.mw_src.power = obj.mw_src_power;
                obj.mw_src.frequency = obj.mw_src_frequency;
                obj.mw_src.on = true;
                obj.setupRMWSrc = false;
            end
        end
    end
end