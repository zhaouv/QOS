%%
% ustcadda tester
%%
import qes.*
import qes.hwdriver.sync.*
QS = qSettings.GetInstance('D:\settings');
%% not needed unless you want to reconfigure the DACs and ADCs during the measurement
% a DACs and ADCs reconfiguration is only needed when the hardware settings
% has beens changed, a reconfiguration will update the changes to the
% hardware.
ustcaddaObj = ustcadda_v1.GetInstance();
%% run all channels
ustcaddaObj.runReps = 3e4;
for ii = 1:40
    ustcaddaObj.SendWave(ii,[zeros(1,4000),65535*ones(1,4000)]);
end
ustcaddaObj.Run(false);
%% sync test, and use the mimimum oscillascope vertical range to check zero offset
ustcaddaObj.runReps = 1e4;
ustcaddaObj.SendWave(37,[32768*ones(1,200),33768*ones(1,200)]+0); % 620
ustcaddaObj.SendWave(38,[32768*ones(1,200),33768*ones(1,200)]+0); % 750
ustcaddaObj.SendWave(39,[32768*ones(1,200),33768*ones(1,200)]+0); % -230
ustcaddaObj.SendWave(40,[32768*ones(1,200),33768*ones(1,200)]+0); % -400
ustcaddaObj.Run(false);
%% sin wave
for ii = 1:40
    ustcaddaObj.SendWave(ii,32768+32768*sin((1:8000)/1000*2*pi));
end
ustcaddaObj.Run(false);
%% test da -> ad
clc
wvLn = 4e3; % 2us
wvData = 32768+1000*ones(1,wvLn);
ustcaddaObj.runReps = 1000;
% ustcaddaObj.setDAChnlOutputDelay(1,100);
% ustcaddaObj.setDAChnlOutputDelay(2,100);
% ustcaddaObj.setDAChnlOutputDelay(3,100);
% ustcaddaObj.setDAChnlOutputDelay(4,100);
ustcaddaObj.SendWave(15,wvData); % 620
% ustcaddaObj.SendWave(2,wvData); % 750
% ustcaddaObj.SendWave(3,wvData); % 620
% ustcaddaObj.SendWave(4,wvData); % 750
tic
data = ustcaddaObj.Run(true);
toc
%%
ustcaddaObj.runReps = 10;
for ii = 0:50:8e3
    clc;
    disp(sprintf('waveform code: %d',ii));
    
    wvData = (32768+ii)*ones(1,100);
    
    ustcaddaObj.SendWave(15,wvData); 
    ustcaddaObj.SendWave(21,wvData); 
    
    data = ustcaddaObj.Run(true);
end
%%
N = 10;
runReps = ceil(logspace(1,4,30));
wvLn = 4e3; % 2us
T = nan*ones(1,N);
for ii = 1:N
    tic
    ustcaddaObj.runReps = runReps(ii);
    ustcaddaObj.SendWave(3,65535*ones(1,wvLn)); % 620
    ustcaddaObj.SendWave(4,65535*ones(1,wvLn)); % 750
    data = ustcaddaObj.Run(true);
    T(ii) = toc;
end
figure();
semilogx(runReps,T-runReps/5e3);
xlabel('Number of samples');
ylabel('Time taken(s)');
title('Repetition 5kHz,waveform length 4000pts(da), 2000pts(ad).');