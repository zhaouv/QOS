FluxQuantum = 2.067833636e-15;
PlanksConst = 6.626068E-34;
ee = 1.602176e-19;

% 0.280 uA -> junction resistance 1kOhm
KRI = 0.290e-6;

R = 6.0e3:0.025e3:7.5e3;
Ic = KRI./(R/1e3);
C = 70e-15:0.5e-15:90e-15;

f01 = NaN*ones(numel(R),numel(C));
ah = NaN*ones(numel(R),numel(C));

for ii = 1:numel(R)
    for jj = 1:numel(C)
        Ej = Ic(ii)*FluxQuantum/(2*pi)/PlanksConst/1e9;    % Unit: GHz.
        Ec = (2*ee)^2./(2*C(jj))/PlanksConst/1e9;  % Unit: GHz.
        f01_est = sqrt(8*Ej*Ec/4);
        EL = sqc.simulation.ctx.XMonELModulation(Ej,Ec,0);
        DEL = diff(EL);
        f01(ii,jj) = DEL(1);
        ah(ii,jj) = diff(DEL);
    end
end
[X,Y] = meshgrid(R/1e3,C/1e-15);

figure();
contour(X,Y,f01',15,'ShowText','on','LineWidth',2);
xlabel('Resistance(2 junctions, kOhm)','FontSize',12);
ylabel('Capacitance(fF)','FontSize',12);
title(sprintf('1kOhm junction -> Ic = %0.0fnA;  Z: f01 in GHz',KRI*1e9),'FontSize',12);
set(gca,'FontSize',12);
grid on;

% figure();
% h=pcolor(R/1e3,C/1e-15,f01');
% set(h,'EdgeColor', 'none');
% xlabel('Resistance(2 junctions, kOhm)');
% ylabel('Capacitance(fF)');
% title('Z: f01 in GHz');

figure();
contour(X,Y,ah'*1e3,15,'ShowText','on','LineWidth',2);
xlabel('Resistance(2 junctions, kOhm)','FontSize',12);
ylabel('Capacitance(fF)','FontSize',12);
title(sprintf('1kOhm junction -> Ic = %0.0fnA;   Z: f12-f01 in MHz',KRI*1e9),'FontSize',12);
set(gca,'FontSize',12);
grid on;

% figure();
% h=pcolor(R/1e3,C/1e-15,ah'*1e3);
% set(h,'EdgeColor', 'none');
% xlabel('Resistance(2 junctions, kOhm)');
% ylabel('Capacitance(fF)');
% title('Z: f12-f01 in MHz');
    