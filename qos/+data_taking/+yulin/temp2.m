import data_taking.public.util.*
import data_taking.public.xmon.*

T1_1('qubit','q2','biasAmp',[-3e4:500:3e4],'biasDelay',20,'time',[0:150:20e3],...
      'gui',true,'save',true);
  
q2Bias2F01 = @(x)- 1.497*x.^2 - 2.736e+04*x + 5.979e+09;
q2Bias2F01_ = @(x_)q2Bias2F01(0.97*x_-1900);

tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);

spectroscopy1_zpa_bndSwp('qubit','q2',...
       'swpBandCenterFcn',q2Bias2F01_,'swpBandWdth',100e6,...
       'biasAmp',[-3e4:500:3e4],'driveFreq',[4.8e9:0.25e6:6.15e9],...
       'gui',false,'save',true);