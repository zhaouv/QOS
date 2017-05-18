classdef jpaRunner < qes.qHandle
    % runs a jpa object
    
% Copyright 2017 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = private)
        jpa
        biasSrc
        pumpMwSrc
    end
    properties (SetAccess = private, GetAccess = private)
        pumpWv
        jpaPumpDA
        setupDC = true
        setupMwSrc = true
    end
    methods
        function obj = jpaRunner(jpaObj)
           obj.jpa = jpaObj;
           awg = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                    'name',jpaObj.channels.signal_da_i.instru);
           % needs checking here because awg could be a network analyzer,
           % jpaRunner dose not handle cases of using a network analyzer as
           % singnal source for S21, we only deal with the standard way of
           % using awg(DAC) and IQ mixing as signal source. 
            if ~isa(awg,'qes.hwdriver.sync.awg') && ~isa(awg,'qes.hwdriver.async.awg')
                throw(MException('QOS_jpaRunner:inValidSettings',...
                      sprintf('jpaRunner only handles cases of using awg(DAC) and IQ mixing as signal source, %s given.',...
                      jpaObj.channels.signal_i.instru)));
            end
            obj.jpaPumpDA = awg;
            biasSrc_ = qes.qHandle.FindByClassProp('qes.hwdriver.hardware','name',jpaObj.channels.bias.instru);
            obj.biasSrc = biasSrc_.GetChnl(jpaObj.channels.bias.chnl);
            pumpMwSrc_ = qes.qHandle.FindByClassProp('qes.hwdriver.hardware','name',jpaObj.channels.pump_mw.instru);
            obj.pumpMwSrc = pumpMwSrc_.GetChnl(jpaObj.channels.pump_mw.chnl);
        end
        function Run(obj,refresh)
            if nargin < 2
                refresh = false;
            end
            if obj.setupDC || refresh
                obj.biasSrc.dcval = obj.jpa.biasAmp;
                obj.biasSrc.on = true;
                obj.setupDC = false;
            end
            if obj.setupMwSrc || refresh
                obj.pumpMwSrc.frequency = obj.jpa.pumpFreq;
                obj.pumpMwSrc.power = obj.jpa.pumpPower;
                obj.setupMwSrc = false;
            end
            if isempty(obj.pumpWv) || refresh
                obj.GenWave();
            end
            obj.pumpWv.SendWave();
        end
    end
    methods (Access = private)
        function GenWave(obj)
            obj.pumpWv = sqc.wv.rect_cos(obj.jpa.opDuration);
			obj.pumpWv.amp = obj.jpa.pumpAmp;
			obj.pumpWv.awg = obj.jpaPumpDA;
            obj.pumpWv.df = 0;
			obj.pumpWv.awgchnl = [obj.jpa.channels.pump_i.chnl,obj.jpa.channels.pump_q.chnl];
			obj.pumpWv.hw_delay = true; % important
            % syncDelay_pump is added as a small calibration to compensate hardware imperfection while startDelay is a logical delay.
			outputDelay = obj.jpa.startDelay+obj.jpa.syncDelay_pump;
            outputDelay(outputDelay<0) = 0;
            obj.pumpWv.output_delay = outputDelay;
        end
    end
end