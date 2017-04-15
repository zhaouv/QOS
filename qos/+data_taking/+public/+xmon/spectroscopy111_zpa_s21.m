function varargout = spectroscopy111_zpa_s21(varargin)
% qubit spectroscopy of one qubit with s21 as measurement data.
% comparison: spectroscopy111_zpa and spectroscopy111_zdc measure
% probability of |1>.
% spectroscopy1_zpa_s21 is used during tune up when mesurement of 
% probability of |1> has not been setup.
% 
% <_o_> = spectroscopy1_zpa_s21('biasQubit',_c&o_,'biasAmp',<[_f_]>,...
%       'driveQubit','driveFreq',<[_f_]>,...
%       'readoutQubit',_c&o_,...
%       'notes',<_c_>,'gui',<_b_>,'save',<_b_>)
% _f_: float% _i_: integer
% _c_: char or char string
% _b_: boolean
% _o_: object
% a&b: default type is a, but type b is also acceptable
% []: can be an array, scalar also acceptable
% {}: must be a cell array
% <>: optional, for input arguments, assume the default value if not specified
% arguments order not important as long as they form correct pairs.

% Yulin Wu, 2016/1/14

fcn_name = 'data_taking.public.xmon.spectroscopy111_zpa_s21'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'biasAmp',0,'driveFreq',[],'r_avg',0,'gui',false,'notes','','save',true});
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
R.swapdata = true;
R.name = 'iq';
R.datafcn = @(x)mean(abs(x));
Z = op.zBias4Spectrum(biasQubit);

x = expParam(Z,'amp');
x.name = [biasQubit.name,' z bias amplitude'];
x.callbacks ={@(x_) x_.expobj.Run()};
x.deferCallbacks = true;
y = expParam(X.mw_src{1},'frequency');
y.offset = -driveQubit.spc_sbFreq;
y.name = [driveQubit.name,' driving frequency (Hz)'];
y.auxpara = X;
y.callbacks ={@(x_)expParam.RunCallbacks(x),@(x_)x_.auxpara.Run()};

s1 = sweep(x);
s1.vals = args.biasAmp;
s2 = sweep(y);
s2.vals = args.driveFreq;
e = experiment();
e.sweeps = [s1,s2];
e.measurements = R;

if numel(s1.vals{1})>1 && numel(s2.vals{1})>1% add by GM, 20170413
    e.plotfcn = @util.plotfcn.OneMeasComplex_2DMap_Amp_Y; 
else
    e.plotfcn = @util.plotfcn.OneMeasComplex_1D_Amp;
end
e.datafileprefix = sprintf('[%s]_spect_zpa', readoutQubit.name);
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
