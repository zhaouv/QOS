% bring up qubits one by one
% GM, 2017/4/14
%%
import qes.*
import qes.hwdriver.sync.*
QS = qSettings.GetInstance('D:\Dropbox\MATLAB GUI\USTC Measurement System\settings');
QS.SU('Ming');
QS.SS('s170405');
QS.CreateHw();
import data_taking.public.util.*
import data_taking.public.xmon.*
qubits = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10'};
dips = [6.9017 6.7981 6.8634 6.334 6.7099 6.6174 6.6578  6.6791 6.6361 6.5638]*1e9; % by qubit index
%% S21 fine scan for each qubit dip, you can scan the power(by scan amp in log scale) to find the dispersive shift

amps=[logspace(log10(2000),log10(30000),41)];
for ii = 2
s21_rAmp('qubit',qubits{ii},'freq',[dips(ii)-2e6:0.1e6:dips(ii)+1e6],'amp',amps,...  % logspace(log10(1000),log10(32768),25)
      'notes',['RT attenuation:23dB; ' qubits{ii}],'gui',true,'save',true);
end
%%

for II=2
s21_zdc('qubit', qubits{II},...
      'freq',[dips(II)-2e6:0.1e6:dips(II)+1e6],'amp',[-0.1e4:1e3:0e4],...
      'notes',[qubits{II}],'gui',true,'save',true);
end

%%
for ii=2:2
s21_zpa('qubit', qubits{ii},...
      'freq',[dips(ii)-2e6:0.2e6:dips(ii)+1e6],'amp',[-3e4:1e3:3e4],...
      'notes',[qubits{ii} ', S21 vs Z pulse'],'gui',true,'save',true);
end

%%
setZDC('q4',0);
s21_zpa('qubit', 'q4',...
      'freq',[dips(4)-2.2e6:0.15e6:dips(4)+1e6],'amp',[-3e4:2e3:3e4],...
      'gui',true,'save',true);
%%
for ii=10:10
s21_zdc_networkAnalyzer('qubit','q1','NAName',[],'startFreq',dips(ii)-3e6,'stopFreq',dips(ii)+3e6,'numFreqPts',500,'avgcounts',10,'NApower',-10,'amp',[-3e4:1e3:3e4],'bandwidth',20000,'notes',['DC4, Dip ' num2str(ii)],'gui',true,'save',true)
end

%% spectroscopy1_zpa_s21
% for ii = 1:numel(qubits)
% 	setZDC(qubits{ii},1e4);
% end
% setZDC(qubits{4},0);
% spectroscopy1_zpa_s21('qubit','q1',...
%        'biasAmp',[-1.5e4:1.25e3:3e4],'driveFreq',[6.1e9:0.10e6:6.35e9],...
%        'gui',false,'save',true);
% spectroscopy1_zpa_s21('qubit','q2',...
%        'biasAmp',[-3e4:1.25e3:1.5e4],'driveFreq',[5.9e9:0.10e6:6.2e9],...
%        'gui',false,'save',true);
% spectroscopy1_zpa_s21('qubit','q3',...
%        'biasAmp',[-3e4:2.5e3:3e4],'driveFreq',[5.75e9:0.10e6:6.05e9],...
%        'gui',false,'save',true);
% for amp=[2e3]
% QS.saveSSettings({'q2','spc_driveAmp'},amp)
for ii=2:3
    QS.saveSSettings({qubits{ii},'spc_driveAmp'},2e3)
    spectroscopy1_zpa_s21('qubit',qubits{ii},...
       'biasAmp',[800:-25:200],'driveFreq',[5.2e9:0.5e6:6e9],...
       'r_avg',3000,'notes',[qubits{ii} ', spc amp: ' num2str(2e3)],'gui',true,'save',true);
end
% end
% for ii = 5:10
% spectroscopy1_zpa_s21('qubit',qubits{ii},...
%        'biasAmp',[-2e4:5e3:2e4],'driveFreq',[5.8e9:0.20e6:6.15e9],...
%        'gui',false,'save',true);
% end
%%
amp=0.5e3;
QS.saveSSettings({qubits{2},'spc_driveAmp'},amp)
spectroscopy1_zpa_s21('qubit',qubits{2},...
       'biasAmp',800,'driveFreq',[5.45e9:0.5e6:5.75e9],...
       'notes',[qubits{2} ', spc amp: ' num2str(amp)],'r_avg',4000,'gui',true,'save',true);
%%
for ii = 1:numel(qubits)
    spectroscopy111_zpa_s21('biasQubit',qubits{ii},'biasAmp',[-3e4:5e3:3e4],...
       'driveQubit','q4','driveFreq',[5.9e9:3e6:6.15e9],...
       'readoutQubit','q4',...
       'gui',true,'save',true);
end
%%
spectroscopy111_zpa_s21('biasQubit','q1','biasAmp',[-2e4:5e3:2e4],...
       'driveQubit','q1','driveFreq',[5.4e9:0.5e6:6e9],...
       'readoutQubit','q1',...
       'r_avg',4000,'gui',true,'save',true);
%%
setZDC('q2',-2000);
rabi_amp1('qubit','q2','biasAmp',[0],'biasLonger',500,...
      'xyDriveAmp',[0:200:3e4],'detuning',[0],'driveTyp','X','note','F2',...
      'dataTyp','S21','r_avg',1000,'gui',true,'save',true);
% rabi_amp1('qubit','q2','xyDriveAmp',[0:500:3e4]);  % lazy mode
%%
rabi_long111('biasQubit','q2','driveQubit','q2','readoutQubit','q2','biasAmp',[0],'biasLonger',500,...
      'xyDriveAmp',[1e4],'xyDriveLength',[10:50:2000],'detuning',[0],'driveTyp','X',...
      'dataTyp','S21','r_avg',5000,'gui',true,'save',true);
%%
tuneup.optReadoutFreq('qubit','q2','gui',true,'save',true);
%%
s21_01('qubit','q2','freq',[],'notes','','gui',true,'save',true);
%%
tuneup.iq2prob_01('qubit','q2','numSamples',1e4,...
      'gui',true,'save',true);
%%
spectroscopy1_zdc('qubit','q2',...
       'biasAmp',[-2000:-500:-5000],'driveFreq',[5e9:1e6:6.5e9],'dataTyp','S21','note','F2',...
       'r_avg',1000,'gui',true,'save',true);
%%
% ramsey_df('qubit','q4',...
%       'time',[0:400:30000],'detuning',[1]*1e6,...
%       'dataTyp','S21','notes','','gui',true,'save',true);
ramsey_df_('qubit','q4',...
      'time',[0:40:20000],'detuning',[+4]*1e6,...
      'dataTyp','S21','notes','','gui',true,'save',true);
%%
T1_1('qubit','q1','biasAmp',[0],'time',[0:200:30e3],...
      'gui',false,'save',true)
%%
T1_1_s21('qubit','q4','biasAmp',[0],'time',[0:400:20e3],...
      'gui',true,'save',true);