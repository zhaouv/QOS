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