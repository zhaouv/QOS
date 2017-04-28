% bring up qubits one by one
% Yulin Wu, 2017/3/11
%%
import data_taking.public.util.*
import data_taking.public.xmon.*
qubits = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10'};
dips = [7.04343, 7.00426, 6.9902, 6.96171,6.9199,6.88215,6.833590,6.79613,6.75390,6.70932]*1e9-200e6; % by qubit index
scanRange = 5e6; % fine scan each qubit dips
%%
qubitIdx = 7;
amp = 1.0e4; % logspace(log10(1000),log10(32768),20);
freq = dips(qubitIdx)-1e6:0.05e6:dips(qubitIdx)+0.51e6;
s21_rAmp('qubit',qubits{qubitIdx},'freq',freq,'amp',amp,...
      'notes','attenuation:26dB','gui',true,'save',true);
% for ii = 1:10
% s21_rAmp('qubit',qubits{ii},'freq',[dips(ii)-2e6:0.05e6:dips(ii)+1e6],'amp',amp,...
%       'notes','attenuation:26dB','gui',true,'save',true);
% end
%%
s21_zdc('qubit', qubits{4},...
      'freq',[dips(4)-3.5e6:0.1e6:dips(4)+1e6],'amp',[-3e4:1.5e3:3e4],...
      'gui',true,'save',true);
%%
s21_zpa('qubit', 'q4',...
      'freq',[dips(4)-2.2e6:0.15e6:dips(4)+1e6],'amp',[-3e4:2e3:3e4],...
      'gui',true,'save',true);
%% spectroscopy1_zpa_s21
% for ii = 1:numel(qubits)
% 	setZDC(qubits{ii},1e4);
% end
% setZDC(qubits{7},3000);
for ii = 7
spectroscopy1_zpa_s21('qubit',qubits{ii},...
       'biasAmp',[-0.4e4:1000:4000],'driveFreq',[5.795e9:0.15e6:5.815e9],...
       'gui',true,'save',true);
end
% spectroscopy1_zpa_s21('qubit','q2'); % lazy mode
%%
spectroscopy1_zpa('qubit','q2',...
       'biasAmp',[0:1000:5000],'driveFreq',[5.94e9-5e6:0.5e6:6.01e9],...
       'gui',true,'save',true);
%%
%q2zAmp2f01 =@(x) - 1.398*(x-500).^2 - 2.634e+04*(x-500) + 5.982e+09;
q2zAmp2f01 =@(x) - 1.397*x.^2 - 2.695e+04*x + 5.977e+09;
q2zAmp2f01_ = @(x)q2zAmp2f01(x+5800);
q7zAmp2f01 =@(x) - 1.629*x.^2 + 2857*x + 5.794e+09;
spectroscopy1_zpa_bndSwp('qubit','q2',...
       'swpBandCenterFcn',q2zAmp2f01_,'swpBandWdth',100e6,...
       'biasAmp',[-1e4:100:2e4],'driveFreq',[4.8e9:0.25e6:6.15e9],...
       'gui',false,'save',true);
% spectroscopy1_zpa_bndSwp('qubit','q2',...
%        'swpBandCenterFcn',q2zAmp2f01,'swpBandWdth',120e6,...
%        'biasAmp',[6000:50:9750],'driveFreq',[5.56e9:0.2e6:5.77e9],...
%        'gui',false,'save',true);
%%
spectroscopy1_zdc('qubit','q7_c',...
       'biasAmp',[0:2:10],'driveFreq',[5.81044e9-10e6:0.2e6:5.81044e9+5e6],...
       'gui',true,'save',true);
%%
rabi_amp1('qubit','q7','biasAmp',0,'biasLonger',0,...
      'xyDriveAmp',[0:500:3e4],'detuning',[0],'driveTyp','X/2',...
      'dataTyp','P','gui',true,'save',true);
% rabi_amp1('qubit','q2','xyDriveAmp',[0:500:3e4]);  % lazy mode
%%
s21_01('qubit','q2','freq',[],'notes','','gui',true,'save',true);
%%
ramsey('qubit','q7','mode','dp',... % available modes are: df01, dp and dz
      'time',[0:16:2e3],'detuning',[5]*1e6,...
      'dataTyp','P','notes','','gui',true,'save',true);
%%
spin_echo('qubit','q7','mode','dp',... % available modes are: df01, dp and dz
      'time',[0:16:2e3],'detuning',[-5]*1e6,...
      'notes','','gui',true,'save',true);
%%
T1_1('qubit','q2','biasAmp',[0],'biasDelay',16,'time',[0:8:2e2],...
      'gui',true,'save',true);
%%
tuneup.APE('qubit','q7',...
      'phase',-pi:pi/10:pi,'numI',2,...
      'gui',true,'save',true);
%%
tuneup.zpls2f01('qubit','q7','maxBias',35e3 ,'gui',true,'save',false);
%%

%% automatic function, after previous steps pined down qubit parameters, 
q = qubits{2};
tuneup.correctf01bySpc('qubit',q,'gui',true,'save',true); % measure f01 by spectrum
% tuneup.correctf01byRamsey('qubit',q,'gui',true,'save',true); 
XYGate = 'X'; % 'X', 'Y', 'X/2', 'Y/2', '-X/2', '-Y/2'
tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate,'gui',true,'save',true); % finds the XY gate amplitude and update to settings
tuneup.optReadoutFreq('qubit',q,'gui',true,'save',true);
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);

%%
zdc2f01('qubit','q7_c','gui',true,'save',true);

  
  
  