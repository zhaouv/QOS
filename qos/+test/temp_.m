g3 = sqc.wv.gaussian(80);
dt = 0.5;
padTime = 1000;
w = 0;

numpts = 2^round(ceil(log2((g3.length+2*padTime)/dt)));
t = linspace(g3.t0-padTime, g3.t0+g3.length+padTime, numpts);
dt = t(2)-t(1);
samples = g3(t);

freqs =(-numpts/2:numpts/2-1)/(dt*numpts);
sampleSpectrum = fft(samples);
sampleSpectrum = dt*fftshift(sampleSpectrum).*exp(-1j*2*pi*freqs*padTime);

s = g3(freqs,true);

figure();plot(freqs, real(sampleSpectrum), freqs, real(s));

% figure();plot(freqs, imag(sampleSpectrum), freqs, imag(s));