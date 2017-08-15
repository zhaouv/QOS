function varargout = Tomo_2QState(varargin)
% demonstration of state tomography on single qubit.
% state tomography is a measurement, it is not used alone in real
% applications, this simple function is just a demonstration/test to show
% that state tomography is working properly.
% prepares a a state(options are: '|00>')
% and do state tomography.
%
% <_o_> = Tomo_2QState('qubit1',_c&o_,'qubit2',_c&o_,...
%       'state',<_c_>,'reps',<_i_>,...
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

    args = util.processArgs(varargin,{'state','|00>','reps',1,'gui',false,'notes','','detuning',0,'save',true});
    [q1,q2] = data_taking.public.util.getQubits(args,{'qubit1','qubit2'});

    R = measure.stateTomography({q1,q2});
    
    switch args.state
        case '|00>'
            p = gate.I(q1).*gate.I(q2);
        case '|01>'
            p = gate.X(q1).*gate.I(q2);
        case '|10>'
            p = gate.X(q2).*gate.I(q1);
        case '|11>'
            p = gate.X(q1).*gate.X(q2);
        case {'++'}
            p = gate.Y2p(q1).*gate.Y2p(q2); 
        case {'--'}
            p = gate.Y2m(q1).*gate.Y2m(q2);
        case {'ii'}
            p = gate.X2m(q1).*gate.X2m(q2);
        case {'GHZ'}
            p = (gate.H(q1).*gate.Y2m(q2))*gate.CZ(q1,q2)*(gate.H(q1).*gate.Y2p(q2));
%         case '|01>+|1>'
%             p = gate.Y2p(q);
%         case '|0>-|1>'
%             p = gate.Y2m(q);
%         case '|0>-i|1>'
%             p = gate.X2p(q);
%         case '|0>+i|1>'
%             p = gate.X2m(q);
        otherwise
            throw(MException('QOS_singleQStateTomo',...
                sprintf('available state options for singleQStateTomo is %s, %s given.',...
                '|0> |1> |0>+|1> |0>-|1> |0>+i|1> |0>-i|1>',args.state)));
    end
    R.setProcess(p);
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
        dataFileName = ['STomo2',datestr(now,'_yymmddTHHMMSS_'),'.mat'];
        sessionSettings = QS.loadSSettings;
        hwSettings = QS.loadHwSettings;
        save(fullfile(dataPath,dataFileName),'P','args','sessionSettings','hwSettings');
    end
    varargout{1} = P;
end