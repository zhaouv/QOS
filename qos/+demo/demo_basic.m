%% waveform
import qes.*
import qes.waveform.*
import sqc.wv.*
%%
T = @qes.waveform.fcns.Show;
F = @(x)qes.waveform.fcns.Show(x,[],true);

g = gaussian(50);
g.df = 0.1;
g.phase = pi/2;

t = 0:50;
plot(t,g(t));
f = -0.1:0.002:0.3;
plot(f,abs(g(f,true)));

T(g);
F(g);

s = rect(20);
s.t0 = 65;

a = g+s;
T(a);
F(a);

b = 1.5*g^3-0.7*s;
T(b);
F(b);

s.overshoot = 0.3;
s.overshoot_w = 1;

v = spacer(3);
q = [g, v, 2*a^10, v{10}, b];
T(q);
F(q);
%% util
notifier = util.pushover;
notifier.apptoken = 'a5imVrScaToxuJYNq3AqVPaccDYZ5J'; % this is code for app 'TritonQ02XZhu1', create your own apptoken at https://pushover.net, it is free
notifier.receiver = 'g7hn3DkeykYBPca7JjYbGSQez1jY3h'; % this is code for 'Group TritonQ02XZhu1', create your own receiver group and add deveices at https://pushover.net, it is free
notifier.title = 'A Test';
notifier.message = 'Hi there, ''pushover'' is now working.'; % check doc for more setting options
notifier.Push; % now watch your device

%% app
scripts.public.DV % no settings needed
%% any qHandle object can be converted to a struct and back,
% ToStruct/ToObject not updated to the new verison, may not work in the new verison
s = qHandle.ToStruct(MWSource1);
delete(MWSource1); % now the hardware object MWSource1 is deleted
MWSource1 = qHandle.ToObject(s); % now you have the hardware object MWSource1 again