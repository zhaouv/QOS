function TwoQSwap(varargin)
% TwoQSwap: two qubit swap
% bias qubit q1 or q2, drive qubit q1 or q2 and readout qubit q1 and q2,
% q1, q2 all has to be the selected qubits in the current session,
% 
% <_o_> = TwoQSwap('qubit1',_o&c_,'qubit2',_o&c_,...
%       'biasQubit',_o&c_,'biasAmp',[_f_],'biasDelay',<_i_>,...
%       'driveQubit',_o&c_,...
%       'swapTime',[_i_],...
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

args = util.processArgs(varargin,{'biasDelay',0,'gui',false,'notes',''});
[q1, q2] =...
    data_taking.public.util.getQubits(args,{'qubit1', 'qubit2'});
qs = {q1, q2};

if q1==q2
    throw(MException('QOS_TwoQSwap:sameQubitError',...
        'the source qubit and the target qubit are the same.'));
end
if q1 ~= args.biasQubit && q2 ~= args.biasQubit
	throw(MException('QOS_TwoQSwap:invalidBiasQubit',...
        'biasQubit can only be qubit1 or qubit2.'));
elseif q1 == args.biasQubit
	args.biasQubit = q1;
else
	args.biasQubit = q2;
end

if q1 ~= args.driveQubit && q2 ~= args.driveQubit
	throw(MException('QOS_TwoQSwap:invaliDriveQubit',...
        'driveQubit can only be qubit1 or qubit2.'));
elseif q1 == args.driveQubit
	args.driveQubit = q1;
else
	args.driveQubit = q2;
end

X = gate.X(qs{args.driveQubit});
I = gate.I(biasQubit);
I.ln = args.biasDelay;
Z = op.zBias4Spectrum(qs{args.biasQubit}); % todo: use iSwap gate
function procFactory(delay)
	Z.ln = delay;
	proc = Z*I*X;
    proc.Run();
end

error('todo...');

end