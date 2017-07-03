% validate waveform phase
g1 = sqc.wv.gaussian(300);
g2 = sqc.wv.gaussian(600);

g1.df = 0.05;
g2.df = 0.05;

g = [g1,g2];
gs = [g,g];

dc = qes.waveform.dc(1e3);
dc.dcval = 1;
dc.df = 0.05;

t = 0:0.25:2000;
figure();plot(t,dc(t),t,g(t));
figure();plot(t,dc(t),t,gs(t));

%%
f = -5:0.01:5;
figure();plot(f,real(g3(f,true)));
%%
g3 = sqc.wv.gaussian0(10);
t = -10:0.1:10;
y = g3(t);
figure();plot(t,real(y),t,imag(y));
%%
g3 = sqc.wv.gaussian0(10);
t = -100:0.1:100;
y = g3(t);
figure();plot(t,y);

yf = fft(y);
% figure();plot(t,ifft(yf),'-d');
% dt = t(end)-t(1);
% ns = numel(t);
% df = 1/dt;
f = (0:numel(t)-1)-numel(t)/2;
figure;plot(f,real(fftshift(yf)),'-d',f,imag(fftshift(yf)),'-+');
% figure;plot((0:numel(t)-1)-numel(t)/2,imag(fftshift(yf)),'-d');
% figure();plot(fftshift(real(yf)),'-d');
%%
g3 = sqc.wv.gaussian(10);
t = -10:0.5:10;
y = g3(t);
yf = fft(y);
figure;plot((0:numel(t)-1)-numel(t)/2,real(fftshift(yf)),'-d');
yp = [zeros(1,10),y,zeros(1,10)];
yf = fft(yp);
hold on;plot((0:numel(yp)-1)-numel(yp)/2,real(fftshift(yf)),'-+');
%%
g3 = sqc.wv.gaussian(30);
dt = 0.5;
padTime = 1000;
w = 0;

numpts = 2^round(ceil(log2((g3.length+2*padTime)/dt)));
t = linspace(g3.t0-padTime, g3.t0+g3.length+padTime, numpts);
dt = t(1)-t(0);
samples = g3(t);

freqs =(-numpts/2:numpts/2-1)/(dt*numpts);
sampleSpectrum = np.fft.fft(samples);
sampleSpectrum = dt*np.fft.fftshift(sampleSpectrum);

s = g3(freqs,true);

figure();plot(freqs, real(sampleSpectrum), freqs, real(s));

%% derivative waveform
df = 0.05;

g3 = sqc.wv.gaussian(100);
t = 0:100;
figure();plot(t, g3(t));
g3d = qes.waveform.fcns.Deriv(g3);
hold on;plot(t, 5*g3d(t));
g3d.df = df;
hold on;plot(t, 5*g3d(t));
g3.df = df;
hold on;plot(t, g3(t));



