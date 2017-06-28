ii = 1;
s21_rAmp('qubit',qNames{ii},'freq',[readoutFreqs(ii)-0e6:0.01e6:readoutFreqs(ii)+1e6],'amp',3000,...
      'notes','attenuation:10dB','gui',true,'save',true);
  
ii = 2;
s21_rAmp('qubit',qNames{ii},'freq',[readoutFreqs(ii)-0e6:0.01e6:readoutFreqs(ii)+1e6],'amp',4000,...
      'notes','attenuation:10dB','gui',true,'save',true);
  
ii = 3;
s21_rAmp('qubit',qNames{ii},'freq',[readoutFreqs(ii)-0e6:0.01e6:readoutFreqs(ii)+1e6],'amp',2500,...
      'notes','attenuation:10dB','gui',true,'save',true);
  ii = 4;
s21_rAmp('qubit',qNames{ii},'freq',[readoutFreqs(ii)-0e6:0.01e6:readoutFreqs(ii)+1e6],'amp',3100,...
      'notes','attenuation:10dB','gui',true,'save',true);
  
  ii = 5;
s21_rAmp('qubit',qNames{ii},'freq',[readoutFreqs(ii)-0e6:0.01e6:readoutFreqs(ii)+1e6],'amp',3100,...
      'notes','attenuation:10dB','gui',true,'save',true);
  
    ii = 6;
s21_rAmp('qubit',qNames{ii},'freq',[readoutFreqs(ii)-0e6:0.01e6:readoutFreqs(ii)+1e6],'amp',3500,...
      'notes','attenuation:10dB','gui',true,'save',true);
  
  ii = 7;
s21_rAmp('qubit',qNames{ii},'freq',[readoutFreqs(ii)-0e6:0.01e6:readoutFreqs(ii)+1e6],'amp',3500,...
      'notes','attenuation:10dB','gui',true,'save',true);
  
  ii = 8;
s21_rAmp('qubit',qNames{ii},'freq',[readoutFreqs(ii)-0e6:0.01e6:readoutFreqs(ii)+1e6],'amp',3800,...
      'notes','attenuation:10dB','gui',true,'save',true);
  
  ii = 9;
s21_rAmp('qubit',qNames{ii},'freq',[readoutFreqs(ii)-0e6:0.01e6:readoutFreqs(ii)+1e6],'amp',4500,...
      'notes','attenuation:10dB','gui',true,'save',true);
  
  setQSettings('r_amp',3000,'q1');
  setQSettings('r_freq',6.59287e+09,'q1');
  
  setQSettings('r_amp',4000,'q2');
  setQSettings('r_freq',6.6336989e+09,'q2');
  
  setQSettings('r_amp',2500,'q3');
  setQSettings('r_freq',6.67795329e+09,'q3');
  
  setQSettings('r_amp',3100,'q4');
  setQSettings('r_freq',6.72450655e+09,'q4');
  
  setQSettings('r_amp',3100,'q5');
  setQSettings('r_freq',6.762159e+09,'q5');
  
  setQSettings('r_amp',3500,'q6');
  setQSettings('r_freq',6.7989908e+09,'q6');
  
  setQSettings('r_amp',3500,'q7');
  setQSettings('r_freq',6.84029589e+09,'q7');
  
  setQSettings('r_amp',3800,'q8');
  setQSettings('r_freq',6.88173125e+09,'q8');
  
  setQSettings('r_amp',4500,'q9');
  setQSettings('r_freq',6.9248311e+09,'q9');
  
  %%
  f01 = [5.225,4.777,5.227,4.753,NaN,4.703,5.223,4.7365,5.173]*1e9;
  for qubitIndex = [1,2,3,4,6,7,8,9]
      setQSettings('f01',f01(qubitIndex),qNames{qubitIndex});
      setQSettings('f02',11.5e9,qNames{qubitIndex});
      setQSettings('qr_xy_fc',f01(qubitIndex)-100e6,qNames{qubitIndex});
      setQSettings('g_XY_ln',60,qNames{qubitIndex});
      rabi_amp1('qubit',qNames{qubitIndex},'biasAmp',[0],'biasLonger',20,...
      'xyDriveAmp',[0:200:3e4],'detuning',[0],'driveTyp','X',...
      'dataTyp','S21','gui',true,'save',true);
  end

setQSettings('spc_sbFreq',700e6);
setQSettings('spc_driveLn',8e3);
setQSettings('spc_driveAmp',5000);
setQSettings('r_avg',1000);

for qubitIndex = [1,2,3,4,6,7,8,9]
spectroscopy1_zpa('qubit',qNames{qubitIndex},...
       'biasAmp',[0],'driveFreq',[f01(qubitIndex)-5e6:0.2e6:f01(qubitIndex)+5e6],...
       'dataTyp','S21','gui',true,'save',true); % dataTyp: S21 or P
end



q = 'q8';
% tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
T1_1('qubit',q,'biasAmp',[2000:-300:-3.2e4],'biasDelay',20,'time',[0:300:30e3],...
      'gui',true,'save',true);
  
q = 'q7';
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
T1_1('qubit',q,'biasAmp',[2000:-300:-3.2e4],'biasDelay',20,'time',[0:300:30e3],...
      'gui',true,'save',true);
  
q = 'q2';
tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
T1_1('qubit','q1','biasAmp',[2000:-300:-3.2e4],'biasDelay',20,'time',[0:300:30e3],...
      'gui',true,'save',true);
  
  