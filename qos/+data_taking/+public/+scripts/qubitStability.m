function qubitStability( varargin )

import qes.*
import data_taking.public.xmon.spectroscopy1_zpa_s21

args = util.processArgs(varargin,{'biasAmp',0,'driveFreq',[],'r_avg',[],'gui',false,'notes','','save',false});

data=NaN(args.Repeat,length(args.driveFreq));
for ii=1:args.Repeat
    data0=spectroscopy1_zpa_s21('qubit',args.qubit,...
        'biasAmp',args.biasAmp,'driveFreq',args.driveFreq,...
        'r_avg',args.r_avg,'notes',args.notes,'gui',args.gui,'save',args.save);
    data(ii,:)=cell2mat(data0.data{1,1});
    figure(44);
    imagesc(1:args.Repeat,args.driveFreq,data')
    xlabel('Repeat times')
    ylabel('Freq (Hz)')
end


end

