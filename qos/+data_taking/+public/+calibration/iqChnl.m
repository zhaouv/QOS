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
    args = qes.util.process_args(varargin,{'gui',false,'save',true});
    try
        QS = qes.qSettings.GetInstance();
    catch
        throw(MException('QOS_calibration_iqChnl:qSettingsNotCreated',...
			'qSettings not created: create the qSettings object, set user and select session first.'));
    end
    s = qes.util.loadSettings(QS.root,{'calibration',args.awgName,'iq',args.chnlSet});

    awgObj = qes.qHandle.FindByClassProp('qes.hwdriver.sync.awg',args.awgName);
    awgchnls = s.chnls;
    spcAnalyzer = qes.qHandle.FindByClassProp('qes.hwdriver.sync.spectrumAnalyzer',s.spc_analyzer);
    spcAmpObj = qes.measurement.specAmp(spcAnalyzer);
    
    mwSrc = qes.qHandle.FindByClassProp('qes.hwdriver.sync.mwSource',s.lo_source);
    loSource = mwSrc.GetChnl(s.lo_chnl);
    Calibrator = qes.measurement.iqMixerCalibrator(awgObj,awgchnls,spcAmpObj,loSource);
    Calibrator.lo_power = s.lo_power;
%     Calibrator.q_delay = s.q_delay;

    Calibrator.pulse_ln = s.pulse_ln;
    
    x = qes.expParam(Calibrator,'lo_freq');
    y = qes.expParam(Calibrator,'sb_freq');
    y_s = qes.expParam(Calibrator,'pulse_ln');

    s1 = sweep(x);
    s1.vals = args.loFreq;
    s2 = sweep({y_s,y});
    ln = ceil(awgObj.samplingRate/args.sbFreq);
    ln(ln>30e3) = 30e3;
    s2.vals = {args.sbFreq,ln};
    e = experiment();
    e.sweeps = {s1,s2};
    e.measurements = Calibrator;
    e.dataprefix = 'iqChnlCal';
    e.savedata = true;
    e.addSettings({'fcn','args'},{fcn_name,args});
    e.Run();
    data = cell2mat(e.data{1});
    iZeros = [data.iZeros];
    qZeros = [data.qZeros];
    sbCompensation = [data.sbCompensation];
    iqAmp = data(1).iqAmp;
    loPower = data(1).loPower;
    
    timeStamp = now;
    if ~args.save
        dataFileDir = fullfile(QS.root,'calibration',args.awgName,'iq',args.chnlSet,'_data');
        if isempty(dir(dataFileDir))
            mkdir(dataFileDir);
        end
        save(fullfile(timeStamp,datestr(now,'yymmTDDHHMMSS')),...
            'iZeros','qZeros','sbCompensation','iqAmp','loPower','timeStamp');
    end
    varargout{1} = e.data{1};
end