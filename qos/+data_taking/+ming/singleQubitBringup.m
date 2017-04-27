% bring up qubits one by one
% GM, 2017/4/14
import qes.*
import qes.hwdriver.sync.*
QS = qSettings.GetInstance('D:\Dropbox\MATLAB GUI\USTC Measurement System\settings');
QS.SU('Ming');
QS.SS('s170405');
QS.CreateHw();
ustcaddaObj = ustcadda_v1.GetInstance();
import data_taking.public.util.*
import data_taking.public.xmon.*
qubits = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10'};
dips = [6.9017 6.7981 6.8634 6.334 6.7099 6.6174 6.6578  6.6791 6.6371 6.5638]*1e9; % by qubit index
%% S21 fine scan for each qubit dip, you can scan the power(by scan amp in log scale) to find the dispersive shift

amps=[logspace(log10(3000),log10(30000),41)];
for ii = 8
s21_rAmp('qubit',qubits{ii},'freq',[dips(ii)-2.5e6:0.1e6:dips(ii)+1e6],'amp',amps,...  % logspace(log10(1000),log10(32768),25)
      'notes',['RT attenuation:23dB; ' qubits{ii}],'gui',true,'save',true,'r_avg',1000);
end
%%

for II=8
s21_zdc('qubit', qubits{II},...
      'freq',[dips(II)-2e6:0.1e6:dips(II)+1e6],'amp',[-3e4:1e3:3e4],...
      'notes',[qubits{II}],'gui',true,'save',true);
end

%%
for ii=8
s21_zpa('qubit', qubits{ii},...
      'freq',[dips(ii)-1e6:0.1e6:dips(ii)+2e6],'amp',[-3e4:3e3:3e4],...
      'notes',[qubits{ii} ', S21 vs Z pulse'],'gui',true,'save',true);
end

%%
for ii=10:10
s21_zdc_networkAnalyzer('qubit','q1','NAName',[],'startFreq',dips(ii)-3e6,'stopFreq',dips(ii)+3e6,'numFreqPts',500,'avgcounts',10,'NApower',-10,'amp',[-3e4:1e3:3e4],'bandwidth',20000,'notes',['DC4, Dip ' num2str(ii)],'gui',true,'save',true)
end

%% spectroscopy1_zpa_s21

for ii=8
    QS.saveSSettings({qubits{ii},'spc_driveAmp'},2000)
    spectroscopy1_zpa_s21('qubit',qubits{ii},...
       'biasAmp',0,'driveFreq',[5.65e9:2e6:5.95e9],...
       'r_avg',4000,'notes','','gui',true,'save',true);
end
%%
amp=5e3;
QS.saveSSettings({qubits{2},'spc_driveAmp'},amp)
spectroscopy1_zpa_s21('qubit',qubits{2},...
       'biasAmp',0,'driveFreq',[5.4e9:1e6:5.9e9],...
       'notes',[qubits{2} ', spc amp: ' num2str(amp)],'r_avg',1000,'gui',true,'save',true);
%%
% setZDC('q2',-2000);
rabi_amp1('qubit','q8','biasAmp',[0],'biasLonger',0,...
      'xyDriveAmp',[0:300:3e4],'detuning',[0],'driveTyp','X','notes','20dB',...
      'dataTyp','S21','r_avg',10000,'gui',true,'save',true);
% rabi_amp1('qubit','q2','xyDriveAmp',[0:500:3e4]);  % lazy mode
%% To do
rabi_long111('biasQubit','q2','driveQubit','q2','readoutQubit','q2','biasAmp',[0],'biasLonger',500,...
      'xyDriveAmp',[1e4],'xyDriveLength',[10:50:2000],'detuning',[0],'driveTyp','X',...
      'dataTyp','S21','r_avg',5000,'gui',true,'save',true);
%%
s21_01('qubit','q2','freq',[],'notes','','gui',true,'save',true);
%%
tuneup.xyGateAmpTuner('qubit','q2','gateTyp','X','gui',false,'save',true);
%%
% QS.saveSSettings({'q2','r_amp'},0.77e4);
tuneup.optReadoutFreq('qubit','q8','gui',true,'save',true);
tuneup.iq2prob_01('qubit','q8','numSamples',1e4,...
      'gui',true,'save',true)
 
%%
spectroscopy1_zdc('qubit','q2',...
       'biasAmp',[-10000:250:10000],'driveFreq',[5.e9:2e6:6.4e9],'dataTyp','S21','note','F2',...
       'r_avg',1000,'gui',true,'save',true);
%%
% ramsey_df('qubit','q4',...
%       'time',[0:400:30000],'detuning',[1]*1e6,...
%       'dataTyp','S21','notes','','gui',true,'save',true);
ramsey_df01('qubit','q2',...
      'time',[0:40:2000],'detuning',[+4]*1e6,...
      'dataTyp','S21','notes','','gui',true,'save',true);
%%
T1_1_s21('qubit','q8','biasAmp',[0],'time',[0:200:10e3],...
      'gui',true,'save',true,'r_avg',10000)
  %%
  T1_1_s21('qubit','q2','biasAmp',[-3e4:1e3:3e4],'time',[0:200:10e3],...
      'gui',true,'save',true,'r_avg',5000)