% bring up qubits one by one
% GM, 2017/4/14
import qes.*
import qes.hwdriver.sync.*
QS = qSettings.GetInstance('D:\Dropbox\MATLAB GUI\USTC Measurement System\settings');
QS.SU('Ming');
QS.SS('s170602');
QS.CreateHw();
ustcaddaObj = ustcadda_v1.GetInstance();
import data_taking.public.util.*
import data_taking.public.xmon.*
import sqc.util.getQSettings
import sqc.util.setQSettings
import data_taking.public.util.readoutFreqDiagram
% qubits = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10'};
qubits = {'q10','q9','q8','q7','q6','q5','q4','q3','q2','q1'};
dips = [6.64320 6.68880 6.73840 6.77460 6.81090 6.85010 6.89200 6.93300 6.94520 6.99620]*1e9; % by qubit index
%%
ustcaddaObj.close()

%%
for ii=1:10
setQSettings('r_fr',dips(ii),qubits{ii});
end
%%
setQSettings('r_ln',4000);
%%
setQSettings('zdc_amp',0.5e4);
%%
for ii=3:10
setZDC(qubits{ii},0.5e4);
end
%%
readoutFreqDiagram
%%
data_taking.public.jpa.turnOnJPA('jpaName','impa1','pumpFreq',13.55e9,'pumpPower',5,'bias',0.00014,'on',true)

%%
for ii=1
s21_zdc_networkAnalyzer('qubit',qubits{ii},'NAName',[],'startFreq',dips(ii)-1e6,'stopFreq',dips(ii)+2e6,'numFreqPts',500,'avgcounts',5,'NApower',-15,'biasAmp',[-3e4:1e3:3e4],'bandwidth',2000,'notes','','gui',true,'save',true)
end
%% S21
ii=5;
s21_zdc('qubit', qubits{ii},...
      'freq',dips(ii)-1e6:0.02e6:dips(ii)+1.5e6,'amp',5000,...
      'notes','','gui',true,'save',true);
%% S21 fine scan for each qubit dip, you can scan the power(by scan amp in log scale) to find the dispersive shift
amps=[logspace(log10(3000),log10(30000),31)];
for ii = 10
data{ii}=s21_rAmp('qubit',qubits{ii},'freq',[dips(ii)-1e6:0.1e6:dips(ii)+1.5e6],'amp',amps,...  % logspace(log10(1000),log10(32768),25)
      'notes','30dB @ RT, zdc=5000','gui',true,'save',true,'r_avg',1500);
end
%%
for ii=3:10
dd=abs(cell2mat(data{1,ii}.data{1,1}));
z_ = 20*log10(abs(dd));
sz=size(z_);
for jj = 1:sz(2)
    z_(:,jj) = z_(:,jj) - z_(1,jj);
end
frqs=dips(ii)+(-1e6:0.1e6:1.5e6);
[~,mm]=min(z_);
figure;surface(frqs,amps,z_','edgecolor','none')
hold on;plot3(frqs(mm),amps,100*ones(1,length(amps)),'-or')
set(gca,'YScale','log')
axis tight
colormap('jet')
title(qubits{ii})
end
%%
for ii=7
    setQSettings('r_freq',6.8927e9,qubits{ii});
    setQSettings('r_amp',1.9e4,qubits{ii});
end
%%
for II=10
s21_zdc('qubit', qubits{II},...
      'freq',[dips(II)-1e6:0.1e6:dips(II)+2e6],'amp',[-3e4:6e3:3e4],...
      'notes',[qubits{II}],'gui',true,'save',true);
end
%%
Damp=logspace(0,4.5,51);
for II=5
data=s21_rAmp('qubit', qubits{II},...
      'freq',6.811e9,'amp',Damp,...
      'notes','10dB @ RT pump','gui',true,'save',true);
data1=cell2mat(data.data{1,1});
figure;semilogx(Damp,abs(data1))
xlabel([qubits{II} ' Readout Amp'])
ylabel('|IQ|')
end
%%
for ii=3:6
s21_zpa('qubit', qubits{ii},...
      'freq',[dips(ii)-1e6:0.1e6:dips(ii)+2e6],'amp',[-3e4:3e3:3e4],...
      'notes',[qubits{ii} ', S21 vs Z pulse'],'gui',true,'save',true,'r_avg',300);
end



%% spectroscopy1_zpa_s21
for ii=5
    QS.saveSSettings({qubits{ii},'spc_driveAmp'},2000)
    data0{ii}=spectroscopy1_zpa('qubit',qubits{ii},...
       'biasAmp',[-3e4:1e3:3e4],'driveFreq',[4.e9:2e6:6e9],...
       'r_avg',3000,'notes','','gui',true,'save',true,'dataTyp','S21');
end
%%
for ii=5
    QS.saveSSettings({qubits{ii},'spc_driveAmp'},200)
    data0{ii}=spectroscopy1_zpa('qubit',qubits{ii},...
       'biasAmp',0,'driveFreq',[4.5e9:2e6:5.6e9],...
       'r_avg',3000,'notes','100M sb, ramp=200','gui',true,'save',true,'dataTyp','S21');
end
%%
data_taking.public.scripts.qubitStability('qubit','q3','Repeat',1,...
       'biasAmp',0,'driveFreq',[6.45e9:2e6:6.55e9],...
       'r_avg',1000,'notes','','gui',true,'save',true);
  
%%
% setZDC('q2',-2000);
rabi_amp1('qubit','q6','biasAmp',000,'biasLonger',10,...
      'xyDriveAmp',[0:500:3e4],'detuning',0,'driveTyp','X','notes','20dB attn.',...
      'dataTyp','S21','r_avg',5000,'gui',true,'save',true);
% rabi_amp1('qubit','q2','xyDriveAmp',[0:500:3e4]);  % lazy mode
%% To do
rabi_long1('qubit','q6','biasAmp',000,'biasLonger',10,...
      'xyDriveAmp',[1e4],'xyDriveLength',[20:20:2000],'detuning',[0],'driveTyp','X','notes','20dB attn.',...
      'dataTyp','S21','r_avg',3000,'gui',true,'save',true);
%%
s21_01('qubit','q3','freq',6.93e9:1e5:6.938e9,'notes','','gui',true,'save',true);
%%
Ramp=logspace(2,4.5,51);
s21_01_rAmp('qubit','q6','freq',[],'rAmp',Ramp,'notes','','gui',true,'save',true);
%%
tuneup.xyGateAmpTuner('qubit','q3','gateTyp','X','gui',false,'save',true);
%%
% QS.saveSSettings({'q2','r_amp'},0.77e4);
tuneup.optReadoutFreq('qubit','q6','gui',true,'save',true);
%%
tuneup.iq2prob_01('qubit','q6','numSamples',1e4,...
      'gui',true,'save',true)
 %% automatic function, after previous steps pined down qubit parameters, 
q = qubits{2};
tuneup.correctf01bySpc('qubit',q,'gui',true,'save',true); % measure f01 by spectrum
XYGate ={'X', 'Y', 'X/2', 'Y/2', '-X/2', '-Y/2','X/4', 'Y/4', '-X/4', '-Y/4'};
for ii = 1:numel(XYGate)
    tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{ii},'gui',true,'save',true); % finds the XY gate amplitude and update to settings
end
tuneup.optReadoutFreq('qubit',q,'gui',true,'save',true);
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
%%
spectroscopy1_zdc('qubit','q2',...
       'biasAmp',[-10000:250:10000],'driveFreq',[5.e9:2e6:6.4e9],'dataTyp','S21','note','F2',...
       'r_avg',1000,'gui',true,'save',true);
%%
% ramsey_df('qubit','q4',...
%       'time',[0:400:30000],'detuning',[1]*1e6,...
%       'dataTyp','S21','notes','','gui',true,'save',true);
ramsey_df01('qubit','q3',...
      'time',[0:10:2000],'detuning',[5]*1e6,...
      'dataTyp','P','notes','','gui',true,'save',true);
%%
T1_1('qubit','q3','biasAmp',[0,1000],'time',[0:400:20e3],'biasDelay',16,...
      'gui',true,'save',true,'r_avg',1000,'fit',true)
%%
T1_1('qubit','q3','biasAmp',[2e4:0.5e3:3e4],'time',[0:400:20e3],'biasDelay',16,...
      'gui',true,'save',true,'r_avg',5000,'fit',true)
%%
T1_1_s21('qubit','q6','biasAmp',-12000,'time',[0:100:8e3],'biasDelay',0,...
      'gui',true,'save',true,'r_avg',5000)
  %%
  T1_1_s21('qubit','q2','biasAmp',[-3e4:1e3:3e4],'time',[0:200:10e3],...
      'gui',true,'save',true,'r_avg',5000)