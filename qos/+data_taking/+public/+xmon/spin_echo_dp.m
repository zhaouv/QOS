function varargout = spin_echo_dp(varargin)
% spin echo:
% detune by changing the second pi/2 pulse tracking frame
% 
% <_o_> = spin_echo_dp('qubit',_c&o_,...
%       'time',[_i_],'detuning',<_f_>,...
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

    fcn_name = 'data_taking.public.xmon.spin_echo_dp'; % this and args will be saved with data
    import qes.*
    import sqc.*
    import sqc.op.physical.*

    args = util.processArgs(varargin,{'gui',false,'notes','','detuning',0,'save',true});
    if any(mod(args.time,2)~=0)
        throw(MException('QOS_spinEcho:invalidInput','time not even integers.'));
    end
    q = data_taking.public.util.getQubits(args,{'qubit'});
    
    da =  qHandle.FindByClassProp('qes.hwdriver.hardware','name',q.channels.xy_i.instru);
    daSamplingRate = da.samplingRate;

    X = gate.X(q);
    X2 = op.XY2p(q,0);
    I = gate.I(q);
    R = measure.resonatorReadout_ss(q);
	detuning = util.hvar(0);
	X2_ = copy(X2);
    function proc = procFactory(delay)
        I.ln = delay/2;
		X2.phase = -2*pi*detuning.val*delay/daSamplingRate;
        proc = X2*I*X*I*X2_;
    end

	x = expParam(detuning,'val');
	x.name = [q.name,' detuning(Hz)'];
	
    y = expParam(@procFactory);
    y.name = [q.name,' time'];
    y.callbacks ={@(x_) x_.expobj.Run()};
    y_s = expParam(R,'delay');
    y_s.offset = 2*X2.length+X.length+5*X2.gate_buffer;
	s1 = sweep(x);
    s1.vals = args.detuning;
    s2 = sweep({y,y_s});
    s2.vals = {args.time,args.time};
    e = experiment();
    e.name = 'Spin Echo(Detune by Phase)';
    e.sweeps = [s1,s2];
    e.measurements = R;
    e.datafileprefix = sprintf('%s',q.name);
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