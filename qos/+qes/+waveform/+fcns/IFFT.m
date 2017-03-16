function v = IFFT(obj,f)


% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

%             padln = 2*obj.length;

    error('not implemented');

    padln = 0;
    t = obj.t0-padln:obj.t0+obj.length - 1+padln;
    tv = obj.TimeFcn(t);
    NFFT = 2^nextpow2(numel(t));
    vi = fft(tv,NFFT);
    v = exp(-1j*2*pi*f*obj.t0).*interp1(linspace(0,1,NFFT),vi,f);
end