for kk = 1:10

qubits = {'q9_1'};
for ii = 1:numel(qubits)
    q = qubits{ii};
    setQSettings('r_avg',2000,q);
    tuneup.correctf01byRamsey('qubit',q,'gui',true,'save',true);
    tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X','AE',false,'gui',true,'save',true);
    tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
    XYGate ={'X','X/2'};
    for jj = 1:numel(XYGate)
        tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{jj},'AE',true,'AENumPi',21,'gui',true,'save',true);
    end
end

setQSettings('r_avg',10000,'q9_1');

delayTime = [000:10:2e3];
zPulseRipple('qubit','q9_1',...
        'delayTime',delayTime,...
       'zAmp',0e3,'gui',true,'save',true);
   
   
delayTime = [000:10:2e3];
zPulseRipple('qubit','q9_1',...
        'delayTime',delayTime,...
       'zAmp',1e3,'gui',true,'save',true);
   
end

for kk = 1:10

qubits = {'q9_1'};
for ii = 1:numel(qubits)
    q = qubits{ii};
    setQSettings('r_avg',2000,q);
    tuneup.correctf01byRamsey('qubit',q,'gui',true,'save',true);
    tuneup.xyGateAmpTuner('qubit',q,'gateTyp','X','AE',false,'gui',true,'save',true);
    tuneup.iq2prob_01('qubit',q,'numSamples',1e4,'gui',true,'save',true);
    XYGate ={'X','X/2'};
    for jj = 1:numel(XYGate)
        tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{jj},'AE',true,'AENumPi',21,'gui',true,'save',true);
    end
end

setQSettings('r_avg',10000,'q9_1');

delayTime = [000:10:1e3];
zPulseRipple('qubit','q9_1',...
        'delayTime',delayTime,...
       'zAmp',0e3,'gui',true,'save',true);
   
   
delayTime = [000:10:1e3];
zPulseRipple('qubit','q9_1',...
        'delayTime',delayTime,...
       'zAmp',1e3,'gui',true,'save',true);
   
end