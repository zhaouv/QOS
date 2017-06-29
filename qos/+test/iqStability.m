function varargout = iqStability(varargin)
% scan resonator s21 vs frequency and raadout amplitude(iq), no qubit drive
% 
% <_o_> = iqStability('qubit',_c&o_,)
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

    fcn_name = 'data_taking.public.xmon.s21_rAmp'; % this and args will be saved with data

    import qes.*
    import sqc.*
    import sqc.op.physical.*
    
    args = util.processArgs(varargin,{'amp',[],'r_avg',[],'gui',false,'notes','','save',true});
    q = data_taking.public.util.getQubits(args,{'qubit'});
    
    data_taking.public.util.setZDC(q); %add by GM, 20170415
    
    if ~isempty(args.r_avg) %add by GM, 20170414
        q.r_avg=args.r_avg;
    end
    if isempty(args.amp)
        args.amp = q.r_amp;
    end
    
    R = measure.resonatorReadout_ss(q);
    R.swapdata = true;
    R.name = 'IQ';
    
    IQRAW = [];
    figure();
    axes();
    for ii = 1:1000
        R.Run();
        IQRAW = [IQRAW,mean(R.data)];
        plot(IQRAW,'.');
        drawnow;
    end
end