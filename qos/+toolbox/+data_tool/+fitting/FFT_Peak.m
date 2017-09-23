function ft=FFT_Peak(t,data)
t_step=t(2)-t(1);
ff=1/t_step;
L=length(t);
NFFT=2^nextpow2(L); 
Y=fft(data-mean(data),NFFT)/L;
f=ff/2*linspace(0,1,NFFT/2+1);
% figure(100);plot(f,2*abs(Y(1:NFFT/2+1)));

[~,num]=max(abs(Y(1:NFFT/2+1)));
ft=f(num);
end