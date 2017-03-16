function varargout = f01DcTuningBySpc(varargin)
% tune qubit f01 to a desired frequency by changing dc bias with spectroscopy measurement
%
% <_f_> = f01DcTuningBySpc('qubit',_c&o_,...
%       'f01',_f_,...
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
    
    % Yulin Wu, 2017/3/4
    
    import data_taking.public.xmon.spectroscopy1_zdc
    
    args = util.processArgs(varargin,{'gui',false,'save',true});
	q = copy(getQubits(args,{'qubit'})); % we may need to modify the qubit properties, better make a copy to avoid unwanted modifications to the original.
	
	if isempty(q.zdc_ampCorrection)
		q.zdc_ampCorrection = 0;
	[dcAmp, slop] = sqc.util.f012zdc(q,args.f01);
	
	precision = (3*q.t_spcFWHM_est/...
		q.zdc_amp2f_freqUnit/slop)*q.zdc_amp2f_dcUnit;
	
	if args.gui
		hf = figure('Units','characters',...
                'NumberTitle','off','Name','QES | f01 Dc Tuning By Spc',...
                'Color',[1,1,1],...
                'DockControls','off');
        ax = axes('parent',hf);
		measuredPeakLocLine = line(NaN,NaN,NaN,'parent',ax,'Color',[1,0,0]);
		hold(ax,'on');
		predicatedPeakLocLine = line(NaN,NaN,NaN,'parent',ax,'Color',[0,1,0],'LineStyle','--');
	end

    f01 = args.f01;
    count = 1;
	err = Inf;
    while err > q.t_spcFWHM_est/20 || count <= 10
        dcAmp_r = dcAmp(end) + precision;
        dcAmp_l = dcAmp(end) - precision;
		if count == 1
			FREQ_SEARCH_RNG = 15*q.t_spcFWHM_est;
			f = f01(end)-FREQ_SEARCH_RNG:q.t_spcFWHM_est/10:f01(end)+FREQ_SEARCH_RNG;
		elseif err > 2*q.t_spcFWHM_est
			FREQ_SEARCH_RNG = 10*q.t_spcFWHM_est;
			f = f01(end)-FREQ_SEARCH_RNG:q.t_spcFWHM_est/10:f01(end)+FREQ_SEARCH_RNG;
		elseif err > q.t_spcFWHM_est
			FREQ_SEARCH_RNG = 5*q.t_spcFWHM_est;
			f = f01(end)-FREQ_SEARCH_RNG:q.t_spcFWHM_est/10:f01(end)+FREQ_SEARCH_RNG;
		else
			FREQ_SEARCH_RNG = 2*q.t_spcFWHM_est;
			f = f01(end)-FREQ_SEARCH_RNG:q.t_spcFWHM_est/20:f01(end)+FREQ_SEARCH_RNG;
		end
        
        e = spectroscopy1_zdc('qubit',q,'bias',dcAmp_r,'driveFreq',f,'save',false,'gui',false);
		P_r = smooth(e.data{1},5);
        [~,idx] = max(P_r);
		f01_r = f(idx);
        err_r = abs(f01_r - args.f01);
        
        e = spectroscopy1_zdc('qubit',q,'bias',dcAmp,'driveFreq',f,'save',false,'gui',false);
		P_c = smooth(e.data{1},5);
        [~,idx] = max(P_c);
		f01_c = f(idx);
        err_c = abs(f01_c - args.f01);
        
        e = spectroscopy1_zdc('qubit',q,'bias',dcAmp_l,'driveFreq',f,'save',false,'gui',false);
		P_l = smooth(e.data{1},5);
        [~,idx] = max(P_l);
		f01_l = f(idx);
        err_l = abs(f01_l - args.f01);
        
		d = qes.util.minPos(l, c, r);
        dAmp = precision*d;
		
        dcAmp = [dcAmp, dcAmp(end)+dAmp];
		if d == 0
			precision = precision/2;
			count = count+1;
        end
		err = min([err_r,err_c,err_l]);
		
		f01_ = [f01_l,f01_c,f01_r];
		f01 = [f01, f01_(d+2)];
		
		if args.gui
			P_ = [P_l(:),P_c(:),P_r(:)];
			P = (P_(:,d+2))';
			try
				plot3(ax,dcAmp(end)*ones(1,numel(f)),f,P,'Color',[0,0,1]);
				[dcAmp4Plot, idx] = sort(dcAmp);
				set(measuredPeakLocLine,'XData',dcAmp4Plot,'YData',f01(idx));
				set(predictedPeakLocLine,'XData',dcAmp4Plot,'YData',polyval(q.zdc_amp2f01,dcAmp4Plot));
			catch
                % pass
			end
		end
    end
	
	if args.save
        QS = qes.qSettings.GetInstance();
        QS.saveSSettings({q.name,'f01'},f01(end));
        QS.saveSSettings({q.name,'zdc_amp'},dcAmp(end));
		QS.saveSSettings({q.name,'zdc_ampCorrection'},dcAmp(end)-dcAmp(1)+q.zdc_ampCorrection);
    end
	
	varargout{1} = dcAmp(end);
    varargout{2} = f01(end);
end
