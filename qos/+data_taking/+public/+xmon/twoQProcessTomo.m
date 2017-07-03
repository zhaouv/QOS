function varargout = twoQProcessTomo(varargin)
% demonstration of process tomography on single qubit.
% process tomography is a measurement, it is not used alone in real
% applications, this simple function is just a demonstration/test to show
% that process tomography is working properly.
% process options are: 'CZ','CNOT'
%
% <_o_> = twoQStateTomo('qubit1',_c&o_,'qubit1',_c&o_,...
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
    [q1,q2] = data_taking.public.util.getQubits(args,{'qubit1','qubit2'});

    switch args.process
        case 'CZ'
            p = gate.CZ(q1,q2); % q1, control qubit, q2, target qubit
        case 'CNOT'
            CZ = gate.CZ(q1,q2); % q1, control qubit, q2, target qubit
            Y2m = gate.Y2m(q2);
            Y2p = gate.Y2p(q2);
			p = Y2m*CZ*Y2p;
        otherwise
            throw(MException('QOS_singleQProcessTomo:unsupportedGate',...
                sprintf('available process options for singleQProcessTomo is %s, %s given.',...
                '''CZ'',''CNOT''',args.process)));
    end
	
    R = measure.processTomography({q1,q2},p);

    for ii = 1:args.reps
        if ii == 1
            data = R();
        else
            data = data+R();
        end
    end
    data = data/args.reps;
    
	
    if ~args.gui
        
    end
    if ~args.save
        
    end
    varargout{1} = data;
end