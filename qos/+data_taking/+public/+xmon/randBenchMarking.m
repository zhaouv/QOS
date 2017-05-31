function varargout = randBenchMarking(varargin)
% randBenchMarking
% process options are: 'X','Z','Y','X/2','-X/2','Y/2','-Y/2'
%
% <_o_> = randBenchMarking('qubit',_c&o_,...
%       'process',<_c_>,'numGates',[_i_],'numReps',_i_,...
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

% Yulin Wu, 2017

    import qes.*
    import sqc.*
    import sqc.op.physical.*

    args = util.processArgs(varargin,{'state','|0>','reps',1,'gui',false,'notes','','detuning',0,'save',true});
    q = data_taking.public.util.getQubits(args,{'qubit'});

    switch args.process
        case 'I'
            p = gate.I(q);
        case 'X'
            p = gate.X(q);
        case 'Y'
            p = gate.Y(q);
        case {'X/2','X2p'}
            p = gate.X2p(q);
        case {'Y/2','Y2p'}
            p = gate.Y2p(q);
		case {'-X/2','X2m'}
            p = gate.X2m(q);
        case {'-Y/2','Y2m'}
            p = gate.Y2m(q);
		case {'Z'}
            X = gate.X(q);
			Y = gate.Y(q);
			p = Y*X;
        otherwise
            throw(MException('randBenchMarking:unsupportedGate',...
                sprintf('available process options for singleQProcessTomo is %s, %s given.',...
                '''X'',''Z'',''Y'',''X/2'',''-X/2'',''Y/2'',''-Y/2''',args.process)));
    end
	
    N = numel(args.numGates);
    data_ref =  zeros(1,N);
    data_i = zeros(1,N);
    ax = NaN;
    
    str = ['D:\data\20170517\RndBenchMarking_',datestr(now,'yymmddTHHMMSS_')];
    
    for ii = 1:N
        for jj = 1:args.numReps
            R = measure.randBenchMarking(q,p,args.numGates(ii));
            data = R();
            data_ref(ii) = data_ref(ii)+ data(1);
            data_i(ii) = data_i(ii)+ data(2);
        end
        data_ref(ii) = data_ref(ii)/args.numReps;
        data_i(ii) = data_i(ii)/args.numReps;
        if args.gui
            if ~ishghandle(ax)
                h = qes.ui.qosFigure(sprintf('Randomized Benchmarking | %s', args.process),true);
                ax = axes('parent',h);
            end
            plot(ax,...
                args.numGates,data_ref,...
                args.numGates,data_i);
            xlabel(ax,'number of gates');
            ylabel(ax,'P|0>');
            legend(ax,{'ref','interleaved'});
            drawnow;
        end
        if args.save
            save([str,'.mat'],'data_ref','data_i','args');
            try
                savefig(h,[str,'.fig']);
            catch
            end
        end
    end

    varargout{1} = data_ref;
    varargout{2} = data_i;
end