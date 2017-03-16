%% waveform
import qes.*
import sqc.wv.*
import qes.util.*
import qes.hwdriver.sync.*
import data_taking.public.xmon.*
%% networkAnalyzer
iobj = visa('agilent','TCPIP0::10.0.0.200::inst0::INSTR');
na = sync.networkAnalyzer.GetInstance('na_agln5230c_1',iobj);
% or na = qes.qHandle.FindByProp('name','na_agln5230c_1'); na = na{1};
    %% single segament scan
    na.power = 20;
    na.swpstartfreq = 6.4e9;
    na.swpstopfreq = 6.97e9;
    na.swppoints = 20000;
    na.bandwidth = 30e3;
    na.avgcounts = 20;
    na.CreateMeasurement('TRACE_S21',[2,1]);
    [f,s] = na.GetData;

    dbs=20*log(abs(s));
    figure();semilogx(f/1e9,dbs,'Marker','.');
    xlabel('f (GHz)');ylabel('dB');grid on;
    %% multiple segament scan
    na.power = -30;
    na.swpstartfreq = [10e6,6e9,15e9];
    na.swpstopfreq = [4e9,12e9,20e9];
    na.swppoints = [50,500,20];
    na.bandwidth = [30e3,30e3,30e3];
    na.avgcounts = 10;
    na.CreateMeasurement('TRACE_S21',[2,1]);
    [f,s] = na.GetData;

    dbs=20*log(abs(s));
    figure();semilogx(f/1e9,dbs,'Marker','.');
    xlabel('f (GHz)');ylabel('dB');grid on;

    %% Create the measurement object GetSParam with na
    SParamObj = qes.measurement.SParam(na);
    SParamObj.name = 'S21';
    SParamObj.Run();
    figure();plot(abs(SParamObj.data(2,:)),abs(SParamObj.data(1,:)),'Marker','.');
%% ustc da
da = ustc_da();
da.vpp = 0.7;
awg = awg.GetInstance('ustc_da_1',da);

g = gaussian(50);
g.df = 0.1;
g.phase = pi/2;

g.awg = awg;
g.awgchnl = [4,3];
g.SendWave();
%%
iobj = visa('agilent','TCPIP0::10.0.0.101::inst0::INSTR');
spc = sync.spectrumAnalyzer.GetInstance('spc_n9030_1',iobj);
%%
spc.startfreq = 5e9;
spc.stopfreq = 7e9;
spc.bandwidth = 0.1e6;
spc.numpts = 501;
spc.avgnum = 1;
spc.on = true;

spc_amp = spc.get_trace();
f = linspace(spc.startfreq,spc.stopfreq,numel(spc_data));

figure();
semilogy(f/1e9,spc_amp);
xlabel('frequency(GHz)');ylabel('amplitude');
