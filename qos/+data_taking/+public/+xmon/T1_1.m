function varargout = T1_1(varargin)
% T1_1: T1
% bias, drive and readout all one qubit
%
% <_o_> = T1_1('qubit',_c&o_,'biasAmp',<[_f_]>,'biasDelay',<_i_>,...
%       'backgroundWithZBias',<_b_>,...
%       'time',[_i_],'r_avg',<_i_>,...
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

% Yulin Wu, 2016/12/27

import qes.*
import data_taking.public.xmon.T1_111
args = util.processArgs(varargin,{'r_avg',[],'biasAmp',0,'biasDelay',0,'backgroundWithZBias',true,...
    'gui',false,'notes','','save',true,'fit',false});
varargout{1} = T1_111('biasQubit',args.qubit,'biasAmp',args.biasAmp,'biasDelay',args.biasDelay,...
    'backgroundWithZBias',args.backgroundWithZBias,'driveQubit',args.qubit,...
    'readoutQubit',args.qubit,'time',args.time,'r_avg',args.r_avg,'notes',args.notes,'gui',args.gui,'save',args.save);

if args.fit
    data=cell2mat(varargout{1,1}.data{1,1}');
    for ii=1:size(data,2)/2
        z(ii,:)=(data(:,2*ii-1)-data(:,2*ii))';
    end
    bias=args.biasAmp;
    time=args.time;
    if length(bias)==1
        A0 = z(end);
        B0 = z(1)-z(end);
        td0 = time(end)/2;
        
        [A_,B_,td_,temp] = toolbox.data_tool.fitting.expDecayFit(time,z,A0,B0,td0);
        
        if args.gui
            tf = linspace(time(1),time(end),100);
            zf = toolbox.data_tool.fitting.expDecay([A_,B_,td_],tf);
            hf=figure;
            plot(gca, time/2000,z);
            hold on;
            plot(gca,tf/2000,zf,'r');
            plot(gca,temp(3,:)/2000,[zf(end),zf(end)],'g-+');
            plot(gca,td_/2000,zf(end),'r+');
            hold off;
            ylabel('Time (us)');
            drawnow;
            legend('Raw','Fit','Errorbar','FitValue')
            if td_<time(end)
                title(['Fit T_1 = ' num2str(td_/2000,'%.2f') ' us'])
            else
                title('Fit failed!')
            end
        end
    else
        for ii = 1:length(bias)
            A0 = z(ii,end);
            B0 = z(ii,1)-z(ii,end);
            td0 = time(end)/4;
            
            [A_,B_,td_,temp] = toolbox.data_tool.fitting.expDecayFit(time,z(ii,:),A0,B0,td0);
            
            wci(ii,:) = temp(3,:); %
            A(ii) = A_;
            B(ii) = B_;
            td(ii) = td_;
            zf = toolbox.data_tool.fitting.expDecay([A_,B_,td_],tf);
        end
        
        if args.gui
            time = time/2e3;
            td = td/2e3;
            wci = wci/2e3;
            
            hf=figure();
            imagesc(bias,time,z');
            hold on;
            errorbar(bias,td,td-wci(:,1)',wci(:,2)'-td,'ro-','MarkerSize',5,'MarkerFaceColor',[1,1,1]);
            set(gca,'YDir','normal');
            xlabel('Z Bias');
            ylabel('Time (us)');
            if mean(td)<time(end)
                title(['Fit average T_1 = ' num2str(mean(td),'%.2f') ' us'])
            else
                title('Fit failed!')
            end
            colorbar
        end
    end
    if args.gui && args.save
        QS = qes.qSettings.GetInstance();
        dataSvName = fullfile(QS.loadSSettings('data_path'),...
            [args.qubit '_T1_fit_',datestr(now,'yymmddTHHMMSS'),...
            num2str(ceil(99*rand(1,1)),'%0.0f'),'_.fig']);
        saveas(hf,dataSvName);
    end
end

end