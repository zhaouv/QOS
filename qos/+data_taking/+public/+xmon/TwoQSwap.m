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

error('todo...');

Z.delay = X.length;
R = measure.resonatorReadout({q1, q2});

x = expParam(Z,'amp');
x.name = [biasQubit.name,' z bias amplitude'];
y = expParam(Z,'ln');
y.name = [driveQubit.name,' decay time(da sampling interval)'];
y.callbacks ={ @(x_) x_.expobj.Run()};
y_s = expParam(R,'delay');
y_s.offset = X.length;
s1 = sweep(x);
s1.vals = args.biasAmp;
s2 = sweep({y,y_s});
s2.vals = {args.time,args.time};
e = experiment();
e.name = 'Two Qubit Swap';
e.sweeps = [s1,s2];
e.measurements = R;
e.datafileprefix = sprintf('%s%s',q1.name,q2.name);
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
end