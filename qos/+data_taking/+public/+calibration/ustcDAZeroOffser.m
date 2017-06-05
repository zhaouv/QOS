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
    
    if args.save
        awgChnlMap = cell2mat(QS.loadHwSettings({args.awgName,'interface','chnlMap'}));
        backendChnlMap = QS.loadHwSettings({'ustcadda','da_chnl_map'});
        boardIndChnlInd = strsplit(regexprep(backendChnlMap{awgChnlMap(args.chnl)},'\s+',''),',');
        fieldNameList = {'ustcadda',...
            sprintf('da_boards{%s}',boardIndChnlInd{1}),...
            sprintf('offsetCorr{%s}',boardIndChnlInd{2})};
    end
    
    Calibrator = qes.measurement.awgZeroCalibrator(awgObj,args.chnl,vM);
    if args.gui
        Calibrator.showProcess = true;
    end
    offsetCorr = Calibrator();
    
    if args.save
        da_boards = QS.loadHwSettings({'ustcadda','da_boards'});
        offsetCorr_old = da_boards{str2double(boardIndChnlInd{1})}.offsetCorr{str2double(boardIndChnlInd{2})};
        QS.saveHwSettings(fieldNameList,num2str(offsetCorr_old+offsetCorr,'%0.0f'));
    end 
    varargout{1} = offsetCorr;
end