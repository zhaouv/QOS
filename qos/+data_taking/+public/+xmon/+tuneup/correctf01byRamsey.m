function varargout = correctf01byRamsey(varargin)
% correct f01 at the current working point(defined by zdc_amp in registry)
% by ramsey: f01 already set previously, correctf01byRamsey is just to
% remeasure f01 in case f01 has drifted away slightly.
% note: T2* time can not be too short
%
% <_f_> = correctf01byRamsey('qubit',_c&o_,...
%       'gui',<_b_>,'save',<_b_>)
% _f_: float
% _i_: integer
% _c_: char or char string
% _b_: boolean
% _o_: object
% a&b: default type is a, but type b is also acceptable
% []: can be an array, scalar also acceptable
% {}: must be a cell array
% <>: optional, for input arguments, assume the default value if not specified
% arguments order not important as long as they form correct pairs.
    
    % Yulin Wu, 2017/4/14
    
    MAXFREQDRIFT = 10e6;
    DELAYTIMERANGE = 4e-6;
    
    import data_taking.public.xmon.ramsey
    
    args = qes.util.processArgs(varargin,{'gui',false,'save',true});
	q = data_taking.public.util.getQubits(args,{'qubit'});
    da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware','name',...
		q.channels.xy_i.instru);
    ad = qes.qHandle.FindByClassProp('qes.hwdriver.hardware','name',...
		q.channels.r_ad_i.instru);
    adDelayStep = ad.delayStep;
    daSamplingRate = da.samplingRate;
    
    t = unique(adDelayStep*round(...
        linspace(0,DELAYTIMERANGE,DELAYTIMERANGE*2*MAXFREQDRIFT*2)*daSamplingRate/adDelayStep));
    e = ramsey('qubit','q2','mode','dp',... 
      'time',t,'detuning',MAXFREQDRIFT,'gui',false,'save',false);
    Pp = e.data{1};
    rP = range(Pp);
    if rP < 0.2
        throw(MException('QOS_correctf01byRamsey:visibilityTooLow',...
				'visibility(%0.2f) too low, run correctf01byRamsey at low visibility might produce wrong result, thus not supported.', rP));
    end
    e = ramsey('qubit','q2','mode','dp',... 
      'time',t,'detuning',-MAXFREQDRIFT,'gui',false,'save',false);
    Pn = e.data{1};
    t = t/daSamplingRate;
    [Frequency,Amp] = qes.util.fftSpectrum(t,Pp);
    idx = Frequency > 0.5*MAXFREQDRIFT;
    Frequency = Frequency(idx);
    Amp = Amp(idx);
    [~, maxIdx] = max(Amp);
    fp = Frequency(maxIdx);
    
    [Frequency,Amp] = qes.util.fftSpectrum(t,Pn);
    Frequency = Frequency(idx);
    Amp = Amp(idx);
    [~, maxIdx] = max(Amp);
    fn = Frequency(maxIdx);
    
    f01 = q.f01+(fn-fp)/2;
    
	if args.save
        QS = qes.qSettings.GetInstance();
        QS.saveSSettings({q.name,'f01'},f01);
    end
	varargout{2} = f01;
end
