function TwoQSwap(varargin)
% TwoQSwap: two qubit swap
% bias qubit q1, drive qubit q2 and readout qubit q1 and q2,
% q1, q2 all has to be the selected qubits in the current session,
% 
% <_o_> = TwoQSwap('qubit1',_o&c_,'qubit2',_o&c_,...
%       'biasQubit',_i_,'biasAmp',[_f_],...
%       'driveQubit',_i_,...
%       'time',[_i_],...
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

% Yulin Wu, 2017/3/15

fcn_name = 'data_taking.public.xmon.TwoQSwap'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'gui',false,'notes',''});
[q1, q2] =...
    data_taking.public.util.getQubits(args,{'qubit1', 'qubit2'});
qs = {q1, q2};

if q1==q2
    throw(MException('QOS_TwoQSwap:sameQubitErr',...
        'the source qubit and the target qubit are the same.'));
end

X = gate.X(qs{args.driveQubit});
Z = op.zBias4Spectrum(qs{args.biasQubit}); % todo: use iSwap gate
function procFactory(delay)
	Z.ln = delay;
	proc = Z*I*X;
    proc.Run();
end

error('todo...');

end