function varargout = optReadoutFreq(varargin)
% finds the optimal readout resonator probe frequency for qubit
%
% <_f_> = optReadoutFreq('qubit',_c&o_,...
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
    
    % Yulin Wu, 2017/1/14
    
    import qes.*
    import data_taking.public.xmon.s21_01
	import data_taking.public.util.getQubits

    args = util.processArgs(varargin,{'gui',false,'save',true});
	q = copy(data_taking.public.util.getQubits(args,{'qubit'})); % we need to modify the qubit properties, better make a copy to avoid unwanted modifications to the original.
	
    R_AVG_MIN = 1000;
    if q.r_avg < R_AVG_MIN
        q.r_avg = R_AVG_MIN;
    end
    frequency = q.r_freq-3*q.t_rrDipFWHM_est:q.t_rrDipFWHM_est/50:q.r_freq+3*q.t_rrDipFWHM_est;
    e = s21_01('qubit',q,'freq',frequency);
    data = cell2mat(e.data{1});
    a0 = unwrap(angle(data(2:end,1))); % 2:end, to deal with an ad bug
    a1 = unwrap(angle(data(2:end,2)));
    frequency = frequency(2:end);
    [~, idx] = max(abs(a0 - a1));
    optFreq = frequency(idx);
   
    updateSettings = false;
    if args.gui
        hf = figure('NumberTitle','off','Name','optimal resonator readout frequency','HandleVisibility','callback');
        ax = axes('parent',hf);
        plot(ax,frequency,a0/pi,frequency,a1/pi);
        hold(ax,'on');
        plot(ax,[optFreq,optFreq],get(ax,'YLim'),'--','Color',[0.4,0.4,0.4]);
        legend(ax,{'|0>','|1>','r_freq'});
        xlabel(ax,'readout resonator driving frequency(Hz)');
        ylabel(ax,'iq angle shift(\pi)');
    end
    if args.save
        QS = qes.qSettings.GetInstance();
        QS.saveSSettings({q.name,'r_freq'},optFreq);
    end
	varargout{1} = optFreq;
end