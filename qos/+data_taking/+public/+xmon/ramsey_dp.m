function varargout = ramsey_dp(varargin)
% ramsey: ramsey oscillation,..
% detune by changing the second pi/2 pulse tracking frame
% 
% <_o_> = ramsey_dp('qubit',_c&o_,...
%       'time',[_i_],'detuning',<[_f_]>,'phaseOffset',<_f_>,...
%       'dataTyp',<'_c_'>,...   % S21 or P
%       'notes',<_c_>,'gui',<_b_>,'save',<_b_>)
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

% Yulin Wu, 2016/12/27

    fcn_name = 'data_taking.public.xmon.ramsey_dp'; % this and args will be saved with data
    import qes.*
    import sqc.*
    import sqc.op.physical.*

    args = util.processArgs(varargin,{'phaseOffset',0,'dataTyp','P','gui',false,'notes','','detuning',0,'save',true});
    q = data_taking.public.util.getQubits(args,{'qubit'});

    X2 = op.XY2p(q,0);
    I = gate.I(q);
    R = measure.resonatorReadout_ss(q);
 
    switch args.dataTyp
        case 'P'
            R.state = 2;
        case 'S21'
            R.swapdata = true;
            R.name = 'iq';
            R.datafcn = @(x)mean(abs(x));
        otherwise
            throw(MException('QOS_ramsey_dp:unrcognizedDataTyp',...
			'unrecognized dataTyp %s, available dataTyp options are P and S21.', args.dataTyp));
    end
	
	detuning = qes.util.hvar(0);
	da = qHandle.FindByClassProp('qes.hwdriver.hardware','name',...
		q.channels.xy_i.instru);
	daSamplingRate = da.samplingRate;
	X2_ = copy(X2);
    function procFactory(delay)
        I.ln = delay;
		X2.phase = -2*pi*detuning.val*delay/daSamplingRate+args.phaseOffset;
        proc = X2_*I*X2;
        proc.Run();
        R.delay = proc.length;
    end

    x = expParam(detuning,'val');
	x.name = [q.name,' detuning(Hz)'];
    y = expParam(@procFactory);
    y.name = [q.name,' time'];
	s1 = sweep(x);
    s1.vals = args.detuning;
    s2 = sweep(y);
    s2.vals = args.time;
    e = experiment();
    e.name = 'Ramsey(Detune by Phase)';
    e.sweeps = [s1,s2];
    e.measurements = R;
    e.datafileprefix = sprintf('%s_Ramsey', q.name);
    if ~args.gui
        e.showctrlpanel = false;
        e.plotdata = false;
    end
    if ~args.save
        e.savedata = false;
    end
    
    e.notes = args.notes;
    e.addSettings({'fcn','args'},{fcn_name,args});
    e.Run();
    varargout{1} = e;
end