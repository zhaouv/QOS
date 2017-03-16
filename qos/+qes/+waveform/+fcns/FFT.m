function v = FFT(obj,f)
% for waveforms whos frequency function dose not have a analytical form,
% use FFT to calculate the frequency values numerically from time domain
% function.

% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    padln = round(0.5*obj.length);
    t = linspace(obj.t0-padln,obj.t0+obj.length - 1+padln,20*(obj.length+2*padln));
    tv = obj(t);
    NFFT = 2^nextpow2(numel(t));
    vi = fftshift(fft(tv,NFFT));
    v = exp(-1j*2*pi*f*obj.t0).*interp1(linspace(-0.5,0.5,NFFT),vi,f);
end