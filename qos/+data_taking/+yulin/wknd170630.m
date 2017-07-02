% auto callibration q7
tuneup.iq2prob_01('qubit','q7','numSamples',1e4,'gui',true,'save','askMe');
%%
tuneup.optReadoutFreq('qubit','q7','gui',true,'save','askMe');
%%
% spectroscopy1_zpa('qubit','q7','gui',true);
% tuneup.correctf01bySpc('qubit','q7','gui',true,'save','askMe');
tuneup.correctf01byRamsey('qubit','q7','gui',true,'save','askMe');
%%
tuneup.xyGateAmpTuner('qubit','q7','gateTyp','X/2','AE',true,'gui',true,'save','askMe');


%%
% auto callibration q8
tuneup.iq2prob_01('qubit','q8','numSamples',1e4,'gui',true,'save','askMe');
%%
tuneup.optReadoutFreq('qubit','q8','gui',true,'save','askMe');
%%
% spectroscopy1_zpa('qubit','q8','gui',true);
% tuneup.correctf01bySpc('qubit','q8','gui',true,'save','askMe');
tuneup.correctf01byRamsey('qubit','q8','gui',true,'save','askMe');
%%
tuneup.xyGateAmpTuner('qubit','q8','gateTyp','X','AE',true,'gui',true,'save','askMe');


%%
q = 'q7';
XYGate ={'X', 'Y', 'X/2', 'Y/2', '-X/2', '-Y/2','X/4', 'Y/4', '-X/4', '-Y/4'};
for ii = 1:numel(XYGate)
    tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{ii},'AE',true,'gui',true,'save',true);
end

q = 'q8';
XYGate ={'X', 'Y', 'X/2', 'Y/2', '-X/2', '-Y/2','X/4', 'Y/4', '-X/4', '-Y/4'};
for ii = 1:numel(XYGate)
    tuneup.xyGateAmpTuner('qubit',q,'gateTyp',XYGate{ii},'AE',true,'gui',true,'save',true);
end
%%
q = 'q7';
setQSettings('r_avg',500, q);
setQSettings('spc_driveAmp',10000, q);
setQSettings('spc_sbFreq',500e8, q);
q7zAmp2f01 = @(x) - 0.46539*x.^2 + 2709.5*x + 5.222e+09-120e6;
spectroscopy1_zpa_bndSwp('qubit',q,...
       'swpBandCenterFcn',q8zAmp2f01,'swpBandWdth',70e6,...
       'biasAmp',[-32500:250:32500],'driveFreq',[4.37e9:0.1e6:4.77e9],...
       'gui',true,'save',true);