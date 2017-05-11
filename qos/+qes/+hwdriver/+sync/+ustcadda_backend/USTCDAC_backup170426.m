% 	FileName:USTCDAC.m
% 	Author:GuoCheng
% 	E-mail:fortune@mail.ustc.edu.cn
% 	All right reserved @ GuoCheng.
% 	Modified: 2017.2.26
%   Description:The class of DAC

classdef USTCDAC < handle
    properties (SetAccess = private)
        id = [];            %è®¾å¤‡æ ‡è¯†
        ip = '';            %è®¾å¤‡ip
        port = 80;          %ç«¯å?£å??
        status = 'close';   %æ‰“å¼€çŠ¶æ?
        isopen = 0;         %æ‰“å¼€çŠ¶æ?
        isblock = 0;        %æ˜¯å?¦ä»¥é˜»å¡žæ¨¡å¼?è¿?è¡?
    end
    
    properties (SetAccess = private)
        name = '';              %DACå??å­—
        channel_amount = 4;     %DACé€šé?“æ•°ç›®
        sample_rate = 2e9;      %é‡‡æ ·çŽ?
        sync_delay = 0;         %DACæ?¿å­?çš„å?Œæ­¥å»¶æ—?
        trig_delay = 0;         %DACè§¦å?‘è¾“å‡ºå»¶æ—¶
        da_range = 0.8;         %æœ?¤§ç”µåŽ‹ï¼Œæœªä½¿ç”¨
        gain = zeros(1,4);      %é€šé?“å¢žç›Š
        offset = zeros(1,4);    %é€šé?“å??ç½®
        offsetcorr  = zeros(1,4); % å…³é—­DACç”µåŽ‹
        
        trig_sel = 0;           %è§¦å?‘æº?é?æ‹?
        trig_interval = 200e-6; %ä¸»æ?¿è¿žç»­è§¦å?‘è¾“å‡ºæ—¶é—´é—´éš”
        ismaster = 0;           %ä¸»æ?¿æ ‡è¯†
        daTrigDelayOffset = 0;  %æœªä½¿ç”?
    end
    
    properties (GetAccess = private,Constant = true)
        driver  = 'USTCDACDriver';   %é©±åŠ¨å??
        driverh = 'USTCDACDriver.h'; %å¤´æ–‡ä»¶å??
    end
    
    methods (Static = true)
        
        function info = GetDriverInformation()
            if(~libisloaded(USTCDAC.driver))
                driverfilename = [USTCDAC.driver,'.dll'];
                loadlibrary(driverfilename,USTCDAC.driverh);
            end
            [ret,version] = calllib(USTCDAC.driver,'GetSoftInformation','');
            if(ret == 0)
                info = version;
            else
                error('USTCDAC: Get information failed!');
            end
        end
        
        function device_array = ScanDevice()
            if(~libisloaded(USTCDAC.driver))
                driverfilename = [USTCDAC.driver,'.dll'];
                loadlibrary(driverfilename,USTCDAC.driverh);
            end
            [ret,data] = calllib(USTCDAC.driver,'ScanDevice','');
            if(ret == 0)
                device_array = data;
            else
                error('USTCDAC: Scan device failed!');
            end
        end
        
    end
    
    methods
        function obj = USTCDAC(ip,port) %construct function.
            obj.ip = ip;
            obj.port = port;
            driverfilename = [obj.driver,'.dll'];
            if(~libisloaded(obj.driver))
                loadlibrary(driverfilename,obj.driverh);
            end
        end
             
        function Open(obj)              %open the device
            if ~obj.isopen
                [ret,obj.id,~] = calllib(obj.driver,'Open',0,obj.ip,obj.port);
                if(ret == 0)
                    obj.status = 'open';
                    obj.isopen = true;
                else
                   error('USTCDA:OpenError','Open DAC failed!');
                end
                 obj.Init();
            end
        end
         
        function Init(obj)
            obj.SetIsMaster(obj.ismaster);
            obj.SetTrigSel(obj.trig_sel);
            obj.SetTrigInterval(obj.trig_interval);

            obj.SetTotalCount(obj.trig_interval/4e-9 - 5000); %20170411

            obj.SetDACStart(obj.sync_delay/4e-9 + 1);
            obj.SetDACStop(obj.sync_delay/4e-9 + 10);
            obj.SetTrigStart(obj.trig_delay/4e-9 + 1);
            obj.SetTrigStop(obj.trig_delay/4e-9 + 10);
            obj.SetLoop(1,1,1,1);
            
            try_count = 10;
            isDACReady = 0;
            
            obj.InitBoard();
            ret = obj.GetReturn(1);
            data = double(ret(2))*65536 + double(ret(1));
            qes.hwdriver.sync.ustcadda_backend.WriteLog(obj.ip,data);
            
            while(try_count > 0 && ~isDACReady)
                obj.isblock = 1;
                ret = obj.ReadReg(5,8);
                obj.isblock = 0;
                if(mod(floor(ret/(2^20)),4) == 3)
                    isDACReady = 1;
                else
                    obj.InitBoard();
                    try_count =  try_count - 1;
                    pause(0.1);
                end
            end
            if(isDACReady == 0)
                error('USTCDAC:InitError','Config DAC failed!');
            end

            for k = 1:obj.channel_amount
%                 obj.SetOffset(k-1,obj.offset(k));
                obj.SetGain(k-1,obj.gain(k));
                obj.SetDefaultVolt(k-1,-obj.offsetcorr(k)+32767);
            end
            obj.PowerOnDAC(1,0);
            obj.PowerOnDAC(2,0);
        end
        
        function Close(obj)
            if obj.isopen
                ret = calllib(obj.driver,'Close',uint32(obj.id));
                if(ret == -1)
                    error('USTCDA:CloseError','Close DA failed.');              
                end
                obj.id = [];
                obj.status = 'closed';
                obj.isopen = false;
            end
        end
        
        function AutoOpen(obj)
            if(~libisloaded(obj.driver))
                driverfilename = [obj.driver,'.dll'];
                loadlibrary(driverfilename,obj.driverh);
            end
            if(~obj.isopen)
                obj.Open();
            end
        end
            
        function StartStop(obj,index)
            obj.AutoOpen();
            ret = calllib(obj.driver,'WriteInstruction', obj.id,uint32(hex2dec('00000405')),uint32(index),0);
            if(ret == -1)
                error('USTCDAC:StartStopError','Start/Stop failed.');
            end
        end
       % è¯¥å‡½æ•°æœªä½¿ç”¨
        function FlipRAM(obj,index)
            obj.AutoOpen();
            ret = calllib(obj.driver,'WriteInstruction', obj.id,uint32(hex2dec('00000305')),uint32(index),0);
            if(ret == -1)
                 error('USTCDAC:FlipRAMError','FlipRAM failed.');
            end
        end
        
        function SetLoop(obj,arg1,arg2,arg3,arg4)
            obj.AutoOpen();
            para1 = arg1*2^16 + arg2;
            para2 = arg3*2^16 + arg4;
            ret = calllib(obj.driver,'WriteInstruction', obj.id,uint32(hex2dec('00000905')),uint32(para1),uint32(para2));
            if(ret == -1)
                error('USTCDAC:SetLoopError','SetLoop failed.');
            end
        end

        function SetTotalCount(obj,count)
             obj.AutoOpen();
             ret = calllib(obj.driver,'WriteInstruction',uint32(obj.id),uint32(hex2dec('00001805')),1,uint32(count*2^16));
             if(ret == -1)
                 error('USTCDAC:SetTotalCount','Set SetTotalCount failed.');
             end
        end
        
        function SetDACStart(obj,count)
             obj.AutoOpen();
             ret = calllib(obj.driver,'WriteInstruction',uint32(obj.id),uint32(hex2dec('00001805')),2,uint32(count*2^16));
             if(ret == -1)
                 error('USTCDAC:SetDACStart','Set SetDACStart failed.');
             end
        end
         
        function SetDACStop(obj,count)
             obj.AutoOpen();
             ret = calllib(obj.driver,'WriteInstruction',uint32(obj.id),uint32(hex2dec('00001805')),3,uint32(count*2^16));
             if(ret == -1)
                 error('USTCDAC:SetDACStop','Set SetDACStop failed.');
             end
        end
        
        function SetTrigStart(obj,count)
            obj.AutoOpen();
            ret = calllib(obj.driver,'WriteInstruction',uint32(obj.id),uint32(hex2dec('00001805')),4,uint32(count*2^16));
            if(ret == -1)
                error('USTCDAC:SetTrigStart','Set SetTrigStart failed.');
            end
        end
        
        function SetTrigStop(obj,count)
            obj.AutoOpen();
             ret = calllib(obj.driver,'WriteInstruction',uint32(obj.id),uint32(hex2dec('00001805')),5,uint32(count*2^16));
             if(ret == -1)
                 error('USTCDAC:SetTrigStop','Set SetTrigStop failed.');
             end
         end
        
        function SetIsMaster(obj,ismaster)
            obj.AutoOpen();
            ret= calllib(obj.driver,'WriteInstruction',uint32(obj.id),uint32(hex2dec('00001805')),6,uint32(ismaster*2^16));
            if(ret == -1)
                error('USTCDAC:SetIsMaster','Set SetIsMaster failed.');
            end
        end
        
        function SetTrigSel(obj,sel)
            obj.AutoOpen();
            ret= calllib(obj.driver,'WriteInstruction',uint32(obj.id),uint32(hex2dec('00001805')),7,uint32(sel*2^16));
            if(ret == -1)
                error('USTCDAC:SetTrigSel','Set SetTrigSel failed.');
            end
        end
        
        function SendIntTrig(obj)
             obj.AutoOpen();
             ret = calllib(obj.driver,'WriteInstruction',uint32(obj.id),uint32(hex2dec('00001805')),8,uint32(2^16));
             if(ret == -1)
                 error('USTCDAC:SendIntTrig','Set SendIntTrig failed.');
             end
        end
                
        function SetTrigInterval(obj,T)
            % T unit: seconds, Step 4ns.
            obj.AutoOpen();
            count = T/4e-9;
            ret= calllib(obj.driver,'WriteInstruction',obj.id,uint32(hex2dec('00001805')),9,uint32(count*2^12));
             if(ret == -1)
                 error('USTCDAC:SelectTrigIntervalError','Set trigger interval failed.');
             end
        end 
        
        function SetTrigCount(obj,count)
            obj.AutoOpen();
            ret= calllib(obj.driver,'WriteInstruction',obj.id,uint32(hex2dec('00001805')),10,uint32(count*2^12));
             if(ret == -1)
                 error('USTCDAC:SetTrigCountError','Set trigger Count failed.');
             end
        end
        
        function SetGain(obj,channel,data)
             obj.AutoOpen();
             map = [2,3,0,1];       %æœ‰bugï¼Œéœ€è¦?å?šä¸?¬¡æ˜ å°„
             channel = map(channel+1);
             ret = calllib(obj.driver,'WriteInstruction',obj.id,uint32(hex2dec('00000702')),uint32(channel),uint32(data));
             if(ret == -1)
                 error('USTCDAC:WriteGain','WriteGain failed.');
             end
        end
        
        function SetOffset(obj,channel,data)
            obj.AutoOpen();
            map = [6,7,4,5];       %æœ‰bugï¼Œéœ€è¦?å?šä¸?¬¡æ˜ å°„
            channel = map(channel+1);
            ret = calllib(obj.driver,'WriteInstruction',obj.id,uint32(hex2dec('00000702')),uint32(channel),uint32(data));
            if(ret == -1)
                 error('USTCDAC:WriteOffset','WriteOffset failed.');
            end
        end
        
        function SetDefaultVolt(obj,channel,volt)
            obj.AutoOpen();
            volt = mod(volt,256)*256 + floor(volt/256);    %é«˜ä½Žä½?åˆ‡æ??
            ret = calllib(obj.driver,'WriteInstruction',obj.id,uint32(hex2dec('00001B05')),uint32(channel),uint32(volt));
            if(ret == -1)
                 error('USTCDAC:WriteOffset','WriteOffset failed.');
            end
        end
        
        function WriteReg(obj,bank,addr,data)
             obj.AutoOpen();
             cmd = bank*256 + 2; %1è¡¨ç¤ºReadRegï¼ŒæŒ‡ä»¤å’Œbankå­˜å‚¨åœ¨ä¸€ä¸ªDWORDæ•°æ?®ä¸?
             ret = calllib(obj.driver,'WriteInstruction',obj.id,uint32(cmd),uint32(addr),uint32(data));
             if(ret == -1)
                 error('USTCDAC:WriteRegError','WriteReg failed.');
             end
        end
        
        function WriteWave(obj,ch,offset,wave)
            obj.AutoOpen();
            % èŒƒå›´é™?åˆ¶
            wave(wave > 65535) = 65535;
            wave(wave < 0) = 0;
            % è¡¥å¤Ÿ512bitçš„ä½?å®½æ•´æ•°å?
            data = wave;
            len = length(wave);
            if(mod(len,32) ~= 0)
                len = (floor(len/32)+1)*32;
                data = zeros(1,len);
                data(1:length(wave)) = wave;
            end            
            % é¢ å?å‰?å?Žæ•°æ?®ï¼Œè¿™æ˜¯ç”±äºŽFPGAæŽ¥æ”¶å­—èŠ‚åº?é—®é¢?
            for k = 1:length(data)/2
                temp = data(2*k);
                data(2*k) = data(2*k-1);
                data(2*k-1) = temp;
            end
            % æ•°æ?®å??ç›¸ï¼Œä¸´æ—¶éœ€è¦?
            data = 65535 - data;
            % ä»?é€šé?“å¼?§‹ç¼–å?·
            ch = ch - 1;
            ch(ch < 0) = 0;
            startaddr = ch*2*2^18+2*offset;
            len = length(data)*2;
            pval = libpointer('uint16Ptr', data);
            [ret,~] = calllib(obj.driver,'WriteMemory',obj.id,uint32(hex2dec('000000004')),uint32(startaddr),uint32(len),pval);
            if(ret == -1)
                error('USTCDAC:WriteWaveError','WriteWave failed.');
            end
        end
        
        function WriteSeq(obj,ch,offset,seq)
            obj.AutoOpen();
            % è¡¥å¤Ÿ512bitä½?å®½
            len = length(seq);
            data = seq;
            if(mod(len,32) ~= 0)
                len = (floor(len/32)+1)*32;
                data = zeros(1,len);
                data(1:length(seq)) = seq;
            end
            % ä»?é€šé?“å¼?§‹ç¼–å?·
            ch = ch - 1;
            ch(ch < 0) = 0;
            startaddr = (ch*2+1)*2^18+offset*8; %åº?åˆ—çš„å†…å­˜èµ·å§‹åœ°å??¼Œå?•ä½?æ˜¯å­—èŠ‚ã?
            len = length(data)*2;               %å­—èŠ‚ä¸ªæ•°ã€?
            pval = libpointer('uint16Ptr', data);
            [ret,~] = calllib(obj.driver,'WriteMemory',obj.id,uint32(hex2dec('00000004')),uint32(startaddr),uint32(len),pval);
            if(ret == -1)
                error('USTCDAC:WriteSeqError','WriteSeq failed.');
            end
        end
       % è¯¥å‡½æ•°æœªä½¿ç”¨
        function wave = ReadWave(obj,ch,offset,len)
              obj.AutoOpen();
              wave = [];
              startaddr = (ch*2)*2^18 + 2*offset;
              ret = calllib(obj.driver,'ReadMemory',obj.id,uint32(hex2dec('00000003')),uint32(startaddr),uint32(len*2));
              if(ret == 0)
                 if(obj.isblock == true)
                     wave = obj.GetReturn(1);
                 end
              else
                  error('USTCDAC:ReadWaveError','ReadWave failed.');
              end
        end
       % è¯¥å‡½æ•°æœªä½¿ç”¨
        function seq = ReadSeq(obj,ch,offset,len)
              obj.AutoOpen();
              startaddr = (ch*2+1)*2^18 + offset*8;
              ret = calllib(obj.driver,'ReadMemory',obj.id,uint32(hex2dec('00000003')),uint32(startaddr),uint32(len*8));
              if(ret == 0)
                 if(obj.isblock == true)
                     seq = obj.GetReturn(1);
                 end
              else
                  error('USTCDAC:ReadSeqError','ReadSeq failed.');
              end
        end
        
        function reg = ReadReg(obj,bank,addr)
             obj.AutoOpen();
             cmd = bank*256 + 1; %1è¡¨ç¤ºReadRegï¼ŒæŒ‡ä»¤å’Œbankå­˜å‚¨åœ¨ä¸€ä¸ªDWORDæ•°æ?®ä¸?
             reg = 0;
             ret = calllib(obj.driver,'ReadInstruction',obj.id,uint32(cmd),uint32(addr));
             if(ret == 0)
                 if(obj.isblock == true)
                      ret = obj.GetReturn(1);
                      reg = double(ret(2))*65536 + double(ret(1));
                 end
              else
                  error('USTCDAC:ReadWaveError','ReadWave failed.');
              end
        end
        
        function data = ReadAD9136_1(obj,addr)
            obj.AutoOpen();
            ret = calllib(obj.driver,'WriteInstruction',obj.id,uint32(hex2dec('00001c05')),uint32(addr),uint32(0));
            if(ret == -1)
                 error('USTCDAC:ReadAD9136','ReadAD9136 failed.');
            end
            ret = obj.GetReturn(1);
            data = double(ret(2))*65536 + double(ret(1));
        end
        
        function data = ReadAD9136_2(obj,addr)
            obj.AutoOpen();
            ret = calllib(obj.driver,'WriteInstruction',obj.id,uint32(hex2dec('00001d05')),uint32(addr),uint32(0));
            if(ret == -1)
                 error('USTCDAC:ReadAD9136','ReadAD9136 failed.');
            end
            ret = obj.GetReturn(1);
            data = double(ret(2))*65536 + double(ret(1));
        end

        function [functiontype,instruction,para1,para2] = GetFuncType(obj,offset)
            obj.AutoOpen()
            [ret,functiontype,instruction,para1,para2] = calllib(obj.driver,'GetFunctionType',uint32(obj.id),uint32(offset),0,0,0,0);
            if(ret == -1)
                error('USTCDAC:GetFuncType','GetFuncType failed');
            end
        end
        
        function data = GetReturn(obj,offset)
           obj.AutoOpen();
           [func_type,~,~,para2] = obj.GetFuncType(1);
           if(func_type == 1 || func_type == 2)
               length = 4;
           else
               length = para2;
           end
           pData = libpointer('uint16Ptr',zeros(1,length/2));
           [ret,data] = calllib(obj.driver,'GetReturn',uint32(obj.id),uint32(offset),pData);
           if(ret == -1)
               error('USTCDAC:GetReturn','Get return failed!');
           end
        end
        
        function isSuccessed = CheckStatus(obj)
           obj.AutoOpen()
           [ret,isSuccessed] = calllib(obj.driver,'CheckSuccessed',uint32(obj.id),0);
           if(ret == -1)
               error('USTCDAC:CheckStatus','Exist some task failed!');
           end
        end
        
        function InitBoard(obj)
            obj.AutoOpen();
            ret = calllib(obj.driver,'WriteInstruction',obj.id,uint32(hex2dec('00001A05')),11,uint32(2^16));
            if(ret == -1)
                 error('USTCDAC:WriteRegError','WriteReg failed.');
            end
        end
        
        function PowerOnDAC(obj,chip,onoff)
            obj.AutoOpen();
            ret = calllib(obj.driver,'WriteInstruction',obj.id,uint32(hex2dec('00001E05')),uint32(chip),uint32(onoff));
            if(ret == -1)
                 error('USTCDAC:PowerOnDAC','PowerOnDAC failed.');
            end
        end
        
        function SetGainPara(obj,channel,gain)
            if(channel <= obj.channel_amount)
                obj.gain(channel) = gain;
            end
        end
        
        function gain = GetGainPara(obj,channel)
            if(channel <= obj.channel_amount)
                gain = obj.gain(channel);
            end
        end
        
        function SetOffsetPara(obj,channel,offset)
            if(channel <= obj.channel_amount)
                obj.offset(channel) = offset;
            end
        end
        
        function offset = GetOffsetPara(obj,channel)
            if(channel <= obj.channel_amount)
                offset = obj.offset(channel);
            end
        end
        
        function SetTrigDelay(obj,num)
            obj.SetTrigStart(floor((obj.trig_delay+ num)/8)+1);
            obj.SetTrigStop(floor((obj.trig_delay+ num)/8)+ 10);
        end
        
        function value = get(obj,properties)
            switch lower(properties)
                case 'isblock';value = obj.isblock ;
                case 'channel_amount';value = obj.channel_amount;
                case 'gain';value = obj.gain;
                case 'offset';value = obj.offset;
                case 'name';value = obj.name;
                case 'ismaster';value = obj.ismaster;
                case 'trig_sel';value = obj.trig_sel;
                case 'trig_interval';value = obj.trig_interval;
                case 'sync_delay';value = obj.sync_delay;
                case 'trig_delay';value = obj.trig_delay;
                case 'sample_rate';value = obj.sample_rate;
                otherwise; error('USTCDAC:get','do not exsis the properties')
            end
        end
        
        function set(obj,properties,value)
             switch lower(properties)
                case 'isblock';obj.isblock = value;
                case 'channel_amount'
                    obj.channel_amount = value;
                    obj.offset = zeros(1,obj.channel_amount);
                    obj.gain = zeros(1,obj.channel_amount);
                case 'gain';obj.gain = value;
                case 'offset';obj.offset = value;
                case 'name';obj.name = value;
                case 'ismaster';obj.ismaster = value;
                case 'trig_sel';obj.trig_sel = value;
                case 'trig_interval';obj.trig_interval = value;
                case 'sync_delay';obj.sync_delay = value;
                case 'trig_delay';obj.trig_delay = value;
                case 'sample_rate';obj.sample_rate = value;
                case 'datrigdelayoffset'; obj.daTrigDelayOffset = value;
                case 'offsetcorr';obj.offsetcorr = value;
                otherwise; error('USTCDAC:get','do not exsis the properties')
            end
        end
    end
end