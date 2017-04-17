spcAnalyzer = qHandle.FindByClassProp('qes.hwdriver.hardware','name','spcAnalyzer_agl_n9030');
specAmpObj = qes.measurement.specAmp(spcAnalyzer);
specAmpObj.freq = 6e9;
specAmpObj.avgnum  = 1;

awgObj = qHandle.FindByClassProp('qes.hwdriver.hardware','name','da_ustc_1');
mwSrc = qHandle.FindByClassProp('qes.hwdriver.hardware','name','nwSrc_anritsu_mg3692_1');
mwSrcChnl = mwSrc.GetChnl(1);

iqCalibratorObj = qes.measurement.iqMixerCalibrator(awgObj,[2,1],specAmpObj,mwSrcChnl);
iqCalibratorObj.pulse_ln = 25e3;
iqCalibratorObj.lo_freq      % Hz, carrier frequency
iqCalibratorObj.lo_power
iqCalibratorObj.sb_freq % Hz, side band frequency

obj.debug = true;

data = iqCalibratorObj();

% obj.data = struct('iZeros',iZero,'qZero',qZero,...
% 				'sbCompensation',sbCompensation);