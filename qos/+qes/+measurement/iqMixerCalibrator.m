classdef iqMixerCalibrator < qes.measurement.measurement
	% do IQ Mixer calibration
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
%         q_delay = 0
        lo_freq      % Hz, carrier frequency
        lo_power
        sb_freq % Hz, side band frequency
        pulse_ln = 25000
%         chnls
        
        debug = true;
    end
	properties (SetAccess = private, GetAccess = private)
		awg
		i_chnl
        q_chnl
		lo_source
		spc_amp_obj
        iqAmp
        
        iqCalDataSetIdx
        
        iZero
        qZero
        
        loFreqs
        iZeros
        qZeros
        sbFreqs
        sbCompensations
	end
    methods
        function obj = iqMixerCalibrator(awgObj,awgchnls,spcAmpObj,loSource)
			if (~isa(awgObj,'qes.hwdriver.sync.awg') &&...
				~isa(awgObj,'qes.hwdriver.async.awg')) ||...
				~isa(spcAmpObj,'qes.measurement.specAmp') ||...
				~isa(loSource,'qes.hwdriver.instrumentChnl') ||...
				numel(awgchnls) ~= 2
				throw(MException('QOS_iqMixerCalibrator:InvalidInput','Invalud input arguments.'));
			end
            obj = obj@qes.measurement.measurement([]);
			obj.awg = awgObj;
			obj.i_chnl = awgchnls(1);
			obj.q_chnl = awgchnls(2);
%             obj.chnls = awgchnls;
			obj.spc_amp_obj = spcAmpObj;
			obj.lo_source = loSource;
            obj.numericscalardata = false;
            
            obj.awg.iqCalDataSet = []; % clear loaded iqCalDataSet is important!

            numIQCalDataSet = numel(obj.awg.iqCalDataSet);
            if numIQCalDataSet==0
                obj.awg.iqCalDataSet = struct(...
                        'loFreq',[],'iZero',[],'qZero',[],'sbFreq',[],'sbCompensation',[]);
                    obj.iqCalDataSetIdx = numIQCalDataSet+1;
            end
            for ii = 1:numIQCalDataSet
                if all(obj.awg.iqCalDataSet(ii).chnls == [obj.i_chnl,obj.q_chnl])
                    obj.iqCalDataSetIdx = ii;
                    break;
                elseif ii == numIQCalDataSet
                    obj.awg.iqCalDataSet(end+1) = struct(...
                        'loFreq',[],'iZero',[],'qZero',[],'sbFreq',[],'sbCompensation',[]);
                    obj.iqCalDataSetIdx = numIQCalDataSet+1;
                end
            end
        end
        function set.lo_freq(obj,val)
            obj.iZero = [];
            obj.qZero = [];
            obj.lo_freq = val;
        end
        function Run(obj)
            if isempty(obj.lo_freq) ||...
                    isempty(obj.lo_power) || isempty(obj.sb_freq)
                throw(MException('QOS_iqMixerCalibrator:propertyNotSet',...
					'some properties are not set.'));
            end
%             if isempty(obj.q_delay) || isempty(obj.lo_freq) ||...
%                     isempty(obj.lo_power) || isempty(obj.sb_freq)
%                 throw(MException('QOS_iqMixerCalibrator:propertyNotSet',...
% 					'some properties are not set.'));
%             end
			Run@qes.measurement.measurement(obj);
            obj.iqAmp = obj.awg.vpp/2;
			obj.lo_source.frequency = obj.lo_freq;
			obj.lo_source.power = obj.lo_power;
            obj.lo_source.on = true;
            [obj.iZero, obj.qZero] = obj.CalibrateZero();
            
            obj.loFreqs = [obj.loFreqs,obj.lo_freq];
            obj.iZeros = [obj.iZeros, obj.iZero];
            obj.qZeros = [obj.qZeros, obj.qZero];
            % obj.sbCompensations = [obj.sbCompensations,];
            [loFreqs_,idx] = unique(obj.loFreqs);
            iZeros_ = obj.iZeros(idx);
            qZeros_ = obj.qZeros(idx);
            
            [loFreqs_,idx] = sort(loFreqs_,'ascend');
            iZeros_ = iZeros_(idx);
            qZeros_ = qZeros_(idx);
            
            obj.awg.iqCalDataSet(obj.iqCalDataSetIdx) =...
                struct('loFreq',loFreqs_,...
                'iZero',iZeros_,'qZero',qZeros_,...
                'sbFreq',[],'sbCompensation',[]);
            
            sbCompensation = CalibrateSideband(obj);
			obj.data = struct('iZeros',obj.iZero,'qZero',obj.qZero,...
				'sbCompensation',sbCompensation,...
                'iqAmp',obj.iqAmp,'loPower',obj.lo_power);
            
            obj.sbFreqs = [obj.sbFreqs,obj.sb_freq];
            obj.sbCompensations = [obj.sbCompensations,sbCompensation];
			obj.dataready = true;
        end
    end
    methods(Access = private)
        function [x, y] = CalibrateZero(obj)
            if ~isempty(obj.iZero) && ~isempty(obj.qZero)
                x = obj.iZero;
                y = obj.qZero;
                return;
            end
            I = qes.waveform.dc(obj.pulse_ln);
            I.awg = obj.awg;
            I.awgchnl = obj.i_chnl;
            Q = copy(I);
            Q.awg = obj.awg;
            Q.awgchnl = obj.q_chnl;
            p1 = qes.expParam(I,'dcval');
            p2 = qes.expParam(Q,'dcval');
            p1.callbacks = {@(x_) x_.expobj.awg.RunContinuousWv(x_.expobj)};
            p2.callbacks = p1.callbacks;
            
            obj.spc_amp_obj.freq = obj.lo_freq;
            f = qes.expFcn([p1, p2],obj.spc_amp_obj);
%             x = 0;
%             y = 0;
%             precision = obj.awg.vpp/8;
%             stopPrecision = obj.awg.vpp/1e5;
%             while precision >= stopPrecision
%                 l = f(x-precision,y);
%                 c = f(x,y);
%                 r = f(x+precision,y);
%                 dx = precision*qes.util.minPos(l, c, r)
%                 x = x+dx
%                 
%                 l = f(x,y-precision);
%                 c = f(x,y);
%                 r = f(x,y+precision);
%                 dy = precision*qes.util.minPos(l, c, r)
%                 y = y+dy;
%                 dx_ = dx;
%                 dy_ = dy;
%                 if sign(dx*dx_)|| sign(dy*dy_)<0
%                     precision =precision/2;
%                 end
%                 precision
%             end
            
            opts = optimset('Display','notify','MaxIter',30,'TolX',0.2,'TolFun',0.1,'PlotFcns',{@optimplotfval});%,'PlotFcns',''); % current value and history
            lb = [-obj.awg.vpp/8, -obj.awg.vpp/8];
            ub = [obj.awg.vpp/8, obj.awg.vpp/8];
            xsol = qes.util.fminsearchbnd(f.fcn,[0,0],lb,ub,opts);
            x = xsol(1);
            y = xsol(2);
			
			if obj.debug
                f(0,0);
                instr = qes.qHandle.FindByClass('qes.hwdriver.sync.spectrumAnalyzer');
                spcAnalyzerObj = instr{1};

                startfreq_backup = spcAnalyzerObj.startfreq;
                stopfreq_backup = spcAnalyzerObj.stopfreq;
                bandwidth_backup = spcAnalyzerObj.bandwidth;
                numpts_backup = spcAnalyzerObj.numpts;

                spcAnalyzerObj.startfreq = obj.lo_freq - 10e6;
                spcAnalyzerObj.stopfreq = obj.lo_freq + 10e6;
                spcAnalyzerObj.bandwidth = 10e3;
                spcAnalyzerObj.numpts = 4001;
                spcAmpBeforeCal = spcAnalyzerObj.get_trace();

                f(x,y);
                spcAmpAfterCal = spcAnalyzerObj.get_trace();
                freq4plot = linspace(spcAnalyzerObj.startfreq,...
                    spcAnalyzerObj.stopfreq,spcAnalyzerObj.numpts)/1e9;
                figure();
                plot(freq4plot,spcAmpBeforeCal,freq4plot,spcAmpAfterCal);
                xlabel('Frequency(GHz)');
                ylabel('Amplitude');
                legend({'before calibration','after calibration'});

                spcAnalyzerObj.startfreq = startfreq_backup;
                spcAnalyzerObj.stopfreq = stopfreq_backup;
                spcAnalyzerObj.bandwidth = bandwidth_backup;
                spcAnalyzerObj.numpts = numpts_backup;
            end
			
			obj.awg.StopContinuousWv(I);
            obj.awg.StopContinuousWv(Q);
        end
        function x = CalibrateSideband(obj)
			% todo: correct mixer zero with the calibration
			% result of the previous step.
			
			awg_ = obj.awg;
			awgchnl_ = [obj.i_chnl, obj.q_chnl];
            IQ = qes.waveform.dc(obj.pulse_ln);
            IQ.dcval = obj.iqAmp;
            
            IQ.df = obj.sb_freq/2e9;
%             IQ.q_delay = obj.q_delay;
            IQ.awg = awg_;
            IQ.awgchnl = awgchnl_;
			IQ_op = copy(IQ);
			IQ_op.df = -obj.sb_freq/2e9;
            

            function wv = calWv(comp_)
				wv = IQ + comp_*IQ_op;
				wv.awg = awg_;
				wv.awgchnl = awgchnl_;
			end
			
			p = qes.expParam(@calWv);
			p.callbacks ={@(x_) x_.expobj.awg.RunContinuousWv(x_.expobj)};
            
            obj.spc_amp_obj.freq = obj.lo_freq;
            f = qes.expFcn(p,obj.spc_amp_obj);

%             precision = 1;
% 			x = 0*1j;
%             while precision > 1e-5
%                 l = f(x-precision);
%                 c = f(x);
%                 r = f(x+precision);
%                 dr = precision*qes.util.minPos(l, c, r);
%                 x = x+dr;
%                 
%                 l = f(x-1j*precision);
%                 c = f(x);
%                 r = f(x+1j*precision);
%                 di = precision*qes.util.minPos(l, c, r);
%                 x = x+1j*di;
%                 precision = max(precision/2, max(abs(dr), abs(di)));
%             end
            
            opts = optimset('Display','notify','MaxIter',30,'TolX',0.0001,'TolFun',0.1,'PlotFcns',{@optimplotfval});%,'PlotFcns',''); % current value and history
            xsol = fminsearch(f.fcn,0,opts);
            x = xsol(1);
			
			if obj.debug
                f(0);
                instr = qes.qHandle.FindByClass('qes.hwdriver.sync.spectrumAnalyzer');
                spcAnalyzerObj = instr{1};

                startfreq_backup = spcAnalyzerObj.startfreq;
                stopfreq_backup = spcAnalyzerObj.stopfreq;
                bandwidth_backup = spcAnalyzerObj.bandwidth;
                numpts_backup = spcAnalyzerObj.numpts;

                spcAnalyzerObj.startfreq = obj.lo_freq - obj.sb_freq - 10e6;
                spcAnalyzerObj.stopfreq = obj.lo_freq - obj.sb_freq + 10e6;
                spcAnalyzerObj.bandwidth = 10e3;
                spcAnalyzerObj.numpts = 4001;
                spcAmpBeforeCal_neg = spcAnalyzerObj.get_trace();
                freq4plot = linspace(spcAnalyzerObj.startfreq,...
                    spcAnalyzerObj.stopfreq,spcAnalyzerObj.numpts)/1e9;

                spcAnalyzerObj.startfreq = obj.lo_freq + obj.sb_freq - 10e6;
                spcAnalyzerObj.stopfreq = obj.lo_freq + obj.sb_freq + 10e6;
                spcAnalyzerObj.bandwidth = 10e3;
                spcAnalyzerObj.numpts = 4001;
                spcAmpBeforeCal_pos = spcAnalyzerObj.get_trace();
                freq4plot = [freq4plot, linspace(spcAnalyzerObj.startfreq,...
                    spcAnalyzerObj.stopfreq,spcAnalyzerObj.numpts)/1e9];

                spcAmpBeforeCal = [spcAmpBeforeCal_neg, spcAmpBeforeCal_pos];

                f(x);
                spcAmpAfterCal_pos = spcAnalyzerObj.get_trace();

                spcAnalyzerObj.startfreq = obj.lo_freq - obj.sb_freq - 10e6;
                spcAnalyzerObj.stopfreq = obj.lo_freq - obj.sb_freq + 10e6;
                spcAnalyzerObj.bandwidth = 10e3;
                spcAnalyzerObj.numpts = 4001;
                spcAmpAfterCal = [spcAnalyzerObj.get_trace(), spcAmpAfterCal_pos];

                figure();
                plot(freq4plot,spcAmpBeforeCal,freq4plot,spcAmpAfterCal);
                xlabel('Frequency(GHz)');
                ylabel('Amplitude');
                legend({'before calibration','after calibration'});

                spcAnalyzerObj.startfreq = startfreq_backup;
                spcAnalyzerObj.stopfreq = stopfreq_backup;
                spcAnalyzerObj.bandwidth = bandwidth_backup;
                spcAnalyzerObj.numpts = numpts_backup;
            end
			
			obj.awg.StopContinuousWv(IQ);
        end
    end


end