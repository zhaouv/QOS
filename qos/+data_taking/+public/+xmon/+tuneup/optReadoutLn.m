function varargout = optReadoutLn(varargin)

import qes.*
import data_taking.public.util.getQubits

args = util.processArgs(varargin,{'bnd',[6000,10000],'gui',true,'save',true});
q = data_taking.public.util.getQubits(args,{'qubit'});
qubit = q.name;
 
    function tt=getMaxfid(r_ln)
        sqc.util.setQSettings('r_ln',round(r_ln), qubit);
        [~,~,tt]=data_taking.public.xmon.tuneup.iq2prob_01('qubit',qubit,'numSamples',1e4,...
            'gui',true,'save',false);
%         tt=-tt;
    end

% options = optimset('PlotFcns',@optimplotfval,'TolX',0.02,'MaxIter',30);
% r_amp = fminbnd(@getMaxfid,args.bnd(1),args.bnd(2),options);

rlns=linspace(args.bnd(1),args.bnd(2),11);
h=figure;
for ii=1:length(rlns)
    
    tt(ii)=abs(getMaxfid(rlns(ii)));
    figure(h);plot(rlns(1:ii),tt,'-o');drawnow;
end

[~,lo]=max(tt);
r_ln=rlns(lo);

sqc.util.setQSettings('r_ln',round(r_ln), qubit);
data_taking.public.xmon.tuneup.iq2prob_01('qubit',qubit,'numSamples',1e4,...
            'gui',true,'save',true);
end


