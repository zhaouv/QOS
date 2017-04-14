function varargout = T1_111(varargin)
% T1_111: T1
% bias qubit q1, drive qubit q2 and readout qubit q3,
% q1, q2, q3 can be the same qubit or diferent qubits,
% q1, q2, q3 all has to be the selected qubits in the current session,
% 
% <_o_> = T1_111('biasQubit',_c&o_,'biasAmp',<[_f_]>,'biasDelay',biasDelay,...
%       'backgroundWithZBias',b,...
%       'driveQubit',_c&o_,'readoutQubit',_c&o_,...
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

fcn_name = 'data_taking.public.xmon.T1_111'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'biasAmp',0,'biasDelay',0,'backgroundWithZBias',true,...
    'gui',false,'notes',''});
[readoutQubit, biasQubit, driveQubit] =...
    data_taking.public.util.getQubits(args,{'readoutQubit', 'biasQubit', 'driveQubit'});

X = gate.X(driveQubit);
I = gate.I(biasQubit);
I.ln = X.length+args.biasDelay;
Z = op.zBias4Spectrum(biasQubit);
function proc = procFactory(delay)
	Z.ln = delay;
	proc = Z*I;
end
R = measure.rReadout4T1(readoutQubit,X.mw_src{1});

x = expParam(Z,'amp');
x.name = [biasQubit.name,' z bias amplitude'];
y = expParam(@procFactory);
y.name = [driveQubit.name,' decay time(da sampling interval)'];
y.auxpara = X;
y.callbacks ={@(x_) x_.expobj.Run(); @(x_) x_.auxpara.Run()};

function rerunZ()
    proc_ = procFactory(y.val);
    proc_.Run();
end
if args.backgroundWithZBias
    R.postRunFcns = @rerunZ;
end

y_s = expParam(R,'delay');
y_s.offset = X.length;

s1 = sweep(x);
s1.vals = args.biasAmp;
s2 = sweep({y,y_s});
s2.vals = {args.time,args.time};
e = experiment();
e.sweeps = [s1,s2];
e.measurements = R;
e.plotfcn = @qes.util.plotfcn.T1;
e.datafileprefix = sprintf('%s%s[%s]',biasQubit.name, driveQubit.name,readoutQubit.name);
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