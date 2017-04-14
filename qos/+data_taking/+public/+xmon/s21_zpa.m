function varargout = s21_zpa(varargin)
% scan resonator s21 vs frequency and qubit z pulse bias
% 
% <_o_> = s21_zpa('qubit',_c&o_,...
%       'freq',[_f_],'amp',[_f_],...
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

% Yulin Wu, 2017/1/13

    fcn_name = 'data_taking.public.xmon.s21_zdc'; % this and args will be saved with data
    import qes.*
    import sqc.*
    import sqc.op.physical.*
    
    args = util.processArgs(varargin,{'gui',false,'notes','','save',true});
    q = data_taking.public.util.getQubits(args,{'qubit'});

    R = measure.resonatorReadout_ss(q);
    R.state = 1;
    R.swapdata = true;
    R.name = 'iq';
    R.datafcn = @(x)mean(x);
    
    
    Z = op.zBias4Spectrum(q);
    
    x = expParam(Z,'amp');
    x.name = [q.name,' z pulse bias'];
    x.callbacks = {@(x_)x_.expobj.Run()};
    x.deferCallbacks = true;
    y = expParam(R,'mw_src_frequency');
    y.offset = q.r_fc - q.r_freq;
    y.name = [q.name,' readout frequency'];
    y.callbacks = {@(x_)expParam.RunCallbacks(x)};
    s1 = sweep(x);
    s1.vals = args.amp;
    s2 = sweep(y);
    s2.vals = args.freq;
    e = experiment();
    e.name = 's21-zpa';
    e.sweeps = [s1,s2];
    e.measurements = R;
    e.datafileprefix = sprintf('%s', q.name);
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