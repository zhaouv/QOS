function varargout = zDelay(varargin)
% measures the syncronization of Z pulse
% 
% <_o_> = zDelay('qubit',_c&o_,'zAmp',[_f_],'zLn',<_i_>,'zDelay',[_i_],...
%       'notes',<_c_>,'gui',<_b_>,'save',<_b_>)
% _f_: float
% _i_: integer
% _c_: char or char string
% _b_: boolean
% _o_: object
% a&b: default type is a, but type b is also acceptable
% []: can be an array, scalar also acceptable
% {}: must be a cell array
% <>: optional, for input arguments, assume the default value if not specified
% arguments order not important as long as they form correct pairs.

% Yulin Wu, 2017/5/10


fcn_name = 'data_taking.public.xmon.zDelay'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'zLn',[],'r_avg',[],'gui',false,'notes','','save',true});
q = data_taking.public.util.getQubits(args,{'qubit'});

if ~isempty(args.r_avg) 
    q.r_avg=args.r_avg;
end
if isempty(args.zLn) 
    args.zLn=q.g_XY_ln;
end

X = gate.X(q);
Z = op.zBias4Spectrum(q);
Z.ln = args.zLn;
Z.amp = args.zAmp;
padLn11 = ceil(-min(X.length/2 - Z.length/2 + min(args.zDelay),0));
padLn12 = ceil(max(max(X.length/2 + Z.length/2 + max(args.zDelay),X.length)-X.length,0));
I1 = gate.I(q);
I1.ln = padLn11;
I2 = copy(I1);
I2.ln = padLn12;
XY = I2*X*I1;
I3 = copy(I1);
function procFactory(delay)
    I3.ln = ceil(X.length/2 + padLn11 - Z.length/2 + delay);
	proc = XY.*(I3*Z);
    proc.Run();
end
R = measure.resonatorReadout_ss(q);
R.state = 2;
R.delay = XY.length;

y = expParam(@procFactory);
y.name = [q.name,' z Pulse delay(da sampling points)'];

s2 = sweep(y);
s2.vals = {args.zDelay};
e = experiment();
e.sweeps = s2;
e.measurements = R;
e.name = 'Z Pulse Delay';
e.datafileprefix = sprintf('%s_zDelay', q.name);

if ~args.gui
    e.showctrlpanel = false;
    e.plotdata = false;
end
if ~args.save
    e.savedata = false;
end
e.notes = args.notes;
e.addSettings({'fcn','args'},{fcn_name,args});
e.Run();
varargout{1} = e;
end