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
% %% sync test, and use the mimimum oscillascope vertical range to check zero offset
% ustcaddaObj.runReps = 1e4;
% ustcaddaObj.SendWave(25,[32768*ones(1,200),33768*ones(1,200)]+-1520); %
% ustcaddaObj.SendWave(26,[32768*ones(1,200),33768*ones(1,200)]+-1530); %
% ustcaddaObj.SendWave(27,[32768*ones(1,200),33768*ones(1,200)]+850); % 
% ustcaddaObj.SendWave(28,[32768*ones(1,200),33768*ones(1,200)]+370); %
% ustcaddaObj.Run(false);
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