%%
g3 = sqc.wv.gaussian(30);
dt = 0.5;
padTime = 1000;
w = 0;
% calculate frequency domain sample by fft on time domain samples
numpts = 2^round(ceil(log2((g3.length+2*padTime)/dt)));
t = linspace(g3.t0-padTime, g3.t0+g3.length+padTime, numpts);
dt = t(2)-t(1);
samples = g3(t);
freqs =(-numpts/2:numpts/2-1)/(dt*numpts);
s_fft = fft(samples);
s_fft = dt*fftshift(s_fft).*exp(1j*2*pi*freqs*padTime);
% calculate frequency domain sample by freqFunc directly
s_direct = g3(freqs,true);
% check they are equal
figure();plot(freqs, real(s_fft), freqs, real(s_direct));
legend({'Re: fft off time domain samples','Re: freqFunc'});
figure();plot(freqs, imag(s_fft), freqs, imag(s_direct));
legend({'Im: fft off time domain samples','Im: freqFunc'});
%%
g3 = sqc.wv.gaussian(30);
n2p = 4;
numpts = 2^n2p;
% numpts = 2^round(ceil(log2(r*g3.length)));
t = linspace(g3.t0,g3.t0+g3.length,numpts);
dt = t(2) - t(1);
freqs = ifftshift(linspace(-numpts/2,numpts/2-1,numpts)/(dt*numpts));
samples = g3(freqs,true);
s_fft = ifft(samples)/dt;
s_direct = g3(t);
figure();plot(t, real(s_fft), t, real(s_direct));
legend({'Re: fft off freq domain samples','Re: timeFunc'});
% figure();plot(t, imag(s_fft), t, imag(s_direct));
% legend({'Im: fft off freq domain samples','Im: timeFunc'});

