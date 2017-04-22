function varargout = spectroscopy111_zdc(varargin)
% spectroscopy111: qubit spectroscopy
% bias qubit q1, drive qubit q2 and readout qubit q3,
% q1, q2, q3 can be the same qubit or different qubits,
% q1, q2, q3 all has to be the selected qubits in the current session,
% the selelcted qubits can be listed with:
% QS.loadSSettings('selected'); % QS is the qSettings object
% 
% <_o_> = spectroscopy111_zdc('biasQubit',_c&o_,'biasAmp',<[_f_]>,...
%       'driveQubit',_c&o_,'driveFreq',<[_f_]>,...
%       'readoutQubit',_c&o_,...
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

fcn_name = 'data_taking.public.xmon.spectroscopy111_zdc'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'dataTyp','P','biasAmp',0,'driveFreq',[],'r_avg',0,'gui',false,'notes','','save',true});
[readoutQubit, biasQubit, driveQubit] = data_taking.public.util.getQubits(...
    args,{'readoutQubit','biasQubit','driveQubit'});
if isempty(args.driveFreq)
    args.driveFreq = driveQubit.f01-5*driveQubit.t_spcFWHM_est:...
        driveQubit.t_spcFWHM_est/5:driveQubit.f01+5*driveQubit.t_spcFWHM_est;
end
if args.r_avg~=0 %add by GM, 20170414
    readoutQubit.r_avg=args.r_avg;
end
X = op.mwDrive4Spectrum(driveQubit);
R = measure.resonatorReadout_ss(readoutQubit);
R.delay = X.length;
% R.state = 1;
switch args.dataTyp %add by GM, 20170415
    case 'P'
        R.state = 2;
        % pass
    case 'S21'
        R.swapdata = true;
        R.name = '|S21|';
        R.datafcn = @(x)mean(abs(x));
    otherwise
        throw(MException('QOS_spectroscopy111_zdc',...
			'unrecognized dataTyp %s, available dataTyp options are P and S21.',...
			args.dataTyp));
end
Z = op.zBias4Spectrum(biasQubit);

x = expParam(Z.zdc_src{1},'dcval');
x.name = [biasQubit.name,' zdc bias amplitude'];
y = expParam(X,'mw_src{1}.frequency');
y.offset = -driveQubit.spc_sbFreq;
y.name = [driveQubit.name,' driving frequency (Hz)'];
y.callbacks ={@(x_) x_.expobj.Run()};
s1 = sweep(x);
s1.vals = args.biasAmp;
s2 = sweep(y);
s2.vals = args.driveFreq;
e = experiment();
e.name = 'Spectroscopy';
e.sweeps = [s1,s2];
e.measurements = R;
e.datafileprefix = sprintf('[%s]_spect_zdc', readoutQubit.name);
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
data_taking.public.util.setZDC(biasQubit,biasQubit.zdc_amp);
end

