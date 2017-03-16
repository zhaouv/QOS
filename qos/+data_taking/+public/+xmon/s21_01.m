function varargout = s21_01(varargin)
% resonator s21 of state |0> and state |1> 
% 
% <_o_> = s21_01('qubit',_c&o_,...
%       'freq',[_f_],...
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

% Yulin Wu, 2017/1/13

    fcn_name = 'data_taking.public.xmon.s21_01'; % this and args will be saved with data
    import qes.*
    import sqc.*
    import sqc.op.physical.*
    
    args = util.processArgs(varargin,{'gui',false,'notes','','save',true});
    q = data_taking.public.util.getQubits(args,{'qubit'});
    
    X = gate.X(q);
    R = measure.resonatorReadout(q);
    R.delay = X.length;
    R.swapdata = true;
    R.name = 'iq';
    R.datafcn = @(x)mean(cell2mat(x));
    
    % with pi pulse
    x = expParam(R,'mw_src_frequency');
    x.offset = q.r_fc - q.r_freq;
    x.name = [q.name,' readout frequency'];
    x.auxpara = X;
    x.callbacks ={@(x_) x_.auxpara.Run()};
    s1 = sweep(x);
    s1.vals = args.freq;
    e1 = experiment();
    e1.sweeps = s1;
    e1.measurements = R;
    if ~args.gui
        e1.showctrlpanel = false;
        e1.plotdata = false;
    end
    e1.savedata = false;
    e1.Run();
    iq_1 = e1.data{1};
    
    % without pi pulse
    X = gate.X(q);
    R = measure.resonatorReadout(q);
    R.delay = X.length;
    R.swapdata = true;
    R.name = 'iq';
    R.datafcn = @(x)mean(cell2mat(x));

    x = expParam(R,'mw_src_frequency');
    x.offset = q.r_fc - q.r_freq;
    x.name = [q.name,' readout frequency'];
    s1 = sweep(x);
    s1.vals = args.freq;
    
    e0 = experiment();
    e0.sweeps = s1;
    e0.measurements = R;
    if ~args.gui
        e0.showctrlpanel = false;
        e0.plotdata = false;
    end
    e0.savedata = false;
    e0.Run();
    
    e0.data{1} = [e0.data{1},iq_1];
    e0.notes = args.notes;
    e0.addSettings({'fcn','args'},{fcn_name,args});
    if args.save
        e0.SaveData();
    end
    varargout{1} = e0;
end