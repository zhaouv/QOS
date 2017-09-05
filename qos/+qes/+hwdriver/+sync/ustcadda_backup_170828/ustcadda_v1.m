% 	FileName:USTCADDA.m
% 	Author:GuoCheng
% 	E-mail:fortune@mail.ustc.edu.cn
% 	All right reserved @ GuoCheng.
% 	Modified: 2017.7.1
%   Description:The class of ADDA
classdef ustcadda_v1 < qes.hwdriver.icinterface_compatible % extends icinterface_compatible, Yulin Wu
    properties
        runReps = 1             %run repetition
        adRecordLength = 1      % daRecordLength
    end
    
    properties (SetAccess = private)
    
        numDABoards
        numDAChnls
        numADBoards
        numADChnls
    
        daOutputDelayStep
        daTrigDelayStep
        daSamplingRate

        adRange
        adDelayStep % unit: DA sampling points
    end
    
    properties (SetAccess = private) % Yulin Wu
        adTakenChnls
        daTakenChnls
    end
    
    properties(SetAccess = private, GetAccess = private) 
        da_list = []
        ad_list = []
        da_channel_list = []
        ad_channel_list = []
        
        da_master_index = 1
    end
    
    methods % Yulin Wu
        function TakeDAChnls(obj,chnls)
            if any(chnls>length(obj.da_channel_list))
                throw(MException('QOS_ustcadda:daChnlAlreadyTaken','some da channels are taken already'));
            end
            if any(ismember(chnls,obj.daTakenChnls))
                throw(MException('QOS_ustcadda:daChnlAlreadyTaken','some da channels are taken already'));
            end
            obj.daTakenChnls = [obj.daTakenChnls, chnls];
        end
		function ReleaseDAChnls(obj,chnls)
			obj.daTakenChnls = setdiff(obj.daTakenChnls,chnls);
        end
		function TakeADChnls(obj,chnls)
			if any(ismember(chnls,obj.adTakenChnls))
				throw(MException('QOS_ustcadda:adChnlAlreadyTaken','some ad channels are taken already'));
			end
			obj.adTakenChnls = [obj.adTakenChnls, chnls];
		end
		function ReleaseADChnls(obj,chnls)
			obj.adTakenChnls = setdiff(obj.adTakenChnls,chnls);
        end
		function val = GetDAChnlSamplingRate(obj, chnls)
			val = zeros(size(chnls));
			for ii = 1:numel(val)
				val(ii) = obj.da_list(obj.da_channel_list(chnls(ii)).index).da.sample_rate;
			end
        end
		function val = GetADChnlSamplingRate(obj,chnls)
			val = zeros(size(chnls));
			for ii = 1:numel(val)
				val(ii) = obj.ad_list(obj.ad_channel_list(chnls(ii)).index).ad.sample_rate;
			end
        end
        function val = GetTrigInterval(obj)
			val = obj.da_list(obj.da_master_index).da.trig_interval;
		end
    end
    methods (Access = private) % Yulin Wu
        function obj = ustcadda_v1()
            obj.Config();
            obj.Open();
        end
    end
    methods (Static = true)
        function obj = GetInstance() % Yulin Wu
            persistent objlst;
            if isempty(objlst) || ~isvalid(objlst)
                obj = qes.hwdriver.sync.ustcadda_v1();
                objlst = obj;
            else
                obj = objlst;
            end
        end
        function seq = GenerateTrigSeq(count,delay)
            if(mod(count,8) ~= 0)
                count = (floor(count/8)+1);
            else
                count = count/8;
            end
            seq  = zeros(1,16384);
            function_ctrl = 64;     %53-63bits,set trig bits
            trigger_ctrl  = 0;      %48-55bits
            counter_ctrl  = 0;      %32-47bits
            length_wave   = 2;      %16-31bits
            address_wave  = 0;      %0-15bits
            for  k = 1:2:4096       %trig sequence
                seq(4*k-3) = function_ctrl*256 + trigger_ctrl;
                seq(4*k-2) = counter_ctrl;
                seq(4*k-1) = length_wave;
                seq(4*k)   = address_wave;
            end

            if(delay ~= 0)
                function_ctrl = 32;     %53-63bits,set delay bits
                counter_ctrl  = delay-1;%32-47bits,set counter
            else
                function_ctrl = 0;      %zero delay,do not set delay bits.
                counter_ctrl  = 0;
            end
            trigger_ctrl = 0; 
            length_wave  = count;
            address_wave = count;
            for k = 2:2:4096            % delay sequency.
                seq(4*k-3) = function_ctrl*256 + trigger_ctrl;
                seq(4*k-2) = counter_ctrl;
                seq(4*k-1) = length_wave;
                seq(4*k) = address_wave;
            end
        end
        function seq = GenerateContinuousSeq(count)
            seq  = zeros(1,16384);
            if(mod(count,8) ~= 0)
                count = floor(count/8)+1;
            else
                count = count/8;
            end
            for k = 1:4096
                seq(4*k-3) = 0;
                seq(4*k-2) = 0;
                seq(4*k-1) = count;
                seq(4*k) = 0;
            end
        end
    end
    methods
        function Config(obj)
            obj.Close();
            addpath('dlls');
            QS = qes.qSettings.GetInstance();
            s = QS.loadHwSettings('ustcadda');
            obj.numDABoards = length(s.da_boards);
            obj.numADBoards = length(s.ad_boards);
            obj.daOutputDelayStep = s.daOutputDelayStep;
            obj.daTrigDelayStep = s.daTrigDelayStep;
            obj.adDelayStep = s.adDelayStep;
            obj.adRange = s.adRange;
            for k = 1:obj.numDABoards
                obj.da_list(k).da = qes.hwdriver.sync.ustcadda_backend.USTCDAC(...
                    s.da_boards{k}.ip,s.da_boards{k}.port);
                obj.da_list(k).da.name=s.da_boards{k}.name;
                obj.da_list(k).da.channel_amount=s.da_boards{k}.numChnls;
                obj.da_list(k).da.gain=cell2mat(s.da_boards{k}.gain);
                obj.da_list(k).da.sample_rate=s.da_boards{k}.samplingRate;
                obj.da_list(k).da.sync_delay=s.da_boards{k}.syncDelay;
                obj.da_list(k).da.trig_delay = 0;
                obj.da_list(k).da.daTrigDelayOffset =s.da_boards{k}.daTrigDelayOffset;% GuoCheng,20170701
                obj.da_list(k).da.trig_sel=s.trigger_source;
                if isfield(s,'da_master') && s.da_master == k  % GuoCheng, 20170701
                    obj.da_list(k).da.ismaster=true;
                    obj.da_master_index = k;
                end
                obj.da_list(k).mask_plus = 0; %
                obj.da_list(k).mask_min  = 0; %
                obj.da_list(k).da.trig_interval=s.triggerInterval;
                obj.da_list(k).da_trig_delay = 0;
                obj.da_list(k).da.offsetCorr=cell2mat(s.da_boards{k}.offsetCorr);
            end
            for k = 1:length(s.da_chnl_map)
                % da_chnl_map settting format changed, the following
                % lines has been changed accordingly, Yulin Wu, 170526
                chnlMap_i = strsplit(regexprep(s.da_chnl_map{k},'\s+',''),',');
                da_index = round(str2double(chnlMap_i{1}));
                ch = round(str2double(chnlMap_i{2}));
                numDAs = numel(obj.da_list);
                if da_index < 0
                    throw(MException('QOS_ustcadda:badSettings',...
                        sprintf('invalid settings found in da_chnl_map{%0.0f}: DA board index can not be an negative number.',...
                        ii, da_index)));
                elseif da_index > numDAs
                    throw(MException('QOS_ustcadda:badSettings',...
                        sprintf('da_chnl_map{%0.0f} points to DA board #%0.0f while only %0.0f DA boards exist.',...
                        ii, da_index, numDAs)));
                end
                if ch > obj.da_list(da_index).da.channel_amount
					throw(MException('QOS_ustcadda:badSettings',...
                        sprintf('Channel %0.0f dose not exist on DA #%s',ch, obj.da_list(da_index).da.name)));
                end
                obj.da_channel_list(k).index = da_index; % bug fix: obj.da_channel_list(ch) -> obj.da_channel_list(k), Yulin Wu
                obj.da_channel_list(k).ch = ch;

                obj.da_channel_list(k).data = [];
                obj.da_channel_list(k).delay = 0;
            end
            for k = 1:obj.numADBoards
                obj.ad_list(k).ad = qes.hwdriver.sync.ustcadda_backend.USTCADC(s.ad_boards{k}.netcard);
                obj.ad_list(k).ad.sample_rate=s.ad_boards{k}.samplingRate;
                obj.ad_list(k).ad.channel_amount=s.ad_boards{k}.numChnls;
                obj.ad_list(k).ad.mac=s.ad_boards{k}.mac;
				obj.ad_list(k).ad.isdemod = s.ad_boards{k}.demod;
                obj.ad_list(k).ad.window_start = s.ad_boards{k}.window_start;%GuoCheng 20170701
                obj.ad_list(k).ad.window_width = s.ad_boards{k}.window_width;%GuoCheng 20170701
            end
            for k = 1:length(s.ad_chnl_map)
                % ad_chnl_map settting format changed, the following
                % lines has been changed accordingly, Yulin Wu, 170526
                chnlMap_i = strsplit(regexprep(s.ad_chnl_map{k},'\s+',''),',');
                ad_index = round(str2double(chnlMap_i{1}));
                ch = round(str2double(chnlMap_i{2}));
                numADs = numel(obj.ad_list);
                if ad_index < 0
                    throw(MException('QOS_ustcadda:badSettings',...
                        sprintf('invalid settings found in ad_chnl_map{%0.0f}: AD board index can not be an negative number.',...
                        ii, ad_index)));
                elseif ad_index > numADs
                    throw(MException('QOS_ustcadda:badSettings',...
                        sprintf('ad_chnl_map{%0.0f} points to AD board #%0.0f while only %0.0f AD boards exist.',...
                        ii, ad_index, numADs)));
                end
                if ch > obj.ad_list(ad_index).ad.channel_amount
					throw(MException('QOS_ustcadda:badSettings',...
                        sprintf('Channel %0.0f dose not exist on AD #%s',ch, obj.ad_list(ad_index).ad.name)));
                end
                obj.ad_channel_list(k).index = ad_index; % bug fix: obj.ad_channel_list(ch) -> obj.ad_channel_list(k), Yulin Wu
                obj.ad_channel_list(k).ch = ch;
                % obj.da_channel_list(ch).data = []; % bug? Yulin Wu
            end
            obj.numDAChnls = length(obj.da_channel_list);
            obj.numADChnls = length(obj.ad_channel_list);
            obj.adTakenChnls = [];
            obj.daTakenChnls = [];
        end   
        function Close(obj)
            len = length(obj.da_list);
            while(len>0)
                obj.da_list(len).da.Close();
                len = len - 1;
            end
            len = length(obj.ad_list);
            while(len>0)
                obj.ad_list(len).ad.Close();
                len = len - 1;
            end
        end     
        function Open(obj)
            len = length(obj.da_list);
            while(len>0)
                obj.da_list(len).da.Open();
                obj.da_list(len).da.Init();
                len = len - 1;
            end
            len = length(obj.ad_list);
            while(len>0)
                obj.ad_list(len).ad.Open();
                obj.ad_list(len).ad.Init();
                len = len - 1;
            end
        end
        function [I,Q,isSuccessed] = Run(obj,isSample)
            I = 0; Q = 0; ret = -1;isSuccessed = 1;
            obj.da_list(obj.da_master_index).da.SetTrigCount(obj.runReps);
            for k = 1:obj.numDABoards
                obj.da_list(k).da.StartStop((15 - obj.da_list(k).mask_min)*16);
                obj.da_list(k).da.StartStop(obj.da_list(k).mask_plus);
                obj.da_list(k).da.SetTrigDelay(obj.da_list(k).da_trig_delay);
            end
            if(obj.ad_list(1).ad.isdemod || isSample)
               obj.ad_list(1).ad.SetMode(obj.ad_list(1).ad.isdemod);
               obj.ad_list(1).ad.SetSampleDepth(obj.adRecordLength);
               obj.ad_list(1).ad.SetTrigCount(obj.runReps);
            end
            for k=1:obj.numDABoards
                try
                    state = obj.da_list(k).da.CheckStatus();
                    if(state.isSuccessed ~= 1)
                        obj.da_list(k).da.GetReturn(state.position);% Throw an exception.
                    end
                catch
                    obj.da_list(k).da.Close();pause(60);
                    obj.da_list(k).da.Open();
                    isSuccessed = 0;
                end
            end
            while(ret ~= 0)
                obj.ad_list(1).ad.EnableADC(); 
                obj.da_list(obj.da_master_index).da.SendIntTrig();
                if~(isSample == false)
                    [ret,I,Q] = obj.ad_list(1).ad.RecvData(obj.runReps,obj.adRecordLength);
%                     save([datestr(now,'HHMMss') 'data.mat'],'I','Q')
%                     if(ret ~= 0)
%                         disp('重传了');
%                     end
                else
                    ret = 0;
                end
            end
            for k = 1:obj.numDABoards
                obj.da_list(k).mask_plus = 0;
                obj.da_list(k).da_trig_delay = 0;
            end
        end
        function SendWave(obj,channel,data)
            obj.da_channel_list(channel).data = data;
            ch_info = obj.da_channel_list(channel);
            ch_delay = obj.da_channel_list(channel).delay;
            ch = ch_info.ch;
            da_struct = obj.da_list(ch_info.index);
            len = length(data);
            seq = obj.GenerateTrigSeq(len,ch_delay);       
            da_struct.da.WriteSeq(ch,0,seq);
            if(mod(len,8) ~= 0)
                data(len+1:(floor(len/8)+2)*8) = 32768;
            end
            len = length(data);
            data(len+1:len+16) = 32768;
            % added uint16 to do clipping, otherwise DA might do wrap
            % around(65535+N is taken as N-1), this is  unacceptable for
            % qubits measurement applications, Yulin Wu
            % than a ustcadda property, Yulin Wu
            data = uint16(data +...
                obj.da_list(obj.da_channel_list(channel).index).da.offset(obj.da_channel_list(channel).ch)); 
            da_struct.da.WriteWave(ch,0,data);
            if(mod(floor(da_struct.mask_plus/(2^(ch-1))),2) == 0)
                obj.da_list(ch_info.index).mask_plus = da_struct.mask_plus + 2^(ch-1);
            end
        end
        function SendContinuousWave(obj,channel,voltage)
            if(length(voltage) == 1)
                voltage = zeros(1,8) + voltage;
            end
            len = length(voltage);
            if(mod(len,8) ~= 0)                     % 采样点个数不是8的整数倍，需要补齐
                t = floor(len/8);
                if(max(voltage) == min(voltage))    %前面是直流
                    voltage(length(voltage)+1:t*8+8) = voltage(1);
                else
                    voltage(length(voltage)+1:t*8+8) = 32768;
                end
            end
            ch_info = obj.da_channel_list(channel);
            ch = ch_info.ch;
            da_struct = obj.da_list(ch_info.index);
            da_struct.da.StartStop(2^(ch-1)*16);
            seq = obj.GenerateContinuousSeq(length(voltage));
            da_struct.da.WriteSeq(ch,0,seq);
            % added uint16 to do clipping, otherwise DA might do wrap
            % around(65535+N is taken as N-1), this is  unacceptable for
            % qubits measurement applications, Yulin Wu
            % than a ustcadda property, Yulin Wu
            voltage = uint16(voltage +...
                obj.da_list(obj.da_channel_list(channel).index).da.offset(obj.da_channel_list(channel).ch)); 
            da_struct.da.WriteWave(ch,0,voltage);
            if(mod(floor(da_struct.mask_min/(2^(ch-1))),2) == 0)
                obj.da_list(ch_info.index).mask_min = da_struct.mask_min + 2^(ch-1);
            end
            da_struct.da.StartStop(240);
            da_struct.da.StartStop(obj.da_list(ch_info.index).mask_min);
        end  
        function StopContinuousWave(obj,channel)
            ch_info = obj.da_channel_list(channel);
            ch = ch_info.ch;
            da_struct = obj.da_list(ch_info.index);
            if(mod(floor(da_struct.mask_min/(2^(ch-1))),2) ~= 0)
                obj.da_list(ch_info.index).mask_min = da_struct.mask_min - 2^(ch-1);
                da_struct.da.StartStop(2^(ch-1)*16);
            end
        end
        function setDAChnlOutputDelay(obj,ch,delay)
            obj.da_channel_list(ch).delay = delay;
        end
        function SetDABoardTrigDelay(obj,da_name,point)
            for k = 1:obj.numDABoards
                name = obj.da_list(k).da.name;
                if(strcmpi(name,da_name))
                    obj.da_list(k).da_trig_delay = point;
                end
            end
        end
        function setDAChnlOutputOffset(obj,ch,offset)
            if(lenth(ch)~=length(offset))
                error('ustcadda_v1:setDAChnlOutputOffset','通道与偏置维度不同。');
            end
            for ii = 1:length(ch)
                ch_info = obj.da_channel_list(ch(ii));
                channel = ch_info.ch;
                da_struct = obj.da_list(ch_info.index);
                da_struct.da.offset(channel) = offset(ii);
                da_struct.da.SetDefaultVolt(32768 + offset(ii));
            end
        end
        function delay = GetDABoardTrigDelay(obj,da_name)
            for k = 1:obj.numDABoards
                name = obj.da_list(k).da.name;
                if(strcmpi(name,da_name))
                   delay = list(k).da_trig_delay;
                end
            end
        end
        function name = GetDACNameByChnl(obj,ch) % Yulin Wu
            numChnls = numel(ch);
            ch_info = obj.da_channel_list(ch);
            name = cell(1,numChnls);
            for ii = 1:numChnls
                da = obj.da_list(ch_info(ii).index).da;
                name{ii} = da.name;
            end
        end
		function d = GetADDemod(obj)
			d = obj.ad_list(1).ad.isdemod;
        end
        function delete(obj) % Yulin Wu
            obj.Close();
        end
    end
end