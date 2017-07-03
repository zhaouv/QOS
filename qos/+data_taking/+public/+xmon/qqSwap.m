function qqSwap(varargin)
% twoQSwap: two qubits swap
% bias qubit q1 or q2, drive qubit q1 and q2, readout qubit q1 or q2,
% q1, q2 all has to be the selected qubits in the current session,
% 
% <_o_> = qqQSwap('qubit1',_o&c_,'qubit2',_o&c_,...
%       'biasQubit',<_i_>,'biasAmp',[_f_],'biasDelay',<_i_>,...
%       'q1XYGate',_c_,'q2XYGate',_c_,...
%       'swapTime',[_i_],'readoutQubit',<_i_>,...
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

% Yulin Wu, 2017/7/3

fcn_name = 'data_taking.public.xmon.qqSwap'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'biasQubit',1,'readoutQubit',2,'biasDelay',0,'gui',false,'notes',''});
[q1, q2] =...
    data_taking.public.util.getQubits(args,{'qubit1', 'qubit2'});

if q1==q2
    throw(MException('QOS_TwoQSwap:sameQubitError',...
        'the source qubit and the target qubit are the same.'));
end

if args.readoutQubit==1
    readoutQ = q1;
else
    readoutQ = q2;
end

if args.biasQubit==1
    biasQ = q1;
else
    biasQ = q2;
end

G1 = feval(str2func(['@(q)sqc.op.physical.gate.',args.q1XYGate,'(q)']),q1);
G2 = feval(str2func(['@(q)sqc.op.physical.gate.',args.q2XYGate,'(q)']),q2);

I1 = gate.I(biasQ);
I1.ln = args.biasDelay;

Is = gate.I(q1);
Is.ln = G1.length+10;

Z = op.zBias4Spectrum(biasQ); % todo: use iSwap gate
R = measure.resonatorReadout_ss(readoutQ);
R.state = 2;
zAmp = qes.util.hvar(0);
function procFactory(swapTime)
	Z.ln = swapTime;
    Z.amp = zAmp.val;
    % G1.amp = 5000;
	proc = (G1.*G2)*I1*Z;
    % proc = (G2.*Is)*G1*I1*Z;
    R.delay = proc.length;
    proc.Run();
end

x = expParam(zAmp,'val');
x.name = [biasQ.name,' zpa'];
y = expParam(@procFactory);
y.name = [q1.name,', ',q2.name,' swap time'];
s1 = sweep(x);
s1.vals = args.biasAmp;
s2 = sweep(y);
s2.vals = args.swapTime;
e = experiment();
e.name = 'Q-Q swap';
e.sweeps = [s1,s2];
e.measurements = R;
e.datafileprefix = sprintf('%s,%s', q1.name, q2.name);
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