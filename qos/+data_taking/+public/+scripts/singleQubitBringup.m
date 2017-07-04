% bring up qubits one by one
% Yulin Wu, 2017/3/11
%%
import data_taking.public.util.allQNames
import data_taking.public.util.setZDC
import data_taking.public.util.readoutFreqDiagram
import sqc.util.getQSettings
import sqc.util.setQSettings
import data_taking.public.xmon.*
%%
% qes.util.copySession([],'s170626');
% sqc.util.resetQSettings();
%%
qNames = allQNames();
readoutFreqs = getQSettings('r_fr');
%%
setQSettings('r_uSrcPower',22);
setQSettings('r_ln',3000);
setQSettings('r_amp',3e4);
setQSettings('r_wvSettings.ring_amp',0);
setQSettings('r_wvSettings.ring_w',150);
setQSettings('qr_xy_uSrcPower',20);
%% just in case the hardware dose not startup with zero dc output, we set the output of qubit dc channels to zero
setQSettings('zdc_amp',0);
for ii = 1:numel(qNames)
    % set to the dc value in registry:
	setZDC(qNames{ii});
    % or set to an specifice value
    % setZDC(qNames{ii},0); 
end
%% s21 vs power with network analyzer
for qubitIndex = 1:9
data_taking.public.s21_scan_networkAnalyzer(... % 'NAName' can be ommitted if there is only one network analyzer
      'startFreq',readoutFreqs(qubitIndex)-0.5e6,'stopFreq',readoutFreqs(qubitIndex)+2e6,...
      'numFreqPts',501,'avgcounts',30,...
      'NAPower',[-30:1:20],'bandwidth',30e3,...
      'notes','attenuation:30dB','gui',true,'save',true);
end
%% s21 vs qubit dc bias with network analyzer
for qubitIndex = 1:9
s21_zdc_networkAnalyzer('qubit',qNames{qubitIndex},...% 'NAName' can be ommitted if there is only one network analyzer
      'startFreq',readoutFreqs(qubitIndex)-0.1e6,'stopFreq',readoutFreqs(qubitIndex)+1e6,...
      'numFreqPts',51,'avgcounts',20,'NApower',-10,...
      'biasAmp',[-3.2e4:200:3.2e4],'bandwidth',30e3,...
      'gui',true,'save',true);
end
%% s21 with DAC, a coarse scan to find all the qubit readoutFreqs
amp = 3e4; % logspace(log10(1000),log10(32768),20);
freq = 6.55e9:0.5e6:7.1e9;
s21_rAmp('qubit',qNames{1},'freq',freq,'amp',amp,...
      'notes','attenuation:20dB','gui',true,'save',true);
%% finds all qubit readoutFreqs automatically by fine s21 scan, session/public/autoConfig.readoutResonators.* has to be properly set for it to work
[readoutFreqs, pkWithd] = auto.qubitreadoutFreqs();
% after this you need to order readoutFreqs in accordance with qNames
% the upadate the readoutFreqs value to r_fr in registry for each qubit:
%% if all readoutFreqs are found correctly, save them to r_fr and r_freq in registry for each qubit:
readoutFreqs = [6.5922000,6.6331600,6.6773200,6.7239600,6.761480,6.798480,6.839720,6.881200,6.9242400]*1e9;
%%
for ii = 1:numel(qNames)
    % r_fr, the qubit dip frequency, it's exact value changes with qubit state and readout power,
    % the value of r_fr is just a reference frequency for automatic
    % routines, a close value is sufficient.
    setQSettings('r_fr',readoutFreqs(ii),qNames{ii}); 
    % also set r_freq is the frequency of the readout pulse, it is slightly
    % different than the qubit dip frequency after optimization, but at the beginning of the
    % meausrement, set it to the qubit dip frequency is OK.
    setQSettings('r_freq',readoutFreqs(ii),qNames{ii});
end
%%  s21 vs power with DAC to finds the dispersive shift, loop over all quits.
amp = logspace(log10(1000),log10(32768),30);
for ii = 1:9
s21_rAmp('qubit',qNames{ii},'freq',[readoutFreqs(ii)-0.5e6:0.05e6:readoutFreqs(ii)+1e6],'amp',amp,...
      'notes','attenuation:10dB','gui',true,'save',true);
end
%%
s21_zdc('qubit', qNames{4},...
      'freq',[readoutFreqs(4)-3.5e6:0.1e6:readoutFreqs(4)+1e6],'amp',[-3e4:1.5e3:3e4],...
      'gui',true,'save',true);
%%
s21_zpa('qubit', 'q4',...
      'freq',[readoutFreqs(4)-2.2e6:0.15e6:readoutFreqs(4)+1e6],'amp',[-3e4:2e3:3e4],...
      'gui',true,'save',true);
%% spectroscopy1_zpa_s21
setQSettings('spc_sbFreq',700e6);
setQSettings('spc_driveLn',8e3);
setQSettings('spc_driveAmp',3e4);
setQSettings('r_avg',500);
for qubitIndex = 1:9
spectroscopy1_zpa('qubit',qNames{qubitIndex},...
       'biasAmp',[0:2000:2e4],'driveFreq',[4.75e9:0.2e6:5.4e9],...
       'dataTyp','S21','gui',true,'save',true); % dataTyp: S21 or P
end
% spectroscopy1_zpa('qubit','q2'); % lazy mode
%%
spectroscopy1_zdc('qubit','q7_c',...
       'biasAmp',[0:2:10],'driveFreq',[5.81044e9-10e6:0.2e6:5.81044e9+5e6],...
       'dataTyp','S21','gui',true,'save',true); % dataTyp: S21 or P
%%
q7zAmp2f01 =@(x) - 0.46539*x.^2 + 2709.5*x + 5.222e+09;
q8zAmp2f01 =@(x) - 0.2994*x.^2 + 1890.6*x + 4.7344e+09;
spectroscopy1_zpa_bndSwp('qubit','q7',...
       'swpBandCenterFcn',q3zAmp2f01,'swpBandWdth',20e6,...
       'biasAmp',[-32500:200:32500],'driveFreq',[4.8e9:0.1e6:5.25e9],...
       'gui',true,'save',true);
% spectroscopy1_zpa_bndSwp('qubit','q2',...
%        'swpBandCenterFcn',q2zAmp2f01,'swpBandWdth',120e6,...
%        'biasAmp',[6000:50:9750],'driveFreq',[5.56e9:0.2e6:5.77e9],...
%        'gui',false,'save',true);
%%
rabi_amp1('qubit','q1','biasAmp',[0],'biasLonger',20,...
      'xyDriveAmp',[0:500:3e4],'detuning',[0],'driveTyp','X',...
      'dataTyp','S21','gui',true,'save',true);
% rabi_amp1('qubit','q2','xyDriveAmp',[0:500:3e4]);  % lazy mode
%%
rabi_long1('qubit','q3','biasAmp',0,'biasLonger',0,...
      'xyDriveAmp',10000,'xyDriveLength',[0:5:1000],...
      'dataTyp','S21','gui',true,'save',true);
%%
s21_01('qubit','q2','freq',[],'notes','','gui',true,'save',true);
%%
ramsey('qubit','q8','mode','dp',... % available modes are: df01, dp and dz
      'time',[0:50:30e3],'detuning',[2]*1e6,...
      'dataTyp','P','notes','','gui',true,'save',true);
%%
spin_echo('qubit','q8','mode','dp',... % available modes are: df01, dp and dz
      'time',[0:50:30e3],'detuning',[1]*1e6,...
      'notes','','gui',true,'save',true);
%%
T1_1('qubit','q3','biasAmp',[0],'biasDelay',20,'time',[0:100:10e3],...
      'gui',true,'save',true);
%%
resonatorT1('qubit','q2',...
      'swpPiAmp',1.8e3,'biasDelay',16,'swpPiLn',28,'time',[0:10:2000],...
      'gui',true,'save',true)
%%
tuneup.APE('qubit','q2',...
      'phase',-pi:pi/15:pi,'numI',3,...
      'gui',true,'save',true);
%%
photonNumberCal('qubit','q1',...
'time',[-500:100:2.5e3],'detuning',[0:1e6:25e6],...
'r_amp',2500,'r_ln',[],...
'ring_amp',5000,'ring_w',200,...
'gui',true,'save',true);
%%
zDelay('qubit','q2','zAmp',5000,'zLn',[],'zDelay',[-50:1:50],...
       'gui',true,'save',true)
%%
delayTime = [[0:1:20],[21:2:50],[51:5:100],[101:10:500],[501:50:3000]];
delayTime = [0:5:1e3];
zPulseRipple('qubit','q2',...
        'delayTime',delayTime,...
       'zAmp',0e4,'gui',true,'save',true);
%%
state = '|0>-i|1>';
data = singleQStateTomo('qubit','q2','reps',2,'state',state);
rho = sqc.qfcns.stateTomoData2Rho(data);
h = figure();bar3(real(rho));h = figure();bar3(imag(rho));
%%
gate = 'Y/2';
data = singleQProcessTomo('qubit','q2','reps',2,'process',gate);
chi = sqc.qfcns.processTomoData2Rho(data);
h = figure();bar3(real(chi));h = figure();bar3(imag(chi));
%%
numGates = 1:1:20;
[Pref,Pi] = randBenchMarking('qubit','q8',...
       'process','X','numGates',numGates,'numReps',20,...
       'gui',true,'save',true);
%% auto
for ii = [2,7,8]
q = qNames{ii};

tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
tuneup.optReadoutFreq('qubit',q,'gui',true,'save',true);
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);

tuneup.correctf01bySpc('qubit',q,'gui',true,'save',true); % measure f01 by spectrum
tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X','AE',true,'gui',true,'save',true);
tuneup.optReadoutFreq('qubit',q,'gui',true,'save',true);
end
%%
for ii = [2,7,8]
q = qNames{ii};

tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save','askMe');
tuneup.optReadoutFreq('qubit',q,'gui',true,'save','askMe');
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save','askMe');

tuneup.correctf01bySpc('qubit',q,'gui',true,'save','askMe'); % measure f01 by spectrum
tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X','AE',true,'gui',true,'save','askMe');
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save','askMe');
end
%%
XYGate ={'X', 'Y', 'X/2', 'Y/2', '-X/2', '-Y/2','X/4', 'Y/4', '-X/4', '-Y/4'};
for ii = 1:numel(XYGate)
    tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{ii},'AE',true,'gui',true,'save',true); % finds the XY gate amplitude and update to settings
end
%%
zdc2f01('qubit','q7_c','gui',true,'save',true);


%%
acz_ramsey('controlQ','q7','targetQ','q8',...
       'czLength',[100:10:300],'czAmp',[-1e4:-200:-2.5e4],'czDelay',20,'cState','0',...
       'notes','','gui',true,'save',true);

%%
qqSwap('qubit1','q7','qubit2','q8',...
       'biasQubit',1,'biasAmp',[-1.7e4:-100:-2.5e4],'biasDelay',10,...
       'q1XYGate','X','q2XYGate','X',...
       'swapTime',[0:10:100],'readoutQubit',2,...
       'notes','','gui',true,'save',true);
   
%%
CZTomoData = twoQProcessTomo('qubit1','q7','qubit2','q8',...
       'process','CZ','reps',1,...
       'notes','','gui',true,'save',true);
%%
twoQStateTomoData = twoQStateTomo('qubit1','q7','qubit2','q8',...
  'state','|00>','reps',1,...
 'notes','','gui',true,'save',true);

   
   
  
  


  