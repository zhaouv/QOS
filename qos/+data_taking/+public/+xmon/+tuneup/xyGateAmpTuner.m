function varargout = xyGateAmpTuner(varargin)
% tune xy gate amplitude: X, X/2, -X/2, X/4, -X/4, Y, Y/2, -Y/2, Y/4, -Y/4
% 
% <_f_> = xyGateAmpTuner('qubit',_c&o_,'gateTyp',_c_,...
%		'AE',<_b_>,...  % insert multiple Idle gate(implemented by two pi rotations) to Amplify Error or not
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
% arguments order not important as long as the form correct pairs.
    
    % Yulin Wu, 2017/1/8
    import data_taking.public.xmon.rabi_amp1
	
	NUM_RABI_SAMPLING_PTS = 70;
	NUM_RABI_SAMPLING_PTS_AE = 35;
	MIN_VISIBILITY = 0.3;
	AE_NUM_PI = 11; % must be an positive odd number
	
	args = qes.util.processArgs(varargin,{'AE',false,'gui',false,'save',true});
	q = data_taking.public.util.getQubits(args,{'qubit'});
    fMat = q.r_iq2prob_fMat;
    vis = (fMat(1)-fMat(2)+fMat(4)-fMat(3))/2;
    if vis < 0.2
        throw(MException('QOS_xyGateAmpTuner:visibilityTooLow',...
				sprintf('visibility(%0.2f) too low, run xyGateAmpTuner at low visibility might produce wrong result, thus not supported.', vis)));
    end
    q.r_iq2prob_normalize = true;
	da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                        'name', q.channels.xy_i.instru);
	switch args.gateTyp
		case {'X','Y'}
			maxAmp = da.vpp/2;
		case {'X/2','-X/2','X2m','X2p','Y/2','-Y/2','Y2m','Y2p'}
			maxAmp = da.vpp/4;
        case {'X/4','-X/4','X4m','X4p','Y/4','-Y/4','Y4m','Y4p'}
			maxAmp = da.vpp/8;
		otherwise
			throw(MException('QOS_xyGateAmpTuner:unsupportedGataType',...
				sprintf('gate %s is not supported, supported types are %s',args.gateTyp,...
				'X Y X/2 -X/2 X2m X2p X/4 -X/4 X4m X4p Y/2 -Y/2 Y2m Y2p Y/4 -Y/4 Y4m Y4p')));
	end
	amps = linspace(0,(1-da.dynamicReserve)*da.vpp/2,NUM_RABI_SAMPLING_PTS);
	e = rabi_amp1('qubit',q,'biasAmp',0,'biasLonger',0,'xyDriveAmp',amps,...
		'detuning',0,'driveTyp',args.gateTyp,'gui',false,'save',false);
	P = e.data{1};
	rP = range(P);
	P0 = min(P);
	P1 = max(P);
	if rP < MIN_VISIBILITY
		throw(MException('QOS_xyGateAmpTuner:visibilityTooLow',...
				sprintf('visibility(%0.2f) too low, run xyGateAmpTuner at low visibility might produce wrong result, thus not supported.', rP)));
	elseif rP < 5/sqrt(q.r_avg)
		throw(MException('QOS_xyGateAmpTuner:rAvgTooLow',...
				'readout average number %d too small.', q.r_avg));
    end
    
    gateAmp = findsPkLoc(amps,P);
    
%     [pks,locs,~,~] = findpeaks(P,'MinPeakHeight',2*rP/3,...
%         'MinPeakProminence',rP/2,'MinPeakDistance',numel(P)/4,...
%         'WidthReference','halfprom');
%     if ~isempty(pks)
%         [locs,idx] = sort(locs,'ascend');
%         pks = pks(idx);
% 
%         maxIdx = locs(1);
%         if numel(pks) > 3
%             throw(MException('QOS_xyGateAmpTuner:tooManyOscCycles',...
%                     'too many oscillation cycles or data SNR too low.'));
%         end
%         dP = pks(1)-P;
%     else
%         [mP,maxIdx] = max(P);
%         dP = mP-P;
%     end
%     
% 	
% 	idx1 = find(dP(maxIdx:-1:1)>rP/4,1,'first');
% 	if isempty(idx1)
% 		idx1 = 1;
% 	else
% 		idx1 = maxIdx-idx1+1;
% 	end
% 	
% 	idx2 = find(dP(maxIdx:end)>rP/4,1,'first');
% 	if isempty(idx2)
% 		idx2 = NUM_RABI_SAMPLING_PTS;
% 	else
% 		idx2 = maxIdx+idx2-1;
%     end
% %	 [~, gateAmp, ~, ~] = toolbox.data_tool.fitting.gaussianFit.gaussianFit(...
% %		 amps(idx1:idx2),P(idx1:idx2),maxP,amps(maxIdx),amps(idx2)-amp(idx1));
% 
% 	% gateAmp = roots(polyder(polyfit(amps(idx1:idx2),P(idx1:idx2),2)));
%     warning('off');
% 	p = polyfit(amps(idx1:idx2),P(idx1:idx2),2);
%     warning('on');
% 	if mean(abs(polyval(p,amps(idx1:idx2))-P(idx1:idx2))) > range(P(idx1:idx2))/4
% 		throw(MException('QOS_xyGateAmpTuner:fittingFailed','fitting error too large.'));
% 	end
% 	gateAmp = roots(polyder(p));
% 	
% 	if gateAmp < amps(idx1) || gateAmp > amps(idx2)
% 		throw(MException('QOS_xyGateAmpTuner:xyGateAmpTuner',...
% 				'gate amplitude probably out of range.'));
%     end
	
	if args.AE  % use multiple pi gates to amplify error to fine tune gateAmp
		amps_ae = linspace(0.9*gateAmp,min(da.vpp,1.1*gateAmp),NUM_RABI_SAMPLING_PTS_AE);
		e = rabi_amp1('qubit',q,'biasAmp',0,'biasLonger',0,'xyDriveAmp',amps_ae,...
			'detuning',0,'numPi',AE_NUM_PI,'driveTyp',args.gateTyp,'gui',false,'save',false);
		P_ae = e.data{1};
		if max(P_ae) < P0 + MIN_VISIBILITY
			warning('QOS_xyGateAmpTuner:visibilityTooLow',...
				'AE visibility too low, AE result not used.');
		else
% 			P_aeS = smooth(P_ae,5);
% 			rP = range(P_aeS);
% 			[pks,locs,~,~] = findpeaks(P_aeS,'MinPeakHeight',2*rP/3,...
% 				'MinPeakProminence',rP/2,'MinPeakDistance',numel(P_aeS)/4,...
% 				'WidthReference','halfprom');
            try
                gateAmp_f = findsPkLoc(amps_ae,P_ae);
            catch
                gateAmp_f = [];
            end
			if ~isempty(gateAmp_f)
				gateAmp = gateAmp_f;
            else
                args.AE = false;
            end
		end
	end

	if args.gui
		h = qes.ui.qosFigure(sprintf('XY Gate Tuner | %s: %s', q.name, args.gateTyp),true);
		ax = axes('parent',h);
		plot(ax,amps,P,'-b');
		hold(ax,'on');
        if args.AE
           plot(ax,amps_ae,P_ae);
        end
        ylim = get(ax,'YLim');
        plot(ax,[gateAmp,gateAmp],ylim,'--r');
		xlabel(ax,'xy drive amplitude');
		ylabel(ax,'P|1>');
        if args.AE
            legend(ax,{'data(1\pi)',...
                sprintf('data(AE:%0.0f\pi)',AE_NUM_PI),...
                sprintf('%s gate amplitude',args.gateTyp)});
        else
            legend(ax,{'data(1\pi)',sprintf('%s gate amplitude',args.gateTyp)});
        end
        set(ax,'YLim',ylim);
        drawnow;
	end
	
    if args.save
        QS = qes.qSettings.GetInstance();
		switch args.gateTyp
			case 'X'
				QS.saveSSettings({q.name,'g_X_amp'},gateAmp);
			case {'X/2','X2p'}
				QS.saveSSettings({q.name,'g_X2p_amp'},gateAmp);
			case {'-X/2','X2m'}
				QS.saveSSettings({q.name,'g_X2m_amp'},gateAmp);
            case {'X/4','X4p'}
				QS.saveSSettings({q.name,'g_X4p_amp'},gateAmp);
            case {'-X/4','X4m'}
				QS.saveSSettings({q.name,'g_X4m_amp'},gateAmp);
			case 'Y'
				QS.saveSSettings({q.name,'g_Y_amp'},gateAmp);
			case {'Y/2', 'Y2p'}
				QS.saveSSettings({q.name,'g_Y2p_amp'},gateAmp);
			case {'-Y/2', 'Y2m'}
				QS.saveSSettings({q.name,'g_Y2m_amp'},gateAmp);
            case {'Y/4','Y4p'}
				QS.saveSSettings({q.name,'g_Y4p_amp'},gateAmp);
            case {'-Y/4','Y4m'}
				QS.saveSSettings({q.name,'g_Y4m_amp'},gateAmp);
		end
    end
	varargout{1} = gateAmp;
end

function xp = findsPkLoc(x,y)
    rng = range(y);
    [pks,locs,~,~] = findpeaks(y,'MinPeakHeight',2*rng/3,...
        'MinPeakProminence',rng/2,'MinPeakDistance',numel(x)/4,...
        'WidthReference','halfprom');
    
    if ~isempty(pks)
        [locs,idx] = sort(locs,'ascend');
        pks = pks(idx);

        maxIdx = locs(1);
        if numel(pks) > 3
            throw(MException('QOS_xyGateAmpTuner:tooManyOscCycles',...
                    'too many oscillation cycles or data SNR too low.'));
        end
        dy = pks(1)-y;
    else
        [mP,maxIdx] = max(y);
        dy = mP-y;
    end

	idx1 = find(dy(maxIdx:-1:1)>rng/3,1,'first');
	if isempty(idx1)
		idx1 = 1;
	else
		idx1 = maxIdx-idx1+1;
	end
	
	idx2 = find(dy(maxIdx:end)>rng/4,1,'first');
	if isempty(idx2)
		idx2 = numel(x);
	else
		idx2 = maxIdx+idx2-1;
    end
%	 [~, gateAmp, ~, ~] = toolbox.data_tool.fitting.gaussianFit.gaussianFit(...
%		 amps(idx1:idx2),P(idx1:idx2),maxP,amps(maxIdx),amps(idx2)-amp(idx1));

	% gateAmp = roots(polyder(polyfit(amps(idx1:idx2),P(idx1:idx2),2)));
    warning('off');
	p = polyfit(x(idx1:idx2),y(idx1:idx2),2);
    warning('on');
	if mean(abs(polyval(p,x(idx1:idx2))-y(idx1:idx2))) > range(y(idx1:idx2))/4
		throw(MException('QOS_xyGateAmpTuner:fittingFailed','fitting error too large.'));
	end
	xp = roots(polyder(p));

    if xp < x(idx1) || xp > x(idx2)
		throw(MException('QOS_xyGateAmpTuner:xyGateAmpTuner',...
				'gate amplitude probably out of range.'));
    end
end