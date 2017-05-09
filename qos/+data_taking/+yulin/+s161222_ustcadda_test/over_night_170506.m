import data_taking.public.xmon.*
import data_taking.public.util.*
%%
qubitIdx = 2;
for ii = 1:numel(qubits)
	setZDC(qubits{ii},-1.7e4);
end
setZDC(qubits{qubitIdx},0);

%%
qubitIdx = 8;
for ii = 1:numel(qubits)
	setZDC(qubits{ii},1e4);
end
setZDC(qubits{qubitIdx},0);
%%
spectroscopy1_zpa_s21('qubit',qubits{qubitIdx},...
       'biasAmp',[-1000:500:2000],'driveFreq',[5.58e9:0.1e6:5.65e9],...
       'gui',true,'save',true,'notes','all other qubits dc biased at 1e4, this qubit 0 dc bias');
%%
spectroscopy1_zpa_s21('qubit',qubits{qubitIdx},...
       'biasAmp',[0],'driveFreq',[5.6045e9:0.05e6:5.6075e9],...
       'gui',true,'save',true,'notes','all other qubits dc biased at 1e4, this qubit 0 dc bias');

%%
qubitIdx = 8;
QS = qes.qSettings.GetInstance('D:\settings');
QS.saveSSettings({qubits{qubitIdx},'spc_sbFreq'},50e6);
for ii = 1:numel(qubits)
	setZDC(qubits{ii},0);
end
spectroscopy1_zpa_s21('qubit',qubits{qubitIdx},...
       'biasAmp',[-1e4:1500:25000],'driveFreq',[5.55e9:0.3e6:5.84e9],...
       'gui',true,'save',true,'notes','all qubits dc biased at 0, spc_sbFreq 50e6');
QS.saveSSettings({qubits{qubitIdx},'spc_sbFreq'},100e6);
for ii = 1:numel(qubits)
	setZDC(qubits{ii},-1e4);
end
QS.saveSSettings({qubits{qubitIdx},'zdc_amp'},-500);
qubitIdx = 8;
spectroscopy1_zpa_s21('qubit',qubits{qubitIdx},...
       'biasAmp',[-1e4:1500:25000],'driveFreq',[5.55e9:0.3e6:5.84e9],...
       'gui',true,'save',true,'notes','all other qubits dc biased at 0, this qubit zdc biased at -500, spc_sbFreq 100e6');
QS.saveSSettings({qubits{qubitIdx},'zdc_amp'},0);
%%   
qubitIdx = 6;
for ii = 1:numel(qubits)
	setZDC(qubits{ii},0);
end
QS.saveSSettings({qubits{qubitIdx},'spc_sbFreq'},50e6);
setZDC(qubits{qubitIdx},0);
spectroscopy1_zpa_s21('qubit',qubits{qubitIdx},...
       'biasAmp',[-1e4:2000:3.0e4],'driveFreq',[5.8e9:0.3e6:6.25e9],...
       'gui',true,'save',true,'notes','all qubits dc biased at 0, spc_sbFreq 50e6');
QS.saveSSettings({qubits{qubitIdx},'spc_sbFreq'},100e6);
%%   
for ii = 1:numel(qubits)
	setZDC(qubits{ii},-1e4);
end
setZDC(qubits{qubitIdx},0);
spectroscopy1_zpa_s21('qubit',qubits{10},...
       'biasAmp',[-2e4:1500:2.0e4],'driveFreq',[5.7e9:0.3e6:6.1e9],...
       'gui',true,'save',true,'notes','all qubits dc biased at 0');
%%   
qubitIdx = 4;
% for ii = 1:numel(qubits)
% 	setZDC(qubits{ii},1e4);
% end
setZDC(qubits{qubitIdx},0);
spectroscopy1_zpa_s21('qubit',qubits{qubitIdx},...
       'biasAmp',[-1e4:1500:3.0e4],'driveFreq',[5.8e9:0.2e6:6.02e9],...
       'gui',true,'save',true,'notes','all qubits dc biased at 0');