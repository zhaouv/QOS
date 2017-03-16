function varargout = spin_echo(varargin)
% spin_echo: spin_echo
% 
% <_o_> = spin_echo('qubit',_c&o_,...
%       'time',[_i_],'detuning',_f_,...
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
% arguments order not important as long as the form correct pairs.


% Yulin Wu, 2016/12/27

    fcn_name = 'data_taking.public.xmon.spin_echo'; % this and args will be saved with data
    import qes.*
    import sqc.*
    import sqc.op.physical.*

    args = util.processArgs(varargin,{'gui',false,'notes','','detuning',0,'save',true});
    q = data_taking.public.util.getQubits(args,{'qubit'});
    
    da =  qHandle.FindByClassProp('qes.hwdriver.hardware','name',q.channels.xy_i.instru);
    sampling_rate = da.sampling_rate;

    X = gate.R(q);
    X2 = gate.X2(q);
    I = op.detune(q);
    R = measure.resonatorReadout(q);
    function proc = procFactory(delay)
        I.ln = delay/2;
        X.phase = 2*pi*args.detuning*delay/2/sampling_rate;
        proc = X2*I*X*I*X2;
    end

    y = expParam(@procFactory);
    y.name = [q.name,' time'];
    y.callbacks ={@(x_) x_.expobj.Run()};
    y_s = expParam(R,'delay');
    y_s.offset = 2*X2.length+X.length+5*X2.gate_buffer;
    s1 = sweep({y,y_s});
    s1.vals = {args.time,args.time};
    e = experiment();
    e.sweeps = s1;
    e.measurements = R;
    
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