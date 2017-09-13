function varargout = s21_01_rAmp(varargin)
% resonator s21 of state |0> and state |1>
%
% <_o_> = s21_01('qubit',_c&o_,...
%       'freq',<_f_>,...
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

% Yulin Wu, 2017/1/13
% GM, 2017/6/12

fcn_name = 'data_taking.public.xmon.s21_01_rAmp'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

args = util.processArgs(varargin,{'freq',[],'gui',false,'notes','','save',true});
q = data_taking.public.util.getQubits(args,{'qubit'});

if isempty(args.freq)
    args.freq = q.r_freq;
end

X = gate.X(q);
R = measure.rReadout4S21_01(q);
R.delay = X.length;
R.name = '|IQ|';

x = expParam(R,'mw_src_frequency');
x.offset = q.r_fc - q.r_freq;
x.name = [q.name,' readout frequency'];
s1 = sweep(x);
s1.vals = args.freq;
y = expParam(R,'r_amp');
y.name = [q.name,' readout Amp'];
y.callbacks ={@(x_) X.Run()};
s2 = sweep(y);
s2.vals = args.rAmp;
e = experiment();
e.name = 'S21 - |0>,|1>';
e.sweeps = [s1,s2];
e.measurements = R;
e.datafileprefix = sprintf('%s', q.name);
e.showctrlpanel = false;
e.plotdata = false;
if args.save
    e.savedata = true;
end
e.Run();
e.data{1} = cell2mat(e.data{1});
if args.gui
    if numel(args.freq) == 1
        ax = axes('Parent',figure('NumberTitle','off','Name','QOS | s21 of |0>, |1> '));
        semilogx(ax, args.rAmp,abs(e.data{1,1}(1:2:end)));
        hold(ax,'on');
        semilogx(ax, args.rAmp, abs(e.data{1,1}(2:2:end)));
        yyaxis right
        semilogx(ax, args.rAmp, (abs(e.data{1,1}(2:2:end))-abs(e.data{1,1}(1:2:end)))./abs(e.data{1,1}(2:2:end)));
        legend(ax,{'|0>', '|1>','|1>-|0>'});
    elseif numel(args.freq) > 1 && numel(args.rAmp) > 1 
        ax = axes('Parent',figure('NumberTitle','off','Name','QOS | s21 of |0>, |1> '));
        surface(ax,args.rAmp,args.freq,abs(e.data{1,1}(:,2:2:end))-abs(e.data{1,1}(:,1:2:end)),'edgecolor','none')
        set(ax,'xscale','log')
        axis tight
    end
end
e.notes = args.notes;
e.addSettings({'fcn','args'},{fcn_name,args});
varargout{1} = e;
end