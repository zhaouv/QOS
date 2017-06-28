% 	FileName:USTCADC.m
% 	Author:GuoCheng
% 	E-mail:fortune@mail.ustc.edu.cn
% 	All right reserved @ GuoCheng.
% 	Modified: 2017.2.26
%   Description:The class of ADC
classdef USTCADC < handle
    properties % Yulin Wu, 170427
        mac = zeros(1,6)   %上位机网卡地址
        name = ''
        channel_amount = 2     %ADC通道，未使用，实际使用I、Q两个通道。
        sample_rate = 1e9      %ADC采样率，未使用
		demod = false
    end
    
    properties(SetAccess = private)
        netcard_no         %上位机网卡号
        % mac = zeros(1,6)   %上位机网卡地址 % Yulin Wu, 170427
        isopen             %打开标识
        status             %打开状态
    end

    properties(SetAccess = private)
        % name = ''              %ADC名字 % Yulin Wu, 170427
        % sample_rate = 1e9      %ADC采样率，未使用 % Yulin Wu, 170427
        % channel_amount = 2     %ADC通道，未使用，实际使用I、Q两个通道。 % Yulin Wu, 170427
        sample_depth = 2000;    %ADC采样深度
        sample_count = 100     %ADC使能后采样次数
    end
    
    properties (GetAccess = private,Constant = true)
        driver = 'USTCADCDriver';
        driverh = 'USTCADCDriver.h';
    end
    
	methods(Static = true) % GuoCheng 170605
        function list = ListAdpter()
            driverfilename = [USTCADC.driver,'.dll'];
            if(~libisloaded(USTCADC.driver))
                loadlibrary(driverfilename,USTCADC.driverh);
            end
            list = blanks(2048);
            pos = 1;
            str = libpointer('cstring',blanks(2048));
            [ret,info] = calllib(USTCADC.driver,'GetAdapterList',str);
            if(ret == 0)
                info = regexp(info,'\n', 'split');
                for index = 1:length(info)
                   info{index} = [num2str(index),' : ',info{index}];
                   list(pos:pos + length(info{index})) = [info{index},10];
                   pos = pos + length(info{index}) + 1;
                end
            else
                error('USTCDAC: Get adpter list failed!');
            end
        end
    end
    methods
        function obj = USTCADC(num)
            obj.netcard_no = num;
            obj.isopen = false;
            obj.status = 'close';
            driverfilename = [obj.driver,'.dll'];
            if(~libisloaded(obj.driver))
                loadlibrary(driverfilename,obj.driverh);
            end
        end
        
        function set.mac(obj,val)
            % Yulin Wu, 170427
            mac_str = regexp(val,'-', 'split');
            obj.mac = hex2dec(mac_str);
        end
        
        function Open(obj)
            if obj.isopen
                return;
            end
            ret = calllib(obj.driver,'OpenADC',int32(obj.netcard_no));
            if(ret == 0)
                obj.status = 'open';
                obj.isopen = true;
            else
               throw(MException('USTCADC:OpenError',...
                   sprintf('Open ADC %s failed!',obj.name))); % Yulin Wu
            end 
            obj.Init()
        end
        
        function Init(obj)
            obj.SetMacAddr(obj.mac');
            obj.SetSampleDepth(obj.sample_depth);
            obj.SetTrigCount(obj.sample_count);
        end
        
        function Close(obj)
            if obj.isopen
                ret = calllib(obj.driver,'CloseADC');
                if(ret == 0)
                    obj.status = 'close';
                    obj.isopen = false;
                else
                   throw(MException('USTCADC:CloseError',...
                        sprintf('Close ADC %s failed!',obj.name))); % Yulin Wu
                end 
            end
        end
        
        function SetSampleDepth(obj,depth)
             if obj.isopen
                data = [0,18,depth/256,mod(depth,256)];
                pdata = libpointer('uint8Ptr', data);
                [ret,~] = calllib(obj.driver,'SendData',int32(4),pdata);
                if(ret ~= 0)
                   throw(MException('USTCADC:SetSampleDepthError',...
                        sprintf('Set SampleDepth failed on ADC %s.',obj.name))); % Yulin Wu
                end 
            end
        end
        
        function ClearBuff(obj)
             if obj.isopen
                ret = calllib(obj.driver,'ClearBuff');
                if(ret ~= 0)
                   error('USTCADC:ClearBuff','ClearBuff failed!');
                end 
            end
        end
        
        function SetTrigCount(obj,count)
             if obj.isopen
                data = [0,19,count/256,mod(count,256)];
                pdata = libpointer('uint8Ptr', data);
                [ret,~] = calllib(obj.driver,'SendData',int32(4),pdata);
                if(ret ~= 0)
                   throw(MException('USTCADC:SetTrigCountError',...
                        sprintf('Set TrigCount failed on ADC %s.',obj.name))); % Yulin Wu
                end 
            end
        end
        
        function SetMacAddr(obj,mac)
           if obj.isopen
                data = [0,17];
                data = [data,mac];
                pdata = libpointer('uint8Ptr', data);
                [ret,~] = calllib(obj.driver,'SendData',int32(length(mac)+2),pdata);
                if(ret ~= 0)
                   error('USTCADC:SendPacket','SetMacAddr failed!');
                end 
            end
        end
        
        function ForceTrig(obj)
           if obj.isopen
                data = [0,1,238,238,238,238,238,238];
                pdata = libpointer('uint8Ptr', data);
                [ret,~] = calllib(obj.driver,'SendData',int32(8),pdata);
                if(ret ~= 0)
                   error('USTCADC:SendPacket','ForceTrig failed!');
                end 
           end
        end
        
        function EnableADC(obj)
           if obj.isopen
                data = [0,3,238,238,238,238,238,238];
                pdata = libpointer('uint8Ptr', data);
                [ret,~] = calllib(obj.driver,'SendData',int32(8),pdata);
                if(ret ~= 0)
                   error('USTCADC:SendPacket','EnableADC failed!');
                end
           end
        end
        
		function SetMode(obj,isdemo) % GuoCheng 170605
            if obj.isopen
                if(isdemo == 0)
                    data = [1,1,17,17,17,17,17,17];
                else
                    data = [1,1,34,34,34,34,34,34];
                end
                pdata = libpointer('uint8Ptr', data);
                [ret,~] = calllib(obj.driver,'SendData',int32(8),pdata);
                if(ret ~= 0)
                   error('USTCADC:SendPacket','SetMode failed!');
                end
            end       
        end
        
        function SetWindowLength(obj,length) % GuoCheng 170605
            if obj.isopen
                data = [0,20,floor(length/256),mod(length,256),0,0,0,0];
                pdata = libpointer('uint8Ptr', data);
                [ret,~] = calllib(obj.driver,'SendData',int32(8),pdata);
                if(ret ~= 0)
                   error('USTCADC:SendPacket','SetWindowLength failed!');
                end
            end       
        end
        
        function SetWindowStart(obj,pos) % GuoCheng 170605
            if obj.isopen
                data = [0,21,floor(pos/256),mod(pos,256),0,0,0,0];
                pdata = libpointer('uint8Ptr', data);
                [ret,~] = calllib(obj.driver,'SendData',int32(8),pdata);
                if(ret ~= 0)
                   error('USTCADC:SendPacket','SetWindowStart failed!');
                end
            end 
        end
        
        function SetDemoFre(obj,fre) % GuoCheng 170605
            if obj.isopen
                step = fre/1e9*65536;
                data = [0,22,floor(step/256),mod(step,256),0,0,0,0];
                pdata = libpointer('uint8Ptr', data);
                [ret,~] = calllib(obj.driver,'SendData',int32(8),pdata);
                if(ret ~= 0)
                   error('USTCADC:SendPacket','SetDemoFre failed!');
                end
            end 
        end
        
        function SetGain(obj,mode) % GuoCheng 170605
            if obj.isopen
                switch mode
                    case 1,code = [80,80];
                    case 2,code = [0,0];
                    case 3,code = [255,255];
                end
                data = [0,23,code(1),code(2),0,0,0,0];
                pdata = libpointer('uint8Ptr', data);
                [ret,~] = calllib(obj.driver,'SendData',int32(8),pdata);
                if(ret ~= 0)
                   error('USTCADC:SendPacket','SetGain failed!');
                end
            end 
        end
        
        function [ret,I,Q] = RecvData(obj,row,column)
            if obj.demod
                [ret,I,Q] = RecvDemo(obj,row);
            else
                [ret,I,Q] = RecvRawData(obj,row,column);
            end
        end
        
        function [ret,I,Q] = RecvRawData(obj,row,column)
            if obj.isopen
                I = zeros(row*column,1);
                Q = zeros(row*column,1);
                pI = libpointer('uint8Ptr', I);
                pQ = libpointer('uint8Ptr', Q);
                [ret,I,Q] = calllib(obj.driver,'RecvData',int32(row*column),int32(column),pI,pQ);
            end
        end
        
        % removed by Yulin Wu, 170427
		function [ret,I,Q] = RecvDemo(obj,row) % GuoCheng 170605
            if obj.isopen
                IQ = zeros(2*row,1);
                pIQ = libpointer('int32Ptr', IQ);
                [ret,IQ] = calllib(obj.driver,'RecvDemo',int32(row),pIQ);
                I = IQ(1:2:length(IQ));
                Q = IQ(2:2:length(IQ));
%                 if(ret ~= 0)
%                     error('USTCADC:RecvDemo','Recive demode data error!')
%                 end
            end
        end
%         function set(obj,properties,value)
%             switch properties
%                 case 'mac'
%                     mac_str = regexp(value,'-', 'split');
%                     obj.mac = hex2dec(mac_str);
%                 case 'name'; obj.name = value;
%                 case 'sample_rate'; obj.sample_rate = value;
%                 case 'channel_amount';obj.channel_amount = value;
%             end
%         end
%         
%         function value = get(obj,properties)
%             switch properties
%                 case 'mac';value = obj.mac;
%                 case 'name'; value = obj.name;
%                 case 'sample_rate'; value = obj.sample_rate;
%                 case 'channel_amount';value = obj.channel_amount;
%             end
%         end
     end
end