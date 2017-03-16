classdef mwSource < qes.hwdriver.sync.instrument & qes.hwdriver.multiChnl
    % microwave source driver

% Copyright 2015 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties % (AbortSet = true) do not use AbortSet
        on          % true/false, output on/off
    end
    properties % (SetAccess = immutable)
        freqlimits
        powerlimits
    end
    methods (Access = private)
        function obj = mwSource(name,interfaceobj,drivertype)
            if isempty(interfaceobj)
                error('mwSource:InvalidInput',...
                    'Input ''%s'' can not be empty!',...
                    'interfaceobj');
            end
            set(interfaceobj,'Timeout',10); 
            if nargin < 3
                drivertype = [];
            end
            obj = obj@qes.hwdriver.sync.instrument(name,interfaceobj,drivertype);
            ErrMsg = obj.InitializeInstr();
            if ~isempty(ErrMsg)
                error('mwSource:InstSetError',[obj.name, ': %s'], ErrMsg);
            end
            obj.chnlProps = {'frequency','power'};
            obj.chnlPropSetMothds = {@(obj,f,chnl)SetFreq(obj,f,chnl),...
                                      @(obj,p,chnl)SetPower(obj,p,chnl)};
            obj.chnlPropGetMothds = {@(obj,chnl)GetFreq(obj,chnl),...
                                      @(obj,chnl)GetPower(obj,chnl)};
        end
        [varargout] = InitializeInstr(obj)
%        [Freq, Power]=GetFreqPwer(obj)
        SetOnOff(obj,OnOrOff)
        onstatus = GetOnOff(obj)
    end
    methods (Static)
        obj = GetInstance(name,interfaceobj,drivertype)
    end
    methods
%         function set.frequency(obj,val)
%             if isempty(val) || ~isnumeric(val) || ~isreal(val) || val <= 0
%                 error('mwSource:SetError','Invalid frequency value.');
%             end
%             if val < obj.freqlimits(1) || val > obj.freqlimits(2)
%                 error('mwSource:OutOfLimit','Frequency value out of limits.');
%             end
%             SetFreq(obj,val);
%             obj.frequency = val;
%         end
%         function frequency = get.frequency(obj)
%             [frequency, ~] = GetFreqPwer(obj);
%         end
%         function set.power(obj,val)
%             if isempty(val) || ~isnumeric(val) || ~isreal(val)
%                 error('mwSource:SetError','Invalid power value.');
%             end
%             if val < obj.powerlimits(1) || val > obj.powerlimits(2)
%                 error('mwSource:OutOfLimit',[obj.name, ': Power value out of limits!']);
%             end
%             SetPower(obj,val);
%             obj.power = val;
%         end
%         function power = get.power(obj)
%             [~, power] = GetFreqPwer(obj);
%         end
        function set.on(obj,val)
            if isempty(val)
                error('mwSource:SetOnOff', 'value of ''on'' must be a bolean.');
            end
            if ~islogical(val)
                if val == 0 || val == 1
                    val = logical(val);
                else
                    error('mwSource:SetOnOff', 'value of ''on'' must be a bolean.');
                end
            end
            obj.SetOnOff(val);
            obj.on = val;
        end
        function val = get.on(obj)
            val = GetOnOff(obj);
        end
        function On(obj)
            % set on, this method is introduced for functional
            % programming.
            obj.on = true;
        end
        function Off(obj)
            % set off, this method is introduced for functional
            % programming.
            obj.on = false;
        end
        function delete(obj)
            obj.on = false;
        end
    end
    methods (Hidden = true)
        SetPower(obj,val,chnl)
        SetFreq(obj,val,chnl)
        power = GetPower(obj,chnl)
        frequency = GetFreq(obj,chnl)
    end
end