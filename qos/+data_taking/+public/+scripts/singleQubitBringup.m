% bring up qubits one by one
% Yulin Wu, 2017/3/11
%%
import data_taking.public.util.*
import data_taking.public.xmon.*
qubits = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10'};
dips = [7.04343, 7.00426, 6.9902, 6.9618,NaN,NaN,NaN,6.79613,NaN,NaN]*1e9; % by qubit index
scanRange = 5e6; % fine scan each qubit dips
%% S21 fine scan for each qubit dip, you can scan the power(by scan amp in log scale) to find the dispersive shift
s21_rAmp('qubit','q1','freq',[dips(2)-1e6:0.025e6:dips(2)+1e6],'amp',[6e3],...  % logspace(log10(1000),log10(32768),25)
      'notes','attenuation:26dB','gui',true,'save',true);
%% spectroscopy1_zpa_s21
for ii = 1:numel(qubits)
	setZDC(qubits{ii},1e4);
end
setZDC(qubits{1},0);
spectroscopy1_zpa_s21('qubit','q1',...
       'biasAmp',[-2e4:5e3:2e4],'driveFreq',[5.8e9:0.1e6:6.4e9],...
       'gui',false,'save',true);
setZDC(qubits{1},1e4);
setZDC(qubits{2},0);
spectroscopy1_zpa_s21('qubit','q2',...
       'biasAmp',[-2e4:5e3:2e4],'driveFreq',[5.8e9:0.1e6:6.4e9],...
       'gui',false,'save',true);
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