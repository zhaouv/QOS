function [A,B,C,freq,varargout] = cosFit(t,P,A0,B0,C0,freq0)
% SinDecayFit fits curve P = P(t) with a Sinusoidal Decay function:
% P = A*(cos(2*pi*freq*t+B)+C));
%
% varargout{1}: ci, 4 by 2 matrix, ci(4,1) is the lower bound of 'freq'
%
% Yulin Wu, SC5,IoP,CAS. mail4ywu@gmail.com
% $Revision: 1.1 $  $Date: 2012/10/18 $

Coefficients(1) = A0;
Coefficients(2) = B0;
Coefficients(3) = C0;
Coefficients(4) = freq0;
for ii = 1:3
    [Coefficients,~,residual,~,~,~,J] = lsqcurvefit(@cos_,Coefficients,t,P);
end
A = Coefficients(1);
B =  Coefficients(2);
C = Coefficients(3);
freq = Coefficients(4);
if nargout > 4
    varargout{1} = nlparci(Coefficients,residual,'jacobian',J);
end


function [P]=cos_(Coefficients,t)

A = Coefficients(1);
B = Coefficients(2);
C = Coefficients(3);
freq = Coefficients(4);
P = A*(cos(2*pi*freq*t+B)+C);
