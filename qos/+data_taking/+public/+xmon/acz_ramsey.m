function varargout = acz_ramsey(varargin)
% ramsey: ramsey oscillation,..
% detune by changing the second pi/2 pulse tracking frame
% 
% <_o_> = acz_ramsey('controlQ',_c&o_,'targetQ',_c&o_,...
%       'czLength',[_i_],'czAmp',[_f_],'czDelay',<_i_>,'cState','0'...
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

% Yulin Wu, 2017/7/2

    fcn_name = 'data_taking.public.xmon.acz_ramsey'; % this and args will be saved with data
    import qes.*
    import sqc.*
    import sqc.op.physical.*

    args = util.processArgs(varargin,{'cState','0','czDelay',0,'gui',false,'notes','','save',true});
    [qc,qt] = data_taking.public.util.getQubits(args,{'controlQ','targetQ'});

    X = gate.X(qc);
    if args.cState == '0'
        X.amp = 0;
    end

            
    X2 = gate.X2p(qt);
    I = gate.I(qt);
    I.ln = args.czDelay;
    CZ = gate.CZ(qc,qt);
    R = measure.resonatorReadout_ss(qt);
    R.state = 2;
    
	X2_ = copy(X2);
    czLength = qes.util.hvar(0);
    function procFactory(amp)
        CZ.ln = czLength.val;
        CZ.amp = amp;
        proc = (X.*X2_)*I*CZ*I*X2;
        proc.Run();
        R.delay = proc.length;
    end

    x = expParam(czLength,'val');
	x.name = ['CZ[',qc.name,',', qt.name,'] length'];
    
    y = expParam(@procFactory);
    y.name = ['CZ[',qc.name,',', qt.name,'] amplitude'];
    s1 = sweep(x);
    s1.vals = args.czLength;
    s2 = sweep(y);
    s2.vals = args.czAmp;
    e = experiment();
    e.name = 'ACZ amplitude';
    e.sweeps = [s2];
    e.measurements = R;
    e.datafileprefix = sprintf('CZ%s%s', qc.name,qt.name);
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