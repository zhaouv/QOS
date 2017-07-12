qubits = {'q7','q8'};
setQSettings('r_avg',2000);
for ii = 1:numel(qubits)
    q = qubits{ii};
    tuneup.correctf01byRamsey('qubit',q,'gui',true,'save',true);
    tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X','AE',true,'gui',true,'save',true);
    tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
    XYGate ={'X', 'Y', 'X/2', 'Y/2', '-X/2', '-Y/2','X/4', 'Y/4', '-X/4', '-Y/4'};
    for jj = 1:numel(XYGate)
        tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{jj},'AE',true,'gui',true,'save',true);
    end
end
TomoDataCZ3 = twoQProcessTomo('qubit1','q7','qubit2','q8',...
'process','CZ','reps',5,...
'notes','','gui',true,'save',true);
str = ['D:\data\20170627\pTomoCZ_',datestr(now,'yymmddTHHMMSS_')];
save([str,'.mat'],'TomoDataCZ3');


numGates = 1:2:60;
setQSettings('r_avg',2000);
qubits = {'q7','q8'};
for ii = 1:numel(qubits)
    q = qubits{ii};
    tuneup.correctf01byRamsey('qubit',q,'gui',true,'save',true);
    tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X','AE',true,'gui',true,'save',true);
    tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);

    % XYGate ={'X', 'Y', 'X/2', 'Y/2', '-X/2', '-Y/2','X/4', 'Y/4', '-X/4', '-Y/4'};
    XYGate ={'X', 'Y', 'X/2', 'Y/2', '-X/2', '-Y/2'};
    for jj = 1:numel(XYGate)
        setQSettings('r_avg',2000);
        tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{jj},'AE',true,'gui',true,'save',true);
        setQSettings('r_avg',250);
        randBenchMarking('qubit',q,...
            'process',XYGate{jj},'numGates',numGates,'numReps',50,...
            'gui',true,'save',true);
    end
    
end