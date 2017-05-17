function varargout = rabi_amp111(varargin)
% rabi_amp111: Rabi oscillation by changing the pi pulse amplitude
% bias qubit q1, drive qubit q2 and readout qubit q3,
% q1, q2, q3 can be the same qubit or different qubits,
% q1, q2, q3 all has to be the selected qubits in the current session,
% the selelcted qubits can be listed with:
% QS.loadSSettings('selected'); % QS is the qSettings object
% 
% <_o_> = rabi_amp111('biasQubit',_c&o_,'biasAmp',<_f_>,'biasLonger',<_i_>,...
%       'driveQubit',_c&o_,...
%       'readoutQubit',_c&o_,...
%       'xyDriveAmp',[_f_],'detuning',<[_f_]>,'driveTyp',<_c_>,...
%       'dataTyp','_c_',...   % S21 or P
%		'numPi',<_i_>,... % number of pi rotations, default 1, use numPi > 1, e.g. 11 for pi pulse amplitude fine tuning.
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

fcn_name = 'data_taking.public.xmon.rabi_amp111'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'biasAmp',0,'biasLonger',0,'detuning',0,'driveTyp','X','dataTyp','P',...
    'numPi',1,'r_avg',0,'gui',false,'notes','','save',true});
[readoutQubit, biasQubit, driveQubit] =...
    data_taking.public.util.getQubits(args,{'readoutQubit', 'biasQubit', 'driveQubit'});

if args.r_avg~=0 %add by GM, 20170414
    readoutQubit.r_avg=args.r_avg;
end
switch args.driveTyp
	case 'X'
		g = gate.X(driveQubit);
        n = 1;
	case {'X/2','X2p'}
		g = gate.X2p(driveQubit);
        n = 2;
	case {'-X/2','X2m'}
		g = gate.X2m(driveQubit);
        n = 2;
    case {'X/4','X4p'}
		g = gate.X4p(driveQubit);
        n = 4;
    case {'-X/4','X4m'}
		g = gate.X4m(driveQubit);
        n = 4;
	case 'Y'
		g = gate.Y(driveQubit);
        n = 1;
	case {'Y/2', 'Y2p'}
		g = gate.Y2p(driveQubit);
        n = 2;
	case {'-Y/2', 'Y2m'}
		g = gate.Y2m(driveQubit);
        n = 2;
    case {'Y/4','Y4p'}
		g = gate.Y4p(driveQubit);
        n = 4;
    case {'-Y/4','Y4m'}
		g = gate.Y4m(driveQubit);
        n = 4;
	otherwise
		throw(MException('QOS_rabi_amp111:illegalDriverTyp',...
			sprintf('the given drive type %s is not one of the allowed drive types: X, X/2, -X/2, X/4, -X/4, Y, Y/2, -Y/2, Y/4, -Y/4',...
			args.driveTyp)));
end
I = gate.I(driveQubit);
I.ln = args.biasLonger;
Z = op.zBias4Spectrum(biasQubit);
Z.amp = args.biasAmp;
m = n*args.numPi;
function procFactory(amp_)
    g.amp = amp_;
    XY = g^m;
    Z.ln = XY.length + 2*args.biasLonger;
    proc = Z.*(XY*I);
    R.delay = proc.length;
    proc.Run();
end
R = measure.resonatorReadout_ss(readoutQubit);

switch args.dataTyp
    case 'P'
        R.state = 2;
        % pass
    case 'S21'
        R.swapdata = true;
        R.name = '|S21|';
        R.datafcn = @(x)mean(abs(x));
    otherwise
        throw(MException('QOS_rabi_amp111:unsupportedDataTyp',...
			'unrecognized dataTyp %s, available dataTyp options are P and S21.',...
			args.dataTyp));
end

x = expParam(g,'f01');
x.offset = driveQubit.f01;
x.name = [driveQubit.name,' detunning(f-f01, Hz)'];
y = expParam(@procFactory);
y.name = [driveQubit.name,' xyDriveAmp'];

s1 = sweep(x);
s1.vals = args.detuning;
s2 = sweep(y);
s2.vals = args.xyDriveAmp;
e = experiment();
e.sweeps = [s1,s2];
e.measurements = R;
e.name = 'rabi_amp111';
e.datafileprefix = sprintf('[%s]_rabi', readoutQubit.name);

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