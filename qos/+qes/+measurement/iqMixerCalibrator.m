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
        
        showProcess@logical scalar = false
        calSideband@logical scalar = true
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
        
        SPC_AMP_MIN = -130
        MAX_ITER_NUM = 25;
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
			obj.spc_amp_obj = spcAmpObj;
			obj.lo_source = loSource;
            obj.numericscalardata = false;
            
            obj.awg.iqCalDataSet = []; % clear loaded iqCalDataSet is important!

            numIQCalDataSet = numel(obj.awg.iqCalDataSet);
            if numIQCalDataSet==0
                obj.awg.iqCalDataSet = struct(...
                        'chnls',[],'loFreq',[],'iZero',[],'qZero',[],'sbFreq',[],'sbCompensation',[]); % loPower is import but not needed by the awg, thus not included
                obj.iqCalDataSetIdx = numIQCalDataSet+1;
            end
            for ii = 1:numIQCalDataSet
                if all(obj.awg.iqCalDataSet(ii).chnls == [obj.i_chnl,obj.q_chnl])
                    obj.iqCalDataSetIdx = ii;
                    break;
                elseif ii == numIQCalDataSet
                    obj.awg.iqCalDataSet(end+1) = struct(...
                        'chnls',[],'loFreq',[],'iZero',[],'qZero',[],'sbFreq',[],'sbCompensation',[]); % loPower is import but not needed by the awg, thus not included
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
			Run@qes.measurement.measurement(obj);
            obj.iqAmp = obj.awg.vpp/4;
			obj.lo_source.frequency = obj.lo_freq;
			obj.lo_source.power = obj.lo_power;
            obj.lo_source.on = true;
            [obj.iZero, obj.qZero] = obj.CalibrateZero();
            
            obj.loFreqs = [obj.loFreqs,obj.lo_freq];
            obj.iZeros = [obj.iZeros, obj.iZero];
            obj.qZeros = [obj.qZeros, obj.qZero];
            [loFreqs_,idx] = unique(obj.loFreqs);
            iZeros_ = obj.iZeros(idx);
            qZeros_ = obj.qZeros(idx);
            
            [loFreqs_,idx] = sort(loFreqs_,'ascend');
            iZeros_ = iZeros_(idx);
            qZeros_ = qZeros_(idx);

            obj.awg.iqCalDataSet(obj.iqCalDataSetIdx) =...
                struct('chnls',[obj.i_chnl, obj.q_chnl],...
                'loFreq',loFreqs_,...
                'iZero',iZeros_,'qZero',qZeros_,...
                'sbFreq',[],'sbCompensation',[]);
            
            if obj.calSideband
                sbCompensation = CalibrateSideband(obj);
            else
                sbCompensation=0;
            end
			
            obj.data = struct('iZeros',obj.iZero,'qZeros',obj.qZero,'chnls',[obj.i_chnl, obj.q_chnl],...
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
            
            % search method 1
            if obj.showProcess
                opts = optimset('Display','none','MaxIter',obj.MAX_ITER_NUM,'TolX',0.2,'TolFun',0.1,'PlotFcns',{@optimplotfval});
            else
                opts = optimset('Display','none','MaxIter',obj.MAX_ITER_NUM,'TolX',0.2,'TolFun',0.1,'PlotFcns','');
            end
            lb = [-obj.awg.vpp/10, -obj.awg.vpp/10];
            ub = [obj.awg.vpp/10, obj.awg.vpp/10];
            xsol = qes.util.fminsearchbnd(f.fcn,[0,0],lb,ub,opts);
            x = round(xsol(1));
            y = round(xsol(2));

			if obj.showProcess
                f([0,0]);
                instr = qes.qHandle.FindByClass('qes.hwdriver.sync.spectrumAnalyzer');
                spcAnalyzerObj = instr{1};

                startfreq_backup = spcAnalyzerObj.startfreq;
                stopfreq_backup = spcAnalyzerObj.stopfreq;
                bandwidth_backup = spcAnalyzerObj.bandwidth;
                numpts_backup = spcAnalyzerObj.numpts;

                obj.spc_amp_obj.freq = obj.lo_freq+obj.sb_freq;
                obj.spc_amp_obj.Run()
                bp=obj.spc_amp_obj.data;
                obj.spc_amp_obj.freq = obj.lo_freq;
                obj.spc_amp_obj.Run()
                b0=obj.spc_amp_obj.data;
                obj.spc_amp_obj.freq = obj.lo_freq-obj.sb_freq;
                obj.spc_amp_obj.Run()
                bm=obj.spc_amp_obj.data;
                
                f([x,y]);
                obj.spc_amp_obj.freq = obj.lo_freq-obj.sb_freq;
                obj.spc_amp_obj.Run()
                am=obj.spc_amp_obj.data;
                obj.spc_amp_obj.freq = obj.lo_freq+obj.sb_freq;
                obj.spc_amp_obj.Run()
                ap=obj.spc_amp_obj.data;
                obj.spc_amp_obj.freq = obj.lo_freq;
                obj.spc_amp_obj.Run()
                a0=obj.spc_amp_obj.data;
                
                freq4plot=[obj.lo_freq-obj.sb_freq, obj.lo_freq, obj.lo_freq+obj.sb_freq];

                hf = qes.ui.qosFigure('IQ Mixer Calibration | DC',true);
				ax = axes('Parent',hf);
                plot(ax, freq4plot,[bm,b0,bp],'-o',freq4plot,[am,a0,ap],'-*');
                xlabel(ax, 'Frequency(GHz)');
                ylabel(ax, 'Amplitude');
                title(['I0 = ' num2str(x) ', Q0=' num2str(y)])
                legend(ax, {'before calibration','after calibration'});

                spcAnalyzerObj.startfreq = startfreq_backup;
                spcAnalyzerObj.stopfreq = stopfreq_backup;
                spcAnalyzerObj.bandwidth = bandwidth_backup;
                spcAnalyzerObj.numpts = numpts_backup;
            end
			
			obj.awg.StopContinuousWv(I);
            obj.awg.StopContinuousWv(Q);
        end
        function z = CalibrateSideband(obj)
            if abs(obj.sb_freq) < 5e6 % in practice, sb_freq are  several tens of MHz at least
                z = 0;
                return;
            end
			
            pulse_len = qes.util.best_fit_count(abs(obj.sb_freq));
            
			awg_ = obj.awg;
			awgchnl_ = [obj.i_chnl, obj.q_chnl];
            IQ = qes.waveform.dc(pulse_len);
            IQ.dcval = obj.iqAmp;
            IQ.df = obj.sb_freq/obj.awg.samplingRate;
            IQ.fc = obj.lo_freq;

            IQ.awg = awg_;
            IQ.awgchnl = awgchnl_;     
            
%% Complex component method.            
			IQ_op = copy(IQ);
			IQ_op.df = -obj.sb_freq/obj.awg.samplingRate;
            
            WaveformObj=qes.util.hvar;
            
            function wv = calWv(comp_)
				wv = IQ + comp_(1)*IQ_op+comp_(2)*1j*IQ_op;
				wv.awg = awg_;
				wv.awgchnl = awgchnl_;
                wv.fc=IQ.fc;
                WaveformObj.val=wv;
			end
			
			p = qes.expParam(@calWv);
            p.callbacks ={@(x_) awg_.RunContinuousWv(WaveformObj.val)};
            
            obj.spc_amp_obj.freq = obj.lo_freq-obj.sb_freq;
            f = qes.expFcn(p,obj.spc_amp_obj);
                        
            
            if obj.showProcess
                opts = optimset('Display','none','MaxIter',obj.MAX_ITER_NUM,'TolX',0.01,'TolFun',0.1,'PlotFcns',{@optimplotfval});
            else
                opts = optimset('Display','none','MaxIter',obj.MAX_ITER_NUM,'TolX',0.01,'TolFun',0.1,'PlotFcns','');
            end
            z1 = qes.util.fminsearchbnd(f.fcn,[0,0],[-0.5,-0.5],[0.5,0.5],opts);
            z=z1(1)+1j*z1(2);
            
            depress=f([0,0])-f(z1);
            
            if depress<0
                z1 = qes.util.fminsearchbnd(f.fcn,[0,0],[-0.5,-0.5],[0.5,0.5],opts);
                z=z1(1)+1j*z1(2);
                
                depress=f([0,0])-f(z1);
                
                if depress<0
                    z=0;
                    disp(['WARNING: Phase calibration failed, lo = ' num2str(obj.lo_freq) ', sb = ' num2str(obj.sb_freq)])
                end
            end
            
			if obj.showProcess
                f([0,0]);
                instr = qes.qHandle.FindByClass('qes.hwdriver.sync.spectrumAnalyzer');
                spcAnalyzerObj = instr{1};

                startfreq_backup = spcAnalyzerObj.startfreq;
                stopfreq_backup = spcAnalyzerObj.stopfreq;
                bandwidth_backup = spcAnalyzerObj.bandwidth;
                numpts_backup = spcAnalyzerObj.numpts;

                obj.spc_amp_obj.freq = obj.lo_freq+obj.sb_freq;
                obj.spc_amp_obj.Run()
                bp=obj.spc_amp_obj.data;
                obj.spc_amp_obj.freq = obj.lo_freq;
                obj.spc_amp_obj.Run()
                b0=obj.spc_amp_obj.data;
                obj.spc_amp_obj.freq = obj.lo_freq-obj.sb_freq;
                obj.spc_amp_obj.Run()
                bm=obj.spc_amp_obj.data;
                
                f(z1);
                obj.spc_amp_obj.freq = obj.lo_freq-obj.sb_freq;
                obj.spc_amp_obj.Run()
                am=obj.spc_amp_obj.data;
                obj.spc_amp_obj.freq = obj.lo_freq+obj.sb_freq;
                obj.spc_amp_obj.Run()
                ap=obj.spc_amp_obj.data;
                obj.spc_amp_obj.freq = obj.lo_freq;
                obj.spc_amp_obj.Run()
                a0=obj.spc_amp_obj.data;
                
                freq4plot=[obj.lo_freq-obj.sb_freq, obj.lo_freq, obj.lo_freq+obj.sb_freq];

                hf = qes.ui.qosFigure('IQ Mixer Calibration | DC',true);
				ax = axes('Parent',hf);
                plot(ax,freq4plot,[bm,b0,bp],'-o',freq4plot,[am,a0,ap],'-*');
                xlabel(ax,'Frequency(GHz)');
                ylabel(ax,'Amplitude');
                legend(ax,{'after calibration zero','after calibration phase'});
                if am-bm>0
                    title(ax,'BAD!','color','r')
                else
                    title(ax,'GOOD!','color','g')
                end
                
%                 spcAnalyzerObj.startfreq = obj.lo_freq-abs(obj.sb_freq) - 1e6;
%                 spcAnalyzerObj.stopfreq = obj.lo_freq+abs(obj.sb_freq) + 1e6;
%                 spcAnalyzerObj.bandwidth = 5e3;
%                 spcAnalyzerObj.numpts = 4001;
%                 spcAmpAfterCal = spcAnalyzerObj.get_trace();
%                 
%                 figure(43)
%                 plot(linspace(spcAnalyzerObj.startfreq,spcAnalyzerObj.stopfreq,spcAnalyzerObj.numpts),spcAmpAfterCal);
                
                spcAnalyzerObj.startfreq = startfreq_backup;
                spcAnalyzerObj.stopfreq = stopfreq_backup;
                spcAnalyzerObj.bandwidth = bandwidth_backup;
                spcAnalyzerObj.numpts = numpts_backup;
            end
			
			obj.awg.StopContinuousWv(IQ);
        end
    end


end