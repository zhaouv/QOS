%%
cd F:\program\qes
addpath('F:\program\qes\dlls');
import qes.*
import qes.waveform.*
import qes.util.*
import qes.hwdriver.sync.*
%%
cd F:\program\qes
QS = qSettings.GetInstance('F:\program\qes_settings');
QS.SU('yulin');
QS.SS('session1');
QS.CreateHw();
%%
MWSrc1 = mwSource.GetInstance('mw_anritsu_001');
MWSrc1.frequency = 6.84231e9;
MWSrc1.power = 20;
MWSrc1.on = true;
MWSrc3 = mwSource.GetInstance('mw_anritsu_003');
MWSrc3.power = 22;
MWSrc3.on = true;
%%
adda = ustcadda();
AWG1 = awg.GetInstance('ustc_da_1',adda);
AWG1.nchnls = 8;
%%
adda.record_ln =  2000;
IQObj = measurement.iq_ustcad(adda);
IQObj.name = 'IQ';
IQObj.n = 500;
IQObj.startidx = 20;
IQObj.endidx = 1980;
IQObj.freq = 100e6;
% IQObj.eps_a = 0.062;
IQObj.eps_a = 0;
IQObj.eps_p = 0;
%%
R = q.rr(4000);
R.amp = 0.67/2;
R.awg = AWG1;
R.awgchnl = [1,2];
R_ = fcns.Mix(R,0.05,0);
R_.SendWave();
%%
x = expParam(MWSrc3,'frequency');
x.name = 'LO frequency(Hz)';
s = sweep(x);
s.vals = (6.55e9:0.2e6:6.85e9)-100e6;
e = experiment();
e.sweeps = s;
e.measurements = IQObj;
e.Run();
%%
x = expParam(R,'amp');
x.name = 'IQ wv amplitude';
x.callbacks ={@(x) SetAuxpara(x,qes.waveform.fcns.Mix(x.expobj,0.05,0)),...
            @(x) x.auxpara.SendWave()};
y = expParam(MWSrc3,'frequency');
y.name = 'LO frequency(Hz)';
s1 = sweep(x);
s1.vals = logspace(log10(0.67/2),log10(0.1),20);
s2 = sweep(y);
s2.vals = 6.6405e9:0.03e6:6.644e9;
e = experiment();
e.sweeps = {s1,s2};
e.measurements = IQObj;
e.Run();
%%

%%
MWSrc1.power = 10;
MWSrc1.on = true;
MWSrc3.power = 22;
MWSrc3.frequency = 6.6422e9;
MWSrc3.on = true;

adda.record_ln =  4000;
IQObj = measurement.iq_ustcad(adda);
IQObj.name = 'IQ';
IQObj.n = 500;
IQObj.startidx = 3020;
IQObj.endidx = 3980;
IQObj.freq = 100e6;

R = q.rr(2000);
R.amp = 0.28;
R_ = [spacer(6000),R];
R_.awg = AWG1;
R_.awgchnl = [1,2];
R_ = fcns.Mix(R_,0.05,0);
R_.SendWave();
QR = flattop(6000);
QR.amp = 0.005;
QR_ = fcns.Mix(QR,0.05,0);
QR_.awg = AWG1;
QR_.awgchnl = [3,4];
QR_.SendWave();
Z = q.z(6000);
Z.amp = 0.3;
Z.awg = AWG1;
Z.awgchnl = [7];

x = expParam(Z,'amp');
x.name = 'zpa';
x.callbacks ={@(x) x.expobj.SendWave()};
y = expParam(MWSrc1,'frequency');
y.name = 'LO frequency(Hz)';
s1 = sweep(x);
% s1.vals = 0.1:-0.05:-0.1;
s1.vals = 0;
s2 = sweep(y);
s2.vals = (5.942e9-1.5e6:0.005e6:5.942e9+1.5e6)-100e6;
e = experiment();
e.sweeps = {s1,s2};
e.measurements = IQObj;
e.Run();
%%
MWSrc1.frequency = 5.84213e9;
MWSrc1.power = 20;
MWSrc1.on = true;
MWSrc3.power = 22;
MWSrc3.frequency = 6.6422e9;
MWSrc3.on = true;

adda.record_ln =  1120;
IQObj = measurement.iq_ustcad(adda);
IQObj.name = 'IQ';
IQObj.n = 1000;
IQObj.startidx = 120;
IQObj.endidx = 1120;
IQObj.freq = 100e6;

R = q.rr(2000);
R.amp = 0.28;
R_ = [spacer(120),R];
R_.awg = AWG1;
R_.awgchnl = [1,2];
R_ = fcns.Mix(R_,0.05,0);
R_.SendWave();
QR = q.xy(100);
QR.amp = 0.3;
QR.awg = AWG1;
QR.awgchnl = [3,4];
Z = q.z(50);
Z.amp = 0.0;
Z.awg = AWG1;
Z.awgchnl = [7];
Z.SendWave();

x = expParam(QR,'amp');
x.name = 'pi amp';
x.callbacks ={@(x) SetAuxpara(x,qes.waveform.fcns.Mix(x.expobj,0.05,0)),...
            @(x) x.auxpara.SendWave()};
s1 = sweep(x);
% s1.vals = logspace(log10(0.01),log10(0.67/2),50);
s1.vals = linspace(0,0.67/2,50);
e = experiment();
e.sweeps = {s1};
e.measurements = IQObj;
e.Run();

%%
MWSrc1.frequency = 5.84213e9;
MWSrc1.power = 20;
MWSrc1.on = true;
MWSrc3.power = 22;
MWSrc3.frequency = 6.6422e9;
MWSrc3.on = true;

adda.record_ln =  1120;
IQObj = measurement.iq_ustcad(adda);
IQObj.name = 'IQ';
IQObj.n = 1000;
IQObj.startidx = 120;
IQObj.endidx = 1120;
IQObj.freq = 100e6;

R = q.rr(2000);
R.amp = 0.28;
R_ = [spacer(120),R];
R_.awg = AWG1;
R_.awgchnl = [1,2];
R_ = fcns.Mix(R_,0.05,0);
R_.SendWave();
QR = q.xy(100);
QR.amp = 0.1504;
QR_ = fcns.Mix(QR,0.05,0);
QR_.awg = AWG1;
QR_.awgchnl = [3,4];
QR_.SendWave();

Z = q.z(50);
Z.amp = 0.0;
Z.awg = AWG1;
Z.awgchnl = [7];
Z.SendWave();

x = expParam(QR,'amp');
x.name = 'pi amp';
x.callbacks ={@(x) SetAuxpara(x,qes.waveform.fcns.Mix(x.expobj,0.05,0)),...
            @(x) x.auxpara.SendWave()};
s1 = sweep(x);
% s1.vals = logspace(log10(0.01),log10(0.67/2),50);
s1.vals = linspace(0,0.67/2,50);
e = experiment();
e.sweeps = {s1};
e.measurements = IQObj;
e.Run();



















%%
s_.name = 'networkanalyzer_001'; 
s_.class = 'qes.hwdriver.sync.networkAnalyzer';
s_.interface.class = 'visa';
s_.interface.vendor = 'agilent';
s_.interface.rscname = 'TCPIP0::10.0.0.200::inst0::INSTR';
na = qes.util.hwCreator(s_);
%%
na.power = 10;
na.swpstartfreq = 6.55e9;
na.swpstopfreq = 6.85e9;
na.swppoints = 20000;
na.bandwidth = 30e3;
na.avgcounts = 50;
na.CreateMeasurement('TRACE_S21',[2,1]);
[f,s] = na.GetData;
dbs=20*log(abs(s));
figure();plot(f/1e9,dbs,'Marker','.');
xlabel('f (GHz)');
ylabel('|S21| (dBm)');










