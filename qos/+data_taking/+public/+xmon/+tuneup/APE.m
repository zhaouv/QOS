function varargout = APE(varargin)
% measure amplified phase error with ramsey measurement
% 
% <_o_> = APE('qubit',_c&o_,...
%       'phase',<[_f_]>,'numI',<_i_>,...
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

% Yulin Wu, 2017/4/1

    fcn_name = 'data_taking.public.xmon.APE'; % this and args will be saved with data
    import qes.*
    import sqc.*
    import sqc.op.physical.*

    args = util.processArgs(varargin,{'phase',[-pi/2:pi/40:pi/2],...
		'numI',5,'gui',false,'notes','','phase',0,'save',true});
    q = data_taking.public.util.getQubits(args,{'qubit'});

    X2p = gate.X2p(q);
	X2m = gate.X2m(q);
	XY2 = op.XY2p(q,0);
	I = (X2m*X2p)^args.numI;
    function proc = procFactory(phase)
		XY2.phase = phase;
        proc = X2p*I*XY2;
    end
	R = measure.resonatorReadout_ss(q);
    R.state = 2;
	R.delay = 2*X2p.length+I.length+3*X2p.gate_buffer;

    x = expParam(@procFactory);
    x.name = [q.name,' phase(rad)'];
    x.callbacks ={@(x_) x_.expobj.Run()};
    s1 = sweep(x);
    s1.vals = args.phase;
    e = experiment();
	e.name = 'Amplified Phase Error';
    e.sweeps = s1;
    e.measurements = R;
    
    if ~args.gui
        e.showctrlpanel = false;
        e.plotdata = false;
    end
    
    if ischar(args.save)
        args.save = false;
        choice  = questdlg('Update settings?','Save options',...
                'Yes','No','No');
        if ~isempty(choice) && strcmp(choice, 'Yes')
            args.save = true;
        end
    end
    if ~args.save
        e.savedata = false;
    end
    e.notes = args.notes;
    e.addSettings({'fcn','args'},{fcn_name,args});
    e.Run();
    varargout{1} = e;
end