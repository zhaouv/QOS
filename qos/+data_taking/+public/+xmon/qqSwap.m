function qqSwap(varargin)
% twoQSwap: two qubits swap
% bias qubit q1 or q2, drive qubit q1 and q2, readout qubit q1 and q2,
% q1, q2 all has to be the selected qubits in the current session,
% 
% <_o_> = twoQSwap('qubit1',_o&c_,'qubit2',_o&c_,...
%       'biasQubit',[_f_],'biasDelay1',<_i_>,...
%		'biasAmp2',[_f_],'biasDelay1',<_i_>,...
%       'q1XYGate',_c_,'q2XYGate',_c_,...
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

fcn_name = 'data_taking.public.xmon.qqSwap'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'biasDelay1',0,'biasDelay1',0,'gui',false,'notes',''});
[q1, q2] =...
    data_taking.public.util.getQubits(args,{'qubit1', 'qubit2'});

if q1==q2
    throw(MException('QOS_TwoQSwap:sameQubitError',...
        'the source qubit and the target qubit are the same.'));
end

if q1 ~= args.driveQubit && q2 ~= args.driveQubit
	throw(MException('QOS_TwoQSwap:invaliDriveQubit',...
        'driveQubit can only be qubit1 or qubit2.'));
elseif q1 == args.driveQubit
	driveQubit = q1;
else
	driveQubit = q2;
end

X = gate.X(driveQubit);
I1 = gate.I(q1);
I1.ln = args.biasDelay1;
Z1 = op.zBias4Spectrum(q1); % todo: use iSwap gate
I2 = gate.I(q2);
I2.ln = args.biasDelay2;
Z2 = op.zBias4Spectrum(q2); % todo: use iSwap gate
function procFactory(delay)
	Z1.ln = delay;
	Z2.ln = delay;
	proc = X*(I1*Z1).*(I2*Z2);
    proc.Run();
end

error('todo...');

end