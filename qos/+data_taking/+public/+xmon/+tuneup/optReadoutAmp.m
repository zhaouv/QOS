function varargout = optReadoutAmp(varargin)

import qes.*
import data_taking.public.util.getQubits

args = util.processArgs(varargin,{'bnd',[1000,30000],'optnum',31,'gui',true,'save',true,'tunerf',false});
q = data_taking.public.util.getQubits(args,{'qubit'});
qubit = q.name;

    function tt=getMaxfid(r_amp)
        sqc.util.setQSettings('r_amp',round(10^r_amp), qubit);
        if args.tunerf
            data_taking.public.xmon.tuneup.optReadoutFreq('qubit',qubit,'gui',true,'save',true,'range',2);
        end
        [~,~,tt]=data_taking.public.xmon.tuneup.iq2prob_01('qubit',qubit,'numSamples',1e4,...
            'gui',true,'save',false);
    end

% options = optimset('PlotFcns',@optimplotfval,'TolX',0.02,'MaxIter',30);
% r_amp = fminbnd(@getMaxfid,args.bnd(1),args.bnd(2),options);

ramps=linspace(log10(args.bnd(1)),log10(args.bnd(2)),args.optnum);
h=figure;
for ii=1:length(ramps)
    
    tt(ii)=abs(getMaxfid(ramps(ii)));
    figure(h);plot(round(10.^ramps(1:ii)),tt,'-o');drawnow;
end

[~,lo]=max(tt);
r_amp=ramps(lo);

sqc.util.setQSettings('r_amp',round(10^r_amp), qubit);
if args.tunerf
    data_taking.public.xmon.tuneup.optReadoutFreq('qubit',qubit,'gui',true,'save',true);
end
data_taking.public.xmon.tuneup.iq2prob_01('qubit',qubit,'numSamples',1e4,...
    'gui',true,'save',true);
end


