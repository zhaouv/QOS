function varargout = rabi_long111(varargin)
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
%       'xyDriveAmp',[_f_],'xyDriveLong',[_f_],'detuning',<[_f_]>,'driveTyp',<_c_>,...
%       'dataTyp','_c_',...   % S21 or P
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
% GM, 2017/04/15

% Not working right now. XY.length cannot be a varible.

fcn_name = 'data_taking.public.xmon.rabi_long111'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'biasAmp',0,'biasLonger',0,'detuning',0,'driveTyp','X','dataTyp','P',...
    'r_avg',0,'gui',false,'notes','','save',true});
[readoutQubit, biasQubit, driveQubit] =...
    data_taking.public.util.getQubits(args,{'readoutQubit', 'biasQubit', 'driveQubit'});

if args.r_avg~=0 %add by GM, 20170414
    readoutQubit.r_avg=args.r_avg;
end

function proc = procFactory(amp_)
    g.amp = amp_;
    proc = g*g;
end
switch args.driveTyp
	case 'X'
		XY = gate.X(driveQubit);
	case {'X/2','X2p'}
		g = gate.X2p(driveQubit);
		XY = @procFactory;
	case {'-X/2','X2m'}
		g = gate.X2m(driveQubit);
		XY = @procFactory;
	case 'Y'
		XY = gate.Y(driveQubit);
	case {'Y/2', 'Y2p'}
		g = gate.Y2p(driveQubit);
		XY = @procFactory;
	case {'-Y/2', 'Y2m'}
		g = gate.Y2m(driveQubit);
		XY = @procFactory;
	otherwise
		throw(MException('QOS_rabi_amp111:illegalDriverTyp',...
			sprintf('the given drive type %s is not one of the allowed drive types: X, X/2, -X/2, Y, Y/2, -Y/2',...
			args.driveTyp)));
end
switch args.driveTyp
	case {'X','Y'}
        XY.delay_xy_i = args.biasLonger;
        XY.delay_xy_q = args.biasLonger;
        XY.amp = args.xyDriveAmp; % add by GM, 20170415
        XYLength = XY.length;
    otherwise
        g.delay_xy_i = args.biasLonger;
        g.delay_xy_q = args.biasLonger;
        XYLength = 2*g.length+g.gate_buffer;
end
Z = op.zBias4Spectrum(biasQubit);
Z.amp = args.biasAmp;
Z.ln = XYLength + 2*args.biasLonger;

R = measure.resonatorReadout_ss(readoutQubit);
R.delay = Z.length;

switch args.dataTyp
    case 'P'
        R.state = 2;
        % pass
    case 'S21'
        R.swapdata = true;
        R.name = '|S21|';
        R.datafcn = @(x)mean(abs(x));
    otherwise
        throw(MException('QOS_rabi_long111',...
			'unrecognized dataTyp %s, available dataTyp options are P and S21.',...
			args.dataTyp));
end

switch args.driveTyp
	case {'X','Y'}
        x = expParam(XY,'f01');
        x.callbacks ={@(x_) x_.expobj.Run()};
        x.deferCallbacks = true;
    otherwise
        x = expParam(g,'f01');
end
x.offset = driveQubit.f01;
x.name = [driveQubit.name,' detunning(f-f01, Hz)'];

y = expParam(XY,'length');
y.name = [driveQubit.name,' xyDriveLength'];
y.auxpara = Z;
y.callbacks ={@(x_) x_.expobj.Run();...
    @(x_) x_.auxpara.Run();... % Need to add Z.ln callback
    @(x_)expParam.RunCallbacks(x)};

s1 = sweep(x);
s1.vals = args.detuning;
s2 = sweep(y);
s2.vals = args.xyDriveLength;
e = experiment();
e.sweeps = [s1,s2];
e.measurements = R;
e.name = 'Rabi Long';
e.datafileprefix = sprintf('[%s]_rabi', readoutQubit.name);
if numel(s1.vals{1})>1 && numel(s2.vals{1})>1% add by GM, 20170413
    e.plotfcn = @util.plotfcn.OneMeasComplex_2DMap_Amp; 
else
    e.plotfcn = @util.plotfcn.OneMeasComplex_1D_Amp;
end

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