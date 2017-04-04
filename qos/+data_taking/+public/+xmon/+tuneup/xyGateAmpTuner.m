function varargout = xyGateAmpTuner(varargin)
% tune xy gate: X, X/2, -X/2, Y, Y/2, -Y/2
% 
% <_f_> = xyGateAmpTuner('qubit',_c&o_,'gateTyp',_c_,...
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
	
	NUM_RABI_SAMPLING_PTS = 50;
	
	args = util.processArgs(varargin,{'gui',false,'save',true});
	q = copy(data_taking.public.util.getQubits(args,{'qubit'})); % we need to modify the qubit properties, better make a copy to avoid unwanted modifications to the original.
	
	q = data_taking.public.util.getQubits(args,{'qubit'});
	da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware',...
                        'name', q.channels.xy_i.instru);
	switch args.gateTyp
		case {'X','Y'}
			maxAmp = vpp/2;
		case {'X/2','-X/2','X2m','X2p','Y/2','-Y/2','Y2m','Y2p'}
			maxAmp = vpp/4;
		otherwise
			throw(MException('QOS_xyGateAmpTuner:unsupportedGataType',...
				sprintf('gate %s is not supported, supported types are %s',args.gateTyp,...
				'X, Y X/2 -X/2 X2m X2p Y/2 -Y/2 Y2m Y2p')));
	end
	amps = linspace(0,(1-da.dynamicReserve)*da.vpp/2,NUM_RABI_SAMPLING_PTS);
	e = rabi_amp1('qubit',q,'bias',0,'biasLonger',0,'xyDriveAmp',amps,...
		'detuning',0,'driveTyp',args.gateTyp,'gui',false,'save',false);
	P = e.data{1};
	rP = range(P);
	if rP < 0.3
		throw(MException('QOS_xyGateAmpTuner:visibilityTooLow',...
				'visibility too low, at least 0.3 for xyGateAmpTuner to work, %0.2f measured', rP);
	elseif rP < 5/sqrt(q.r_avg)
		throw(MException('QOS_xyGateAmpTuner:rAvgTooLow',...
				'readout average number %d too small.', q.r_avg);
	end
	[maxP,maxIdx] = max(P);
	if maxIdx < NUM_RABI_SAMPLING_PTS/3 ||...
		range(P(max(1,round(maxIdx-NUM_RABI_SAMPLING_PTS/6)):...
		min(NUM_RABI_SAMPLING_PTS,round(maxIdx+NUM_RABI_SAMPLING_PTS/6))))...
		> range(P)/2
		throw(MException('QOS_xyGateAmpTuner:tooManyOscCycles',...
				'too many oscillation cycles or data SNR too low.');
	end
	dP = maxP-P;
	idx1 = find(dP(maxIdx:-1:1)>rP/4,1,'first');
	if isempty(idx1)
		idx1 == 1;
	else
		idx1 = maxIdx-idx1+1;
	end
	
	idx2 = find(dP(maxIdx:end)>rP/4,1,'first');
	if isempty(idx2)
		idx2 == NUM_RABI_SAMPLING_PTS;
	else
		idx2 = maxIdx+idx2-1;
	end
%	 [~, gateAmp, ~, ~] = toolbox.data_tool.fitting.gaussianFit.gaussianFit(...
%		 amps(idx1:idx2),P(idx1:idx2),maxP,amps(maxIdx),amps(idx2)-amp(idx1));

	% gateAmp = roots(polyder(polyfit(amps(idx1:idx2),P(idx1:idx2),2)));
	p = polyfit(amps(idx1:idx2),P(idx1:idx2),3);
	if mean(abs(polyval(p,amps(idx1:idx2))-P(idx1:idx2))) > range(P(idx1:idx2))/4
		throw(MException('QOS_xyGateAmpTuner:fittingFailed','fitting error too large.'));
	end
	gateAmp = roots(polyder(p));
	
	if gateAmp < amps(idx1) || gateAmp > amps(idx2)
		throw(MException('QOS_xyGateAmpTuner:xyGateAmpTuner',...
				'gate amplitude probably out of range.');
	end

	if args.gui
		h = figure();
		ax = axes('parent',h);
		plot(ax,amps,P,'.b');
		hold(ax,'on');
		plot(ax,[gateAmp,gateAmp],[min(P),maxP],'--r');
		xlabel('xy drive amplitude');
		ylabel('P');
	end
	
    if args.save
        QS = qes.qSettings.GetInstance();
		switch args.gateTyp
			case 'X'
				QS.saveSSettings({q.name,'g_X_amp'},q.gateAmp);
			case {'X/2','X2p'}
				QS.saveSSettings({q.name,'g_X2p_amp'},q.gateAmp);
			case {'-X/2','X2m'}
				QS.saveSSettings({q.name,'g_X2m_amp'},q.gateAmp);
			case 'Y'
				QS.saveSSettings({q.name,'g_Y_amp'},q.gateAmp);
			case {'Y/2', 'Y2p'}
				QS.saveSSettings({q.name,'g_Y2p_amp'},q.gateAmp);
			case {'-Y/2', 'Y2m'}
				QS.saveSSettings({q.name,'g_Y2m_amp'},q.gateAmp);
		end
    end
	varargout{1} = gateAmp;
end