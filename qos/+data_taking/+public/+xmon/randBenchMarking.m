function varargout = randBenchMarking(varargin)
% randBenchMarking
% process options are: 'X','Z','Y','X/2','-X/2','Y/2','-Y/2', 'CZ'
%
% <_o_> = randBenchMarking('qubit1',_c&o_,'qubit2',<_c&o_>,...
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
    if isempty(args.qubit2)
        q = data_taking.public.util.getQubits(args,{'qubit1'});
    else
        [q1,q2] = data_taking.public.util.getQubits(args,{'qubit1','qubit2'});
        q = {q1,q2};
    end

    if numel(q) == 1
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
                    sprintf('available process options is %s, %s given.',...
                    '''X'',''Z'',''Y'',''X/2'',''-X/2'',''Y/2'',''-Y/2'' for single qubit.',args.process)));
        end
    else
        switch args.process
            case {'CZ'}
                p = gate.CZ(q{1},q{2});
            otherwise
                throw(MException('randBenchMarking:unsupportedGate',...
                    sprintf('available process options is %s, %s given.',...
                    '''CZ'' for two qubits',args.process)));
        end
    end
	
    N = numel(args.numGates);
    Pref =  zeros(1,N);
    Pgate = zeros(1,N);
    ax = NaN;

    Pref = NaN(args.numReps,N); 
    Pgate = NaN(args.numReps,N);
    for ii = 1:N
        R = measure.randBenchMarking(q,p,args.numGates(ii),args.numReps);
        data = R();
        Pref(:,ii) = data(:,1);
        Pgate(:,ii) = data(:,2);
        if args.gui
            if ~ishghandle(ax)
                h = qes.ui.qosFigure(sprintf('Randomized Benchmarking | %s', args.process),true);
                ax = axes('parent',h);
            end
            try
                plot(ax,...
                args.numGates(1:ii),mean(Pref(:,1:ii),1),...
                args.numGates(1:ii),mean(Pgate(:,1:ii),1));
            catch
            end
            xlabel(ax,'number of gates');
            if numel(q) == 1
                ylabel(ax,'P|0>');
            else
                ylabel(ax,'P|00>');
            end
            legend(ax,{'reference','interleaved'});
            drawnow;
        end
        if args.save
            QS = qes.qSettings.GetInstance();
            dataPath = QS.loadSSettings('data_path');
            dataFileName = ['RB',datestr(now,'_yymmddTHHMMSS_'),'.mat'];
            sessionSettings = QS.loadSSettings;
            hwSettings = QS.loadHwSettings;
            save(fullfile(dataPath,dataFileName),'Pref','Pgate','args','sessionSettings','hwSettings');
        end
    end

    varargout{1} = Pref;
    varargout{2} = Pgate;
end