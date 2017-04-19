function varargout = iqChnl(varargin)
    % run this function to calibrate iq channels
    % 
    % iqChnl('awgName',_c_,'chnlSet',_c_,'maxSbFreq',_f_,'sbFreqStep',_f_...
	%		'loFreqStart',_f_,'loFreqStop',_f_,'loFreqStep',_f_,...
    %       'gui',<_b_>,'save',<_b_>);
	% awgName: name of the awg to calibrate
	% chnlSet: channel set to calibrate, it is a settings group in:
	% settingsRoot\calibration\awgName\
	% sideband frequency: -maxSbFreq:sbFreqStep:maxSbFreq
	% lo frequency: loFreqStart:loFreqStep:loFreqStop

% Yulin Wu, 2017

    fcn_name = 'data_taking.public.calibration.iqChnl'; % this and args will be saved with data
    args = qes.util.processArgs(varargin,{'gui',false,'save',true});
    try
        QS = qes.qSettings.GetInstance();
    catch
        throw(MException('QOS_calibration_iqChnl:qSettingsNotCreated',...
			'qSettings not created: create the qSettings object, set user and select session first.'));
    end
    s = qes.util.loadSettings(QS.root,{'calibration',args.awgName,'iq',args.chnlSet});

    awgObj = qes.qHandle.FindByClassProp('qes.hwdriver.sync.awg','name',args.awgName);
    awgchnls = s.chnls;
    spcAnalyzer = qes.qHandle.FindByClassProp('qes.hwdriver.sync.spectrumAnalyzer','name',s.spc_analyzer);
    spcAmpObj = qes.measurement.specAmp(spcAnalyzer);
    spcAmpObj.avgnum = 2;
    
    mwSrc = qes.qHandle.FindByClassProp('qes.hwdriver.sync.mwSource','name',s.lo_source);
    loSource = mwSrc.GetChnl(s.lo_chnl);
    Calibrator = qes.measurement.iqMixerCalibrator(awgObj,awgchnls,spcAmpObj,loSource);
    Calibrator.lo_power = s.lo_power;
%     Calibrator.q_delay = s.q_delay;

    x = qes.expParam(Calibrator,'lo_freq');
    y = qes.expParam(Calibrator,'sb_freq');
    y_s = qes.expParam(Calibrator,'pulse_ln');
    loFreq=args.loFreqStart:args.loFreqStep:args.loFreqStop;
    sbFreq=-args.maxSbFreq:args.sbFreqStep:args.maxSbFreq;

    sbFreq(abs(sbFreq)<3.5e4)=[];
    s1 = qes.sweep(x);

    s1.vals = loFreq;
    s2 = sweep({y_s,y});
    ln = awgObj.samplingRate./sbFreq;
    ln = ceil(ln);
%     for ii = 1:ln
%         d = ceil(ln(ii)) - ln(ii);
%         if d ~= 0
%             N = 1/d;
%             ln(ii) = ln(ii)*N;
%         end
%     end
    ln(ln>30e3) = 30e3;
    s2.vals = {ln,sbFreq};
    e = experiment();
    e.sweeps = [s1,s2];

    e.measurements = Calibrator;
    e.datafileprefix = 'iqChnlCal';
    e.savedata = true;
    e.addSettings({'fcn','args'},{fcn_name,args});
    e.Run();
    data = cell2mat(e.data{1});
    iZeros = [data.iZeros];
    qZeros = [data.qZeros];
    sbCompensation = [data.sbCompensation];
    iZeros=unique(iZeros);
    qZeros=unique(qZeros);
    sbCompensation = reshape(sbCompensation,[numel(loFreq),numel(sbFreq)]); % Row is loFreq, Column is sbFreq
    iqAmp = data(1).iqAmp;
    loPower = data(1).loPower;
    
    timeStamp = now;
    if args.save
        dataFileDir = fullfile(QS.root,'calibration',args.awgName,'iq',args.chnlSet,'_data');
        if isempty(dir(dataFileDir))
            mkdir(dataFileDir);
        end
        save(fullfile(timeStamp,datestr(now,'yymmTDDHHMMSS')),...
            'iZeros','qZeros','sbCompensation','iqAmp','loPower','timeStamp','loFreq','sbFreq');
    end
    varargout{1} = e.data{1};
end