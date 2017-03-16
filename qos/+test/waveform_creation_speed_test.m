%% new version, orginize all files in packages
% Elapsed time is 2.3 seconds. 230us per waveform
tic; 
for ii = 1:1e4
g = sqc.wv.gaussian(40);
end
toc
%% old version
% Elapsed time is 8.429968 seconds. 840us per waveform
tic; 
for ii = 1:1e4
g = Wv_Gaussian(40);
end
toc