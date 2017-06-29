%fusheng 2017/6/25
import qes.hwdriver.*

visaAddress = 'GPIB8::1::INSTR';
iobj = visa('tek', visaAddress);

spc = sync.spectrumAnalyzer.GetInstance('tek',iobj,'tek_rsa607a');
spc.startfreq = 2e9;
spc.stopfreq = 2.1e9;
spc.bandwidth = 10e3;
spc.numpts =801;
spc.reflevel=-10;
spc.trigmod=0;
spc.avgnum = 1000;
spc.on = true;

spc_amp=spc.get_trace();
f = linspace(spc.startfreq,spc.stopfreq,numel(spc_amp));

figure();
% semilogy(f/1e9,spc_amp);
plot(f/1e9,spc_amp)
xlabel('frequency(GHz)');ylabel('amplitude');
% disp(['peak:',spc.peak_amp,' freq:',spc.peak_freq])
