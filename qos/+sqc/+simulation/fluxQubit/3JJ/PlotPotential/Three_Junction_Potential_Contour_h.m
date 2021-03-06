clear all;
r3=0;
a=0.55;
b=0.01;
k=0;
bias=pi;
r1=-1*pi:0.02:1*pi;
r2=r1;
figure;
for n=1:length(r2)
      U(n,:)=-((1+k)*cos(r1-r2(n)-r3)+(1-k)*cos(r1+r2(n)+r3)+a*cos(2*r2(n)+bias-r3/a))+(1+2*a)^2*(1-k^2)/(2*a*b*(1+2*a-k^2))*r3.^2;
end
mesh(r1,r2,U);
xlabel('\gamma_a');
ylabel('\gamma_s');
zlabel('Energy (E_J)');
title('Three-junction flux qubit Potential   ( \alpha = 0.8  \beta = 0.01  \kappa = 0  \phi_e_x = \pi )');
