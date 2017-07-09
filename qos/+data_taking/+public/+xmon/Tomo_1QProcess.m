function varargout = Tomo_1QProcess(varargin)
% demonstration of process tomography on single qubit.
% process tomography is a measurement, it is not used alone in real
% applications, this simple function is just a demonstration/test to show
% that process tomography is working properly.
% process options are: 'X','Z','Y','X/2','-X/2','Y/2','-Y/2'
%
% <_o_> = singleQStateTomo('qubit',_c&o_,...
%       'process',<_c_>,'reps',<_i_>,...
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

    args = util.processArgs(varargin,{'reps',1,'gui',false,'notes','','detuning',0,'save',true});
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
            throw(MException('QOS_singleQProcessTomo:unsupportedGate',...
                sprintf('available process options for singleQProcessTomo is %s, %s given.',...
                '''X'',''Z'',''Y'',''X/2'',''-X/2'',''Y/2'',''-Y/2''',args.process)));
    end
	
    R = measure.processTomography(q,p);

    for ii = 1:args.reps
        if ii == 1
            P = R();
        else
            P = P+R();
        end
    end
    P = P/args.reps;
    
	
    if ~args.gui
        
    end
    if args.save
        QS = qes.qSettings.GetInstance();
        dataPath = QS.loadSSettings('data_path');
        dataFileName = ['PTomo1',datestr(now,'_yymmddTHHMMSS_'),'.mat'];
        sessionSettings = QS.loadSSettings;
        hwSettings = QS.loadHwSettings;
        save(fullfile(dataPath,dataFileName),'P','args','sessionSettings','hwSettings');
    end
    varargout{1} = P;
end