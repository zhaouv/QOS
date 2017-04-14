function varargout = T1_1_s21(varargin)
% T1_1_s21: T1
% bias qubit q1, drive qubit q2 and readout qubit q3,
% q1, q2, q3 can be the same qubit or diferent qubits,
% q1, q2, q3 all has to be the selected qubits in the current session,
% 
% <_o_> = T1_111('qubit',_c&o_,'biasAmp',<[_f_]>,...
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

% Yulin Wu, 2016/12/27

fcn_name = 'data_taking.public.xmon.T1_1_s21'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'biasAmp',0,'gui',false,'notes',''});
q = data_taking.public.util.getQubits(args,{'qubit'});

X = gate.X(q);
Z = op.zBias4Spectrum(q);
Z.delay = X.length;



% R = measure.rReadout4T1(q,X.mw_src{1});
% R.swapdata = true;
% R.name = '|S21|';


R = measure.resonatorReadout_ss(q);
R.swapdata = true;
R.name = 'iq';
R.datafcn = @(x)mean(abs(x));


x = expParam(Z,'amp');
x.name = [q.name,' z bias amplitude'];
y = expParam(Z,'ln');
y.name = [q.name,' decay time(da sampling interval)'];
y.auxpara = X;
y.callbacks ={ @(x_) x_.expobj.Run(); @(x_) x_.auxpara.Run()};
y_s = expParam(R,'delay');
y_s.offset = X.length;
s1 = sweep(x);
s1.vals = args.biasAmp;
s2 = sweep({y,y_s});
s2.vals = {args.time,args.time};
e = experiment();
e.sweeps = [s1,s2];
e.measurements = R;
% e.plotfcn = @qes.util.plotfcn.T1;
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