% ustcadda tester
%%
import qes.*
import qes.hwdriver.sync.*
cd('Q:\qos');
addpath('Q:\qos\dlls');
QS = qSettings.GetInstance('Q:\settings');
%% not needed unless you want to reconfigure the DACs and ADCs during the measurement
% a DACs and ADCs reconfiguration is only needed when the hardware settings
% has beens changed, a reconfiguration will update the changes to the
% hardware.
ustcaddaObj = ustcadda_v1.GetInstance();
%%
dcSrcInterface =  ustc_dc_v1(1:32);
dcSrcObj = dcSource.GetInstance('myDCSource',dcSrcInterface);
%%
dcChnl1 = dcSrcObj.GetChnl(29);
dcChnl2 = dcSrcObj.GetChnl(30);
dcChnl3 = dcSrcObj.GetChnl(31);
dcChnl4 = dcSrcObj.GetChnl(32);
%%
dcChnl1.dcval = 0;
dcChnl2.dcval = 0;
dcChnl3.dcval = 0;
dcChnl4.dcval = 0;
%%
% daInterface = ustc_da_v1([3,4,5,6,7,8,9,10,11,12]);
daInterface = ustc_da_v1([1,2]);
awgObj = awg.GetInstance('myAWG',daInterface);
%%
import sqc.wv.*
T = @qes.waveform.fcns.Show;
F = @(x)qes.waveform.fcns.Show(x,[],true);
%%
g = gaussian(50);
g.amp = 3e4;
g.df = 0.1;
g.phase = pi/2;
%%
T(g);
F(g);
%%
g.awg = awgObj;
g.awgchnl = [1,2];
%%
g.awg.SetTrigOutDelay(1,0);
g.output_delay = [0,0];
g.SendWave();
g.Run(2e4);