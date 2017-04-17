function varargout = correctf01bySpc(varargin)
% correct f01 at the current working point(defined by zdc_amp in registry)
% by spectroscopy: f01 already set previously, correctf01bySpc is just to
% remeasure f01 in case f01 has drifted away slightly.
% note: estimation of the FWHM of the spectrum peak(t_spcFWHM_est) must be
% set with a resonable value, otherwise measuref01 might produce an
% incorrect result.
%
% <_f_> = correctf01bySpc('qubit',_c&o_,...
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
    
    import data_taking.public.xmon.spectroscopy1_zpa
    
    args = qes.util.processArgs(varargin,{'gui',false,'save',true});
	q = data_taking.public.util.getQubits(args,{'qubit'});

    f = q.f01-3*q.t_spcFWHM_est:q.t_spcFWHM_est/10:q.f01+3*q.t_spcFWHM_est;
    e = spectroscopy1_zpa('qubit',q,'driveFreq',f,'save',false,'gui',false);
    P = e.data{1};
    rP = range(P);
    if rP < 0.15
        throw(MException('QOS_correctf01bySpc:visibilityTooLow',...
				'visibility(%0.2f) too low, run correctf01bySpc at low visibility might produce wrong result, thus not supported.', rP));
    end
    [~,idx] = max(smooth(P,5));
    f01 = f(idx);
    
	if args.save
        QS = qes.qSettings.GetInstance();
        QS.saveSSettings({q.name,'f01'},f01);
    end
	varargout{2} = f01;
end
