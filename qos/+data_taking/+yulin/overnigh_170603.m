bias = 0:5e3:3e4;
qubitInd = [1,8,10,4,3,5,6];
f01_est = [3.9, 4.8, 5.85, 7.40, 6.05, 4.95, 6.0]*1e9;

for ii = 1:numel(qubitInd)
    freq = f01_est(ii)-1000e6:0.5e6:f01_est(ii)+1000e6;
    spectroscopy1_zpa_s21('qubit',qNames{qubitInd(ii)},...
           'biasAmp',bias,'driveFreq',freq,...
           'gui',true,'save',true);
       
    spectroscopy1_zdc('qubit',qNames{qubitInd(ii)},'dataTyp','S21',...
       'biasAmp',0:500:2500,'driveFreq',freq,...
       'gui',true,'save',true);
end
