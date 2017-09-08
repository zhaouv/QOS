 % 	FileName:USTCADC.m
% 	Author:GuoCheng
% 	E-mail:fortune@mail.ustc.edu.cn
% 	All right reserved @ GuoCheng.
% 	Modified: 2017.7.1
%   Description:The class of ADC
classdef USTCADC < handle
    properties(SetAccess = private)
        netcard;                     % net card number
        isopen;                      % open flag
        status;                      % open state.
    end
    
    properties
        name = '';                   % ADC name
        mac = '00-00-00-00-00-00';   % mac address of pc
        sample_rate = 1e9;           % ADC sample rate
        channel_amount = 2;          % ADC channel amount, I & Q.
        isdemod = 0;                 % is run demod mode.
        sample_depth = 2000;         % ADC sample depth
        trig_count = 100;          % ADC accept trigger count
        window_start = 0;            % start position of demod window.
        window_width = 2000;         % demod window width.
        demod_frequency = 100e6;     % demod frequency.
    end
    
    properties (GetAccess = private,Constant = true)
        driver = 'USTCADCDriver';
        driverh = 'USTCADCDriver.h';
        driverdll = 'USTCADCDriver.dll';
    end
    
    methods(Static = true)
        function LoadLibrary()
            if(~libisloaded(qes.hwdriver.sync.ustcadda_backend.USTCADC.driver))
                loadlibrary(qes.hwdriver.sync.ustcadda_backend.USTCADC.driverdll,qes.hwdriver.sync.ustcadda_backend.USTCADC.driverh);
            end
        end
        function info = GetDriverInformation()
            qes.hwdriver.sync.ustcadda_backend.USTCADC.LoadLibrary();
            str = libpointer('cstring',blanks(1024));
            [ErrorCode,info] = calllib(qes.hwdriver.sync.ustcadda_backend.USTCADC.driver,'GetSoftInformation',str);
            qes.hwdriver.sync.ustcadda_backend.USTCADC.DispError('USTCDAC:GetDriverInformation:',ErrorCode);
        end
        function list = ListAdpter()
            qes.hwdriver.sync.ustcadda_backend.USTCADC.LoadLibrary();
            list = blanks(2048);
            str = libpointer('cstring',blanks(2048));
            [ErrorCode,info] = calllib(qes.hwdriver.sync.ustcadda_backend.USTCADC.driver,'GetAdapterList',str);
            if(ErrorCode == 0)
                info = regexp(info,'\n', 'split');pos = 1;
                for index = 1:length(info)
                   info{index} = [num2str(index),' : ',info{index}];
                   list(pos:pos + length(info{index})) = [info{index},10];
                   pos = pos + length(info{index}) + 1;
                end
            end
            qes.hwdriver.sync.ustcadda_backend.USTCADC.DispError('USTCADC:ListAdapter',ErrorCode);
        end
        function DispError(MsgID,errorcode)
            if(errorcode ~= 0)
                str = libpointer('cstring',blanks(1024));
                [~,info] = calllib(qes.hwdriver.sync.ustcadda_backend.USTCADC.driver,'GetErrorMsg',int32(errorcode),str);
                msg = ['Error code:',num2str(errorcode),' --> ',info];
                qes.hwdriver.sync.ustcadda_backend.WriteErrorLog([MsgID,' ',msg]);
                error(MsgID,msg);
            end
        end
    end
    
    methods
        function obj = USTCADC(num)
            obj.netcard = num;
            obj.isopen = false;
            obj.status = 'close';
        end
        function Open(obj)
            if ~obj.isopen
                obj.LoadLibrary();
                ErrorCode = calllib(obj.driver,'OpenADC',int32(obj.netcard));
                obj.DispError('USTCADC:Open',ErrorCode);
                obj.status = 'open';
                obj.isopen = true;
                obj.Init()
            end
        end
        function Close(obj)
            if(obj.isopen == true)
                ErrorCode = calllib(obj.driver,'CloseADC');
                obj.DispError('USTCADC:Close',ErrorCode);
                obj.status = 'close';
                obj.isopen = false;
            end
        end
        function Init(obj)
            obj.SetMacAddr(obj.mac);
            obj.SetGain(1);
        end
        function SetSampleDepth(obj,depth)
            obj.sample_depth = depth;
            data = [0,18,depth/256,mod(depth,256)];
            pdata = libpointer('uint8Ptr', data);
            [ErrorCode,~] = calllib(obj.driver,'SendData',int32(4),pdata);
            obj.DispError('USTCADC:SetSampleDepth',ErrorCode);
        end
        function SetTrigCount(obj,count)
            obj.trig_count = count;
            data = [0,19,count/256,mod(count,256)];
            pdata = libpointer('uint8Ptr', data);
            [ErrorCode,~] = calllib(obj.driver,'SendData',int32(4),pdata);
            obj.DispError('USTCADC:SetTrigCount',ErrorCode);
        end
        function SetMacAddr(obj,macStr)
            obj.mac = macStr;
            macdata = regexp(macStr,'-', 'split');
            macdata = hex2dec(macdata)';
            data = [0,17];
            data = [data,macdata];
            pdata = libpointer('uint8Ptr', data);
            [ErrorCode,~] = calllib(obj.driver,'SendData',int32(length(macdata)+2),pdata);
            obj.DispError('USTCADC:SetMacAddr',ErrorCode);
        end
        function ForceTrig(obj)
            data = [0,1,238,238,238,238,238,238];
            pdata = libpointer('uint8Ptr', data);
            [ErrorCode,~] = calllib(obj.driver,'SendData',int32(8),pdata);
            obj.DispError('USTCADC:ForceTrig',ErrorCode);
        end
        function EnableADC(obj)
            data = [0,3,238,238,238,238,238,238];
            pdata = libpointer('uint8Ptr', data);
            [ErrorCode,~] = calllib(obj.driver,'SendData',int32(8),pdata);
            obj.DispError('USTCADC:EnableADC',ErrorCode);
        end
        function SetMode(obj,isdemo)
            obj.isdemod = isdemo;
            if(isdemo == 0)
                data = [1,1,17,17,17,17,17,17];
            else
                data = [1,1,34,34,34,34,34,34];
            end
            pdata = libpointer('uint8Ptr', data);
            [ErrorCode,~] = calllib(obj.driver,'SendData',int32(8),pdata);
            obj.DispError('USTCADC:SetMode',ErrorCode);
        end
        function SetWindowLength(obj,length)
            data = [0,20,floor(length/256),mod(length,256),0,0,0,0];
            pdata = libpointer('uint8Ptr', data);
            [ErrorCode,~] = calllib(obj.driver,'SendData',int32(8),pdata);
            obj.DispError('USTCADC:SetWindowLength',ErrorCode);  
        end
        function SetWindowStart(obj,pos)
            data = [0,21,floor(pos/256),mod(pos,256),0,0,0,0];
            pdata = libpointer('uint8Ptr', data);
            [ErrorCode,~] = calllib(obj.driver,'SendData',int32(8),pdata);
            obj.DispError('USTCADC:SetWindowStart',ErrorCode);  
        end
        function SetDemoFre(obj,fre)
            step = fre/1e9*65536;
            data = [0,22,floor(step/256),mod(step,256),0,0,0,0];
            pdata = libpointer('uint8Ptr', data);
            [ErrorCode,~] = calllib(obj.driver,'SendData',int32(8),pdata);
            obj.DispError('USTCADC:SetDemoFre',ErrorCode);  
        end      
        function SetGain(obj,mode)
            switch mode
                case 1,code = [80,80];
                case 2,code = [0,0];
                case 3,code = [255,255];
            end
            data = [0,23,code(1),code(2),0,0,0,0];
            pdata = libpointer('uint8Ptr', data);
            [ErrorCode,~] = calllib(obj.driver,'SendData',int32(8),pdata);
            obj.DispError('USTCADC:SetGain',ErrorCode);
        end
        function [ret,I,Q] = RecvData(obj,row,column)
            if(obj.isdemod)
                IQ = zeros(2*row,1);
                pIQ = libpointer('int32Ptr', IQ);
                [ret,IQ] = calllib(obj.driver,'RecvDemo',int32(row),pIQ);
                if(ret == 0)
                    I = IQ(1:2:length(IQ));
                    Q = IQ(2:2:length(IQ));
                end
            else
                I = zeros(row*column,1);
                Q = zeros(row*column,1);
                pI = libpointer('uint8Ptr', I);
                pQ = libpointer('uint8Ptr', Q);
                [ret,I,Q] = calllib(obj.driver,'RecvData',int32(row),int32(column),pI,pQ);
                I = (reshape(I,[obj.sample_depth,obj.trig_count]))';
                Q = (reshape(Q,[obj.sample_depth,obj.trig_count]))';
            end
        end
     end
end