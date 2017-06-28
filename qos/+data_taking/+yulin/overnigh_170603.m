bias = 0:5e3:3e4;
% qubitInd = [1,8,10,4,3,5,6];
% f01_est = [3.9, 4.8, 5.85, 7.40, 6.05, 4.95, 6.0]*1e9;

qubitInd = [7,8,10,4,3,5,6];
f01_est = [6.5, 4.8, 5.85, 7.40, 6.05, 4.95, 6.0]*1e9;

for ii = 2:numel(qubitInd)
    freq = min(2e9,f01_est(ii)-4000e6):0.3e6:max(f01_est(ii)+2000e6,8e9);
    spectroscopy1_zpa_s21('qubit',qNames{qubitInd(ii)},...
           'biasAmp',0,'driveFreq',freq,...
           'gui',true,'save',true);
end
