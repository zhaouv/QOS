function varargout = ustcDAZeroOffser(varargin)
    % run this function to calibrate USTC DA zero offset
    % 
    % awgZero('awgName',_c_,'chnl',_i_,'voltMeterName',_c_,...
    %       'gui',<_b_>,'save',<_b_>);
	% awgName: name of the awg to calibrate
	% chnl: channel to calibrate

% Yulin Wu, 2017

    args = qes.util.processArgs(varargin,{'debug',false,'avgnum',1,'gui',false,'save',true});
    try
        QS = qes.qSettings.GetInstance();
    catch
        throw(MException('QOS_calibration_awgZero:qSettingsNotCreated',...
			'qSettings not created: create the qSettings object, set user and select session first.'));
    end

    awgObj = qes.qHandle.FindByClassProp('qes.hwdriver.sync.awg','name',args.awgName);
    voltMeter = qes.qHandle.FindByClassProp('qes.hwdriver.sync.voltMeter','name',args.voltMeterName);
    vM = qes.measurement.dcVoltage(voltMeter);
    Calibrator = qes.measurement.awgZeroCalibrator(awgObj,args.chnl,vM);
    zero = Calibrator();
    
    if args.save
        awgChnlMap = cell2mat(QS.loadHwSettings({args.awgName,'interface','chnlMap'}));
        backendChnlMap = QS.loadHwSettings({'ustcadda','da_chnl_map'});
        tempVar = strsplit(regexprep(backendChnlMap{awgChnlMap(args.chnl)},'\s+',''),',');
        QS.saveSSettings({'ustcadda',...
            sprintf('da_boards{%s}',tempVar{1}),...
            sprintf('offsetCorr{%s}',tempVar{2})},num2str(zero,'%0.0f'));
    end 
    varargout{1} = zero;
end