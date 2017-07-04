function zpa = detune2zpa(q,detune)
% 

% Copyright 2017 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    p = q.zpls_amp2f01;
    p(end) = p(end) - q.f01;
    r = roots(p);
    r0 = sort(r(isreal(r)));
    if isempty(r) %
        throw(MException('QOS_detune2zpa:illegalzplsamp2f01',...
            sprintf('zpls_amp2f01 setting for qubit %s has no root for f01 %0.2f MHz.',...
            q.name, f01)));
    end
    [~,idx] = min(abs(r));
    r0 = r0(idx);
    
    p = q.zpls_amp2f01;
    p(end) = p(end) - q.f01 - detune;
    r = roots(p);
    r = sort(r(isreal(r)));
    if isempty(r) %
        throw(MException('QOS_detune2zpa:illegalzplsamp2f01',...
            sprintf('zpls_amp2f01 setting for qubit %s has no root for f01+detune %0.2f MHz.',...
            q.name, f01+detune)));
    end
    r = r(idx);
    
    zpa = r - r0;

end