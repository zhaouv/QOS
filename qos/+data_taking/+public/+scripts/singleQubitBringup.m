% bring up qubits one by one
% Yulin Wu, 2017/3/11
%% initialization, run this code section before doing anything else,
% and run it whenever your are not sure whether the system is ready to run,
% repeatedly run the initialization process will not bring your any harm.
disp('Initializing...');
import data_taking.public.xmon.*  % because all xmon data taking functions that your are going to need are here 
QS = qes.qSettings.GetInstance('D:\QOS\settings');  % create the settings object, the settings root directory must be correct
QS.SU('yulin');     % switch to your private settings directory, make your own settings directory(by copy and paste other's repo and make changes)
QS.SS('s170302');   % it's good habit to start a new session now and then by copy an old session so that you can always trace back if something gose wrong
QS.CreateHw();      % create all necessary hardware objects
disp('Initialization done.'); % now you are all setup(if nothing gose wrong of course)
%%
dips = [7.04345, 7.00425, 6.9902, 6.9618,NaN,NaN,NaN,6.79613,NaN,NaN]*1e9; % by qubit index
scanRange = 5e6; % fine scan each qubit dips
%% S21 fine scan for each qubit dip, you can scan the power(by scan amp in log scale) to find the dispersive shift
% s21_rAmp('qubit','q1','freq',[dips(9):0.05e6:dips(9)+2*scanRange/3]+200e6,'amp',[logspace(log10(1000),log10(32768),25)],...
%       'notes','attenuation:26dB','gui',false,'save',true);
s21_rAmp('qubit','q4','freq',[dips(2)-1e6:0.05e6:dips(2)+1e6],'amp',[3200],...
      'notes','attenuation:26dB','gui',true,'save',true);
%% spectroscopy1_zpa_s21
% spectroscopy1_zpa_s21('qubit','q2',...
%        'biasAmp',fliplr([-18000:600:7000]),'driveFreq',[6.22e9:0.1e6:6.315e9],...
%        'notes','','gui',true,'save',true); % 4hrs
dcChnl = hw{1}.GetChnl(9);
dcChnl.dcval = 0;
spectroscopy1_zpa_s21('qubit','q8',...
       'biasAmp',[-2e4:2e3:2e4],'driveFreq',[5.9e9:0.2e6:6.7e9],...
       'gui',true,'save',true);
dcChnl = hw{1}.GetChnl(9);
dcChnl.dcval = 32768;
dcChnl = hw{1}.GetChnl(3);
dcChnl.dcval = 0;
spectroscopy1_zpa_s21('qubit','q2',...
       'biasAmp',[-2e4:2e3:2e4],'driveFreq',[5.9e9:0.2e6:6.7e9],...
       'gui',true,'save',true);
dcChnl = hw{1}.GetChnl(3);
dcChnl.dcval = 32768;
dcChnl = hw{1}.GetChnl(2);
dcChnl.dcval = 0;
spectroscopy1_zpa_s21('qubit','q1',...
       'biasAmp',[-2e4:2e3:2e4],'driveFreq',[5.9e9:0.2e6:6.7e9],...
       'gui',true,'save',true);
% spectroscopy1_zpa_s21('qubit','q2'); % lazy mode
%%
spectroscopy111_zpa_s21('biasQubit','q1','biasAmp',[-2e4:5e3:2e4],...
       'driveQubit','q1','driveFreq',[5.8e9:0.1e6:6.4e9],...
       'readoutQubit','q1',...
       'gui',true,'save',true);
%%
rabi_amp1('qubit','q2','biasAmp',[0],'biasLonger',0,...
      'xyDriveAmp',[0:500:3e4],'detuning',[0],'driveTyp','X/2',...
      'dataTyp','S21','gui',true,'save',false);
% rabi_amp1('qubit','q2','xyDriveAmp',[0:500:3e4]);  % lazy mode
%%
tuneup.optReadoutFreq('qubit','q2','gui',true,'save',true);
%%
s21_01('qubit','q2','freq',[],'notes','','gui',true,'save',true);
%%
tuneup.iq2prob_01('qubit','q2','numSamples',1e4,...
      'gui',true,'save',true);
%%
spectroscopy1_zdc('qubit','q1',...
       'biasAmp',[-3e4:100e2:3e4],'driveFreq',[5.5e9:15e6:6.3e9],...
       'gui',true,'save',true);
%%
ramsey_df('qubit','q2',...
      'time',[0:10:2000],'detuning',[2]*1e6,...
      'dataTyp','S21','notes','','gui',true,'save',true);
%%
T1_1('qubit','q1','biasAmp',[0],'time',[0:200:30e3],...
      'gui',false,'save',true)
%%
T1_1_s21('qubit','q2','biasAmp',[0],'time',[0:200:30e3],...
      'gui',true,'save',true);