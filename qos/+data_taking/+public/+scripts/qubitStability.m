function varargout=qubitStability( varargin )

import qes.*
import data_taking.public.xmon.spectroscopy1_zpa

args = util.processArgs(varargin,{'biasAmp',0,'driveFreq',[],'r_avg',[],'gui',false,'notes','','save',false,'dataTyp','S21'});

data=NaN(args.Repeat,length(args.driveFreq));
for ii=1:args.Repeat
    data0=spectroscopy1_zpa('qubit',args.qubit,...
        'biasAmp',args.biasAmp,'driveFreq',args.driveFreq,...
        'r_avg',args.r_avg,'notes',args.notes,'gui',args.gui,'save',args.save,'dataTyp',args.dataTyp);
    data(ii,:)=data0.data{1,1};
    hf=figure(44);
    imagesc(1:args.Repeat,args.driveFreq,data')
    xlabel('Repeat times')
    ylabel('Freq (Hz)')
    colorbar
    drawnow;
end

QS = qes.qSettings.GetInstance();
dataSvName = fullfile(QS.loadSSettings('data_path'),...
    [args.qubit '_qubitStability_',datestr(now,'yymmddTHHMMSS'),...
    num2str(ceil(99*rand(1,1)),'%0.0f'),'_.fig']);
saveas(hf,dataSvName);

varargout{1}=data;

end

