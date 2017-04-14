% bring up qubits one by one
% Yulin Wu, 2017/3/11
%%
import data_taking.public.util.*
import data_taking.public.xmon.*
qubits = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10'};
dips = [7.04343, 7.00426, 6.9902, 6.96171,6.9199,6.88215,6.833590,6.79613,6.75390,6.70932]*1e9-200e6; % by qubit index
scanRange = 5e6; % fine scan each qubit dips
%%
amp = 1e4; % logspace(log10(1000),log10(32768),20);
freq = dips(10)-2e6:0.1e6:dips(10)+1e6;
s21_rAmp('qubit',qubits{3},'freq',freq,'amp',amp,...
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
% setZDC(qubits{4},0);
for ii = 1
spectroscopy1_zpa_s21('qubit',qubits{ii},...
       'biasAmp',[-700:100:700],'driveFreq',[6.228e9:0.1e6:6.23e9],...
       'gui',true,'save',true);
end
% spectroscopy1_zpa_s21('qubit','q2'); % lazy mode
%%
spectroscopy1_zpa('qubit','q2',...
       'biasAmp',[-3.5e4:1000:1e4],'driveFreq',[5.978e9:0.25e6:6.15e9],...
       'gui',true,'save',true);
%%
spectroscopy1_zdc('qubit','q1',...
       'biasAmp',[-3e4:5e2:3e4],'driveFreq',[5.5e9:15e6:6.3e9]+125e6,...
       'gui',true,'save',true);
%%
rabi_amp1('qubit','q1','biasAmp',0,'biasLonger',0,...
      'xyDriveAmp',[0:500:3e4],'detuning',[0],'driveTyp','X',...
      'dataTyp','P','gui',true,'save',true);
% rabi_amp1('qubit','q2','xyDriveAmp',[0:500:3e4]);  % lazy mode
%%
s21_01('qubit','q2','freq',[],'notes','','gui',true,'save',true);
%%
ramsey('qubit','q1','mode','df01',... % available modes are: df01, dp and dz
      'time',[0:16:20e2],'detuning',[-5]*1e6,...
      'dataTyp','P','notes','','gui',true,'save',true);
%%
spin_echo('qubit','q1','mode','dp',... % available modes are: df01, dp and dz
      'time',[0:16:2e3],'detuning',[5]*1e6,...
      'notes','','gui',true,'save',true);
%%
T1_1('qubit','q1','biasAmp',[0],'biasDelay',16,'time',[0:160*2:20e3],...
      'gui',true,'save',true);
%%



%% automatic function, after previous steps pined down qubit parameters, 
q = qubits{1};
tuneup.correctf01bySpc('qubit',q,'gui',false,'save',true); % measure f01 by spectrum
XYGate = 'X'; % 'X', 'Y', 'X/2', 'Y/2', '-X/2', '-Y/2'
tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X','gui',false,'save',true); % finds the XY gate amplitude and update to settings
tuneup.optReadoutFreq('qubit',q,'gui',false,'save',true);
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',false,'save',true);

  
  
  