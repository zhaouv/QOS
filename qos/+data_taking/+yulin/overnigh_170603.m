bias = -3e4:2e3:3e4;
qubitInd = [1,8,10,4,3,5,6];
f01_est = [3.9, 4.8, 5.85, 7.40, 6.05, 4.95, 6.0]*1e9;

for ii = 1:numel(qubitInd)
    freq = f01_est(ii)-300e6:0.3e6:f01_est(ii)+200e6;
    spectroscopy1_zpa_s21('qubit',qNames{qubitInd(ii)},...
           'biasAmp',bias,'driveFreq',freq,...
           'gui',true,'save',true);
end