import data_taking.public.util.*
import data_taking.public.xmon.*
qubits = {'q1','q2','q3','q4','q5','q6','q7','q8','q9','q10'};
dips = [7.04343, 7.0035, 6.9902, 6.96171,6.9199,6.88215,6.833590,6.79613,6.75390,6.70932]*1e9-200e6; % by qubit index

freq = dips(10)-25e6:0.1e6:dips(1)+25e6;
s21_rAmp('qubit',qubits{1},'freq',freq,'amp',3e4,...
'notes','attenuation:26dB','gui',true,'save',true);

qubitIdx = 10;
amp = logspace(log10(1000),log10(32768),30);
freq = dips(qubitIdx)-2e6:0.05e6:dips(qubitIdx)+0.51e6;
for ii = 1:10
s21_rAmp('qubit',qubits{ii},'freq',[dips(ii)-4e6:0.1e6:dips(ii)+3e6],'amp',amp,...
      'notes','attenuation:26dB','gui',true,'save',true);
end

for ii = 1:10
s21_zdc('qubit', qubits{ii},...
      'freq',[dips(ii)-5e6:0.1e6:dips(ii)+3e6],'amp',[-4e4:1e3:3e4],...
      'gui',true,'save',true);
s21_zpa('qubit', qubits{ii},...
      'freq',[dips(4)-5e6:0.1e6:dips(4)+3e6],'amp',[-4e4:2e3:3e4],...
      'gui',true,'save',true);
end