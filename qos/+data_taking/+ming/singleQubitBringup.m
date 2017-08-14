% bring up qubits one by one
data_taking.ming.InitMeasure
import data_taking.public.util.*
import data_taking.public.xmon.*
import sqc.util.getQSettings
import sqc.util.setQSettings
import data_taking.public.util.readoutFreqDiagram
%%
ustcaddaObj.close()

%%
for II=1:10
    setQSettings('r_fr',dips(II),qubits{II});
end
%%
setQSettings('r_avg',0.5e3)
%%
setQSettings('spc_sbFreq',400e6);
setQSettings('spc_driveLn',6e3);
%%
setQSettings('zdc_amp',0);
%%
setQSettings('channels.xy_mw.chnl',2);
setQSettings('qr_xy_uSrcPower',7);
%%
setQSettings('channels.r_mw.instru','mwSrc_sinolink_1');
setQSettings('channels.r_mw.chnl',1);
setQSettings('r_uSrcPower',20);
%%
for II=1:10
    setZDC(qubits{II},0);
end
%%
readoutFreqDiagram(qubits,200e6)
%%
data_taking.public.jpa.turnOnJPA('jpaName','impa1','pumpFreq',13.55e9,'pumpPower',5,'bias',0.00014,'on',true)
%% S21
s21_rAmp('qubit', qubits{10},...
    'freq',dips(1)-5e6:1e6:dips(end)+5e6,'amp',1e4,...
    'notes','H5H6','gui',true,'save',true);
%%
s21_rAmp('qubit', qubits{9},...
    'freq',6.55e9:1e6:7.1e9,'amp',1e4,...
    'notes','','gui',true,'save',true);
%%
for II=1:10
    s21_zdc_networkAnalyzer('qubit',qubits{II},'NAName',[],'startFreq',dips(II)-3e6,'stopFreq',dips(II)+3e6,'numFreqPts',500,'avgcounts',5,'NApower',-20,'biasAmp',[-3e4:1e3:3e4],'bandwidth',2000,'notes','','gui',true,'save',true)
end
%%
for II=1:10
    s21_zdc('qubit', qubits{II},...
        'freq',[dips(II)-1e6:0.1e6:dips(II)+2e6],'amp',[-3e4:3e3:3e4],...
        'notes',[qubits{II}],'gui',true,'save',true);
end

%% S21 fine scan for each qubit dip, you can scan the power(by scan amp in log scale) to find the dispersive shift
amps=[logspace(log10(1000),log10(30000),41)];
for II = 10:-1:1
    data1{II}=s21_rAmp('qubit',qubits{II},'freq',[dips(II)-1e6:0.1e6:dips(II)+2e6],'amp',amps,...  % logspace(log10(1000),log10(32768),25)
        'notes','r_fr center£¬30dB @ RT','gui',true,'save',true,'r_avg',1000);
end
%% figure out dispersive shift
for II=1:10
    dd=abs(cell2mat(data1{1,II}.data{1,1}));
    z_ = 20*log10(abs(dd));
    sz=size(z_);
    for jj = 1:sz(2)
        z_(:,jj) = z_(:,jj) - z_(1,jj);
    end
    frqs=dips(II)+(-1e6:0.1e6:2e6);
    [~,mm]=min(z_);
    figure;surface(frqs,amps,z_','edgecolor','none')
    hold on;plot3(frqs(mm),amps,100*ones(1,length(amps)),'-or')
    set(gca,'YScale','log')
    axis tight
    colormap('jet')
    title(qubits{II})
end
%% Set all dispersive readout point
% r_freq=[6.849e9 6.819e9 6.794e9 6.755e9 6.708e9 6.683e9 6.66e9 6.642e9 6.624e9 6.591e9];
r_amp=[4244 4621 6493 9123 4244 1.519e4 7696 1.396e4 1.519e4 1.519e4];
for II=1:numel(r_amp)
%     setQSettings('r_freq',r_freq(II),qubits{11-II});
    setQSettings('r_amp',r_amp(II),qubits{11-II});
end

%% Get all S21 curves with current readout setup, and update r_freq
for II=1:10
    r_freq=getQSettings('r_freq', qubits{II});
    s_r_freq=r_freq-0.5e6:0.05e6:r_freq+0.5e6;
    data2{II}=s21_rAmp('qubit', qubits{II},...
        'freq',s_r_freq,'amp',getQSettings('r_amp', qubits{II}),...
        'notes',qubits{II},'gui',true,'save',true);
    dat=smooth(abs(cell2mat(data2{1,II}.data{1,1})),3)';
    [~,lo]=min(dat);
    r_freq1=s_r_freq(lo)
    setQSettings('r_freq',r_freq1,qubits{II});
end
%% for High power readout
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
for II=10:-1:1
    s21_zpa('qubit', qubits{II},...
        'freq',[dips(II)-1e6:0.1e6:dips(II)+2e6],'amp',[-3e4:6e3:3e4],...
        'notes',[qubits{II} ', S21 vs Z pulse'],'gui',true,'save',true,'r_avg',300);
end
%% spectroscopy1_zpa
for II=[3]
    cP=getQSettings('qr_xy_uSrcPower', qubits{II});
    setQSettings('qr_xy_uSrcPower',7-10, qubits{II});
    setQSettings('spc_sbFreq',-500e6, qubits{II});
    QS.saveSSettings({qubits{II},'spc_driveAmp'},5000)
    data0{II}=spectroscopy1_zpa('qubit',qubits{II},...
        'biasAmp',[-2e4:1e3:2e4],'driveFreq',[4.7e9:1e6:5e9],...
        'r_avg',1000,'notes','10dB in RT','gui',true,'save',true,'dataTyp','S21');
    setQSettings('qr_xy_uSrcPower',cP, qubits{II});
end
% sendmail2me('minggong@ustc.edu.cn', 'Measurement Done')
%%
for II=9
    cP=getQSettings('qr_xy_uSrcPower', qubits{II});
    setQSettings('qr_xy_uSrcPower',7-20, qubits{II});
    setQSettings('spc_sbFreq',800e6, qubits{II});
    QS.saveSSettings({qubits{II},'spc_driveAmp'},30000)
    data0{II}=spectroscopy1_zpa('qubit',qubits{II},...
        'biasAmp',000,'driveFreq',[5.3e9:2e6:6.2e9],...
        'r_avg',500,'notes','800M sb','gui',true,'save',true,'dataTyp','S21');
    setQSettings('qr_xy_uSrcPower',cP, qubits{II});
end
%% qubitStability
data=data_taking.public.scripts.qubitStability('qubit','q2','Repeat',200,...
    'biasAmp',2e4,'driveFreq',[5.5e9:2e6:6.2e9],'dataTyp','S21',...
    'r_avg',1000,'notes','','gui',false,'save',false);

%%
% setZDC('q2',-2000);
rabi_amp1('qubit','q3','biasAmp',-000,'biasLonger',10,...
    'xyDriveAmp',[0:500:3e4],'detuning',0,'driveTyp','X','notes','10dB attn.',...
    'dataTyp','S21','r_avg',1000,'gui',true,'save',true);
% rabi_amp1('qubit','q2','xyDriveAmp',[0:500:3e4]);  % lazy mode
%% 
rabi_long1('qubit','q2','biasAmp',0,'biasLonger',10,...
    'xyDriveAmp',[0.5e4],'xyDriveLength',[2:2:200],'detuning',[0],'driveTyp','X','notes','10dB attn.',...
    'dataTyp','P','r_avg',3000,'gui',true,'save',true);
%%
s21_01('qubit','q3','freq',6.93e9:1e5:6.938e9,'notes','','gui',true,'save',true);
%%
Ramp=logspace(2,4.5,51);
s21_01_rAmp('qubit','q6','freq',[],'rAmp',Ramp,'notes','','gui',true,'save',true);
%%
tuneup.xyGateAmpTuner('qubit','q3','gateTyp','X','gui',false,'save',true);
%%
% QS.saveSSettings({'q2','r_amp'},0.77e4);
tuneup.optReadoutFreq('qubit','q2','gui',true,'save',true);
%%
tuneup.iq2prob_01('qubit','q2','numSamples',1e4,...
    'gui',true,'save',true)
%%
tuneup.optReadoutAmp('qubit','q2','gui',true,'save',true,'bnd',[2000,30000],'optnum',31);
%% automatic function, after previous steps pined down qubit parameters,
q = qubits{5};
tuneup.correctf01bySpc('qubit',q,'gui',true,'save',true); % measure f01 by spectrum
XYGate ={'X', 'Y', 'X/2', 'Y/2', '-X/2', '-Y/2','X/4', 'Y/4', '-X/4', '-Y/4'};
for II = 1:numel(XYGate)
    tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{II},'gui',true,'save',true); % finds the XY gate amplitude and update to settings
end
tuneup.optReadoutFreq('qubit',q,'gui',true,'save',true);
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
%%
spectroscopy1_zdc('qubit','q2',...
    'biasAmp',[-10000:250:10000],'driveFreq',[5.e9:2e6:6.4e9],'dataTyp','S21','note','F2',...
    'r_avg',1000,'gui',true,'save',true);
%%
ramsey('mode','dp','qubit','q2',...
    'time',[0:4:600],'detuning',-40*1e6,'T1',1560,...
    'dataTyp','P','notes','','gui',true,'save',true);
% ramsey_df01('qubit','q6',...
%       'time',[0:2:200],'detuning',10*1e6,...
%       'dataTyp','P','notes','','gui',true,'save',true);
%%
T1_1('qubit','q2','biasAmp',0,'time',[0:200:20e3],'biasDelay',16,...
    'gui',true,'save',true,'r_avg',1000,'fit',true)
%%
T1_1('qubit','q10','biasAmp',[-3e4:1e3:3e4],'time',[0:50:5e3],'biasDelay',16,...
    'gui',true,'save',true,'r_avg',1000,'fit',true)
%%
T1_1_s21('qubit','q6','biasAmp',000,'time',[0:100:8e3],'biasDelay',0,...
    'gui',true,'save',true,'r_avg',5000)
%%
T1_1_s21('qubit','q2','biasAmp',[-3e4:1e3:3e4],'time',[0:200:10e3],...
    'gui',true,'save',true,'r_avg',5000)