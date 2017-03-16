function iqChnl(varargin)
    % run this function to calibrate iq channels
    % signiture
    % iqChnl('awgName',n,'chnlSet',s,'maxSbFreq',fsbMax,'sbFreqStep',dfsb...
	%		'loFreqStart',flo0,'loFreqStop',flo1,'loFreqStep',dflo,'gui',false)
	% awgName: name of the awg to calibrate
	% chnlSet: channel set to calibrate, it is a settings group in:
	% settingsRoot\calibration\awgName\
	% sideband frequency: -maxSbFreq:sbFreqStep:maxSbFreq
	% lo frequency: loFreqStart:loFreqStep:loFreqStop

% Yulin Wu, 2017

    fcn_name = 'iqChnl'; % this and args will be saved with data
    args = util.process_args(varargin,{'gui',false,'notes','','save',true});
%     args = util.process_args(varargin);
    
    try
        QS = qes.qSettings.GetInstance();
    catch
        throw(MException('QOS_calibration_iqChnl:qSettingsNotCreated',...
			'qSettings not created: create the qSettings object, set user and select session first(only need to do once).');
    end
    s = qes.util.loadSettings(QS.root,{'calibration',awgName,'iq',chnlSet});

    awgObj = qes.qHandle.FindByClassProp('qes.hwdriver.sync.awg',awgName);
    awgchnls = args.awgchnls;
    spcAnalyzer = qes.qHandle.FindByClassProp('qes.hwdriver.sync.spectrumAnalyzer',s.spc_analyzer);
    spcAmpObj = qes.measurement.specAmp(spcAnalyzer);
    loSource = qes.qHandle.FindByClassProp('qes.hwdriver.sync.mwSource',s.lo_source);
    Calibrator = qes.measurement.iqiqMixerCalibrator(awgObj,awgchnls,spcAmpObj,loSource);
    Calibrator.lo_power = s.lo_power;
    Calibrator.q_delay = s.q_delay;
    Calibrator.pulse_ln = s.pulse_ln;
    
    x = qes.expParam(Calibrator,'lo_freq');
    y = qes.expParam(Calibrator,'sb_freq');

    s1 = sweep(x);
    s1.vals = args.loFreq;
    s2 = sweep(y);
    s2.vals = args.sbFreq;
    e = experiment();
    e.sweeps = {s1,s2};
    e.measurements = Calibrator;

    if ~args.gui
        e.showctrlpanel = false;
        e.plotdata = false;
    end
    if ~args.save
        e.savedata = false;
    end
    e.notes = args.notes;
    e.addSettings({'fcn','args'},{fcn_name,args});
    e.Run();

    data = e.data{1};
	
end