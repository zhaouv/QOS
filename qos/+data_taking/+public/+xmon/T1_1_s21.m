function varargout = T1_1_s21(varargin)
% T1_1_s21: T1
% bias qubit q1, drive qubit q2 and readout qubit q3,
% q1, q2, q3 can be the same qubit or diferent qubits,
% q1, q2, q3 all has to be the selected qubits in the current session,
% 
% <_o_> = T1_111('qubit',_c&o_,'biasAmp',<[_f_]>,...
%       'time',[_i_],'r_avg',<_i_>,...
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

% Yulin Wu, 2016/12/27

fcn_name = 'data_taking.public.xmon.T1_1_s21'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'r_avg',[],'biasAmp',0,'gui',false,'notes',''});
q = data_taking.public.util.getQubits(args,{'qubit'});

driveQubit=q;
biasQubit=q;

if ~isempty(args.r_avg) %add by GM, 20170416
    q.r_avg=args.r_avg;
end

X = gate.X(driveQubit);
I = gate.I(biasQubit);
I.ln = args.biasDelay;
Z = op.zBias4Spectrum(biasQubit);
function proc = procFactory(delay)
	Z.ln = delay;
	proc = Z*I*X;
end
R = measure.resonatorReadout_ss(q);
R.swapdata = true;
R.name = 'iq';
R.datafcn = @(x)mean(abs(x));

x = expParam(Z,'amp');
x.name = [q.name,' z bias amplitude'];
y = expParam(Z,'ln');
y.name = [q.name,' decay time(da sampling interval)'];
y.callbacks ={ @(x_) x_.expobj.Run(); @(x_) X.Run()};
y_s = expParam(R,'delay');
y_s.offset = X.length;
s1 = sweep(x);
s1.vals = args.biasAmp;
s2 = sweep({y,y_s});
s2.vals = {args.time,args.time};
e = experiment();
e.name = 'T1';
e.sweeps = [s1,s2];
e.measurements = R;
% e.plotfcn = @qes.util.plotfcn.T1;
% e.plotfcn = @qes.util.plotfcn.OneMeasComplex_1D_Amp;
e.datafileprefix = sprintf('%s',q.name);
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