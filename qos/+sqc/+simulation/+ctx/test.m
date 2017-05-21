    Ej0 = 6/0.4;
    Ec0 = 4*Ej0/50;
    x = linspace(0,pi/2,30);
    EL = sqc.simulation.ctx.XMonELModulation(Ej0,Ec0,x);
    EL = [flipud(EL);EL];
%     figure();
%     plot([fliplr(-x),x],EL);
    figure();
    plot([fliplr(-x),x],diff(EL,1,2));
    legend({'f01','f12'})