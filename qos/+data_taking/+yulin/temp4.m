gate = 'Z';
data = singleQProcessTomo('qubit','q2','reps',2,'state',gate);
chi = processTomoData2Rho(data);
h = figure();bar3(real(chi));
str = ['D:\data\20170517\tomo\procTomo_',datestr(now,'yymmddTHHMMSS_'),gate];
save([str,'.mat'],'data');
savefig(h,[str,'.fig']);
%%
state = '|0>-i|1>';
data = singleQStateTomo('qubit','q2','reps',2,'state',state);
rho = sqc.qfcns.stateTomoData2Rho(data);
h = figure();bar3(real(rho));%h = figure();bar3(imag(rho));
str = ['D:\data\20170517\tomo\stateTomo_',datestr(now,'yymmddTHHMMSS_'),'(0)-i(1)'];
save([str,'.mat'],'data');
savefig(h,[str,'.fig']);
%%
XYGate ={'X', 'Y', 'I','X/2', 'Y/2', '-X/2', '-Y/2'};
numGates = 1:1:20;
for ii = 1:numel(XYGate)
    [Pref,Pi] = randBenchMarking('qubit','q2',...
           'process',XYGate{ii},'numGates',numGates,'numReps',50,...
           'gui',true,'save',true);
end

tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X','AE',true,'gui',true,'save',true); 

tuneup.iq2prob_01('qubit',q,'numSamples',2e4,'gui',true,'save',true);

XYGate ={'X', 'Y', 'X/2', 'Y/2', '-X/2', '-Y/2','X/4', 'Y/4', '-X/4', '-Y/4'};
for ii = 1:numel(XYGate)
    try
    tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{ii},'AE',true,'gui',true,'save',true); 
    catch
    end
end

XYGate ={'X', 'Y', 'I','X/2', 'Y/2', '-X/2', '-Y/2'};
numGates = 1:1:30;
for ii = 1:numel(XYGate)
    [Pref,Pi] = randBenchMarking('qubit','q2',...
           'process',XYGate{ii},'numGates',numGates,'numReps',100,...
           'gui',true,'save',true);
end
%%