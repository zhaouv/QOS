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
    % resolution low, not recommended, use correctf01bySpc instead
    
    MAXFREQDRIFT = 20e6;
    DELAYTIMERANGE = 500e-9;
    
    import data_taking.public.xmon.ramsey
    
    args = qes.util.processArgs(varargin,{'gui',false,'save',true});
	q = data_taking.public.util.getQubits(args,{'qubit'});
    da = qes.qHandle.FindByClassProp('qes.hwdriver.hardware','name',...
		q.channels.xy_i.instru);
    daSamplingRate = da.samplingRate;
    
    t = unique(round((0:4e-9:DELAYTIMERANGE)*daSamplingRate));
    e = ramsey('qubit',q,'mode','dp',... 
      'time',t,'detuning',MAXFREQDRIFT,'gui',false,'save',false);
    Pp = e.data{1};
    maP = max(Pp);
    miP = min(Pp);
    if maP < 0.85 || maP > 1.15 || miP < -0.15 || miP > 0.15
        throw(MException('QOS_correctf01byRamsey:probabilityNotProperlyCallibrated',...
				'probability not properly callibrated to SNR too low.'));
    end
    e = ramsey('qubit',q,'mode','dp',... 
      'time',t,'detuning',-MAXFREQDRIFT,'gui',false,'save',false);
    Pn = e.data{1};
    t = t/daSamplingRate;
    
    % P = B*(exp(-t/td)*(sin(2*pi*freq*t+D)+C));
    tf = linspace(t(1),t(end),200);
    
    [B,C,D,freqp,tdp,cip] =...
        toolbox.data_tool.fitting.sinDecayFit_s(...
        t,Pp,0.5,1,pi/2,MAXFREQDRIFT,5e-6);
    Ppf = B*(exp(-tf/tdp).*(sin(2*pi*freqp*tf+D)+C));
    
    
    dcip = diff(cip,1,2);
    if  B < 0.3 || B > 0.7 || C < 0.5 || C > 2 ...
        || freqp < 2e6 || freqp > 2*MAXFREQDRIFT || abs(tdp) < 200e-9 || any(abs(dcip([1,2,4])./[B;C;freqp]) > 0.20)
    
        if args.gui
            h = qes.ui.qosFigure(sprintf('Correct f01 by ramsey | %s', q.name),true);
            ax = axes('parent',h);
            plot(ax,t,Pp,'.',tf,Ppf);
            legend(ax,{num2str(MAXFREQDRIFT/1e6,'%0.2fMHz'),'fit'});
            xlabel(ax,'time(us)');
            ylabel(ax,'P|1>');
            title('fitting failed.');
        end    
    
        throw(MException('QOS_correctf01byRamsey:fittingFailed',...
				'fitting failed.'));
    end

    [B,C,D,freqn,tdn,cin] =...
        toolbox.data_tool.fitting.sinDecayFit_s(...
        t,Pn,0.5,1,pi/2,MAXFREQDRIFT,5e-6);
    
    Pnf = B*(exp(-tf/tdn).*(sin(2*pi*freqn*tf+D)+C));
    
    dcip = diff(cin,1,2);
    if B < 0.3 || B > 0.7 || C < 0.5 || C > 2 ...
        || freqn < 2e6 || freqn > 2*MAXFREQDRIFT || abs(tdn) < 200e-9 || any(abs(dcip([1,2,4])./[B;C;freqn]) > 0.20)
    
        if args.gui
            h = qes.ui.qosFigure(sprintf('Correct f01 by ramsey | %s', q.name),true);
            ax = axes('parent',h);
            plot(ax,tf/1e-6,Ppf,'-b',tf/1e-6,Pnf,'-r');
            hold on;
            plot(ax,t/1e-6,Pp,'.',t/1e-6,Pn,'.');
            legend(ax,{'','',num2str(MAXFREQDRIFT/1e6,'%0.2fMHz'),num2str(-MAXFREQDRIFT/1e6,'%0.2fMHz')});
            xlabel(ax,'time(us)');
            ylabel(ax,'P|1>');
            title('fitting failed.');
            drawnow;
        end 
    
        throw(MException('QOS_correctf01byRamsey:fittingFailed',...
				'fitting failed.'));
    end
    
    if ((freqn + freqp)/2-MAXFREQDRIFT)/MAXFREQDRIFT > 0.05
        throw(MException('QOS_correctf01byRamsey:fittingFailed',...
				'fitting failed or frequency drift out of measureable range.'));
    end
    
    f01 = q.f01+(freqn - freqp)/2;
    
    if args.gui
        h = qes.ui.qosFigure(sprintf('Correct f01 by ramsey | %s', q.name),true);
		ax = axes('parent',h);
        plot(ax,tf/1e-6,Ppf,'-b',tf/1e-6,Pnf,'-r');
        hold on;
		plot(ax,t/1e-6,Pp,'.',t/1e-6,Pn,'.');
		legend(ax,{'','',num2str(MAXFREQDRIFT/1e6,'%0.2fMHz'),num2str(-MAXFREQDRIFT/1e6,'%0.2fMHz')});
		xlabel(ax,'time(us)');
		ylabel(ax,'P|1>');
        title(sprintf('Original f01: %0.5fGHz, current f01: %0.5fGHz',q.f01/1e9,f01/1e9));
        drawnow;
    end
    
    if ischar(args.save)
        args.save = false;
        choice  = questdlg('Update settings?','Save options',...
                'Yes','No','No');
        if ~isempty(choice) && strcmp(choice, 'Yes')
            args.save = true;
        end
    end
	if args.save
        QS = qes.qSettings.GetInstance();
        QS.saveSSettings({q.name,'f01'},f01);
    end
	varargout{2} = f01;
end
