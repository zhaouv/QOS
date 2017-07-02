function [A,B,C,D,freq,td,varargout] = sinDecayFit(t,P,A0,B0,C0,D0,freq0,td0)
% SinDecayFit fits curve P = P(t) with a Sinusoidal Decay function:
% P = A +B*(exp(-t/td)*(sin(2*pi*freq*t+D)+C));
%
% varargout{1}: ci, 6 by 2 matrix, ci(5,1) is the lower bound of 'freq',
% ci(6,2) is the upper bound of 'td',...
%
% Yulin Wu, SC5,IoP,CAS. mail4ywu@gmail.com
% $Revision: 1.1 $  $Date: 2012/10/18 $

Coefficients(1) = A0;
Coefficients(2) = B0;
Coefficients(3) = C0;
Coefficients(4) = D0;
Coefficients(5) = freq0;
Coefficients(6) = td0;
for ii = 1:3
    [Coefficients,~,residual,~,~,~,J] = lsqcurvefit(@SinusoidalDecay,Coefficients,t,P);
end
A = Coefficients(1);
B = Coefficients(2);
C =  Coefficients(3);
D = Coefficients(4);
freq = Coefficients(5);
td = Coefficients(6);
if nargout > 6
    varargout{1} = nlparci(Coefficients,residual,'jacobian',J);
end


function [P]=SinusoidalDecay(Coefficients,t)
% Sinusoidal Decay
% Parameter estimation:
% A: value of P at large x: P(end) or mean(P(end-##,end))
% B: max(P) - min(P)
% C: A - (max(P) + min(P))/2
% D: 0
% freq: use fft to detect
% td: ...
%
% Yulin Wu, SC5,IoP,CAS. wuyulin@ssc.iphy.ac.cn/mail4ywu@gmail.com
% $Revision: 1.0 $  $Date: 2012/03/28 $

A = Coefficients(1);
B = Coefficients(2);
C = Coefficients(3);
D = Coefficients(4);
freq = Coefficients(5);
td = Coefficients(6);
P = A +B*(exp(-t/td).*(sin(2*pi*freq*t+D)+C));