import data_taking.public.util.*
import data_taking.public.xmon.*

for ii=1:9
    setZDC(qNames{ii},0);
end

    

ii = 8;
spectroscopy111_zdc('driveQubit',qNames{ii},'biasQubit',qNames{ii},'readoutQubit',qNames{ii},...
'biasAmp',[-1.5e4:500:1.5e4],'driveFreq',[4.3e9:0.5e6:4.8e9],...
'dataTyp','S21','gui',true,'save',true);
setZDC(qNames{ii},0);
ii = 9;
spectroscopy111_zdc('driveQubit',qNames{ii},'biasQubit',qNames{ii},'readoutQubit',qNames{ii},...
'biasAmp',[-1.5e4:500:1.5e4],'driveFreq',[4.6e9:0.5e6:5.3e9],...
'dataTyp','S21','gui',true,'save',true);
setZDC(qNames{ii},0);
ii = 3;
spectroscopy111_zdc('driveQubit',qNames{ii},'biasQubit',qNames{ii},'readoutQubit',qNames{ii},...
'biasAmp',[-1e4:500:1e4],'driveFreq',[5.2e9:0.5e6:5.3e9],...
'dataTyp','S21','gui',true,'save',true);
setZDC(qNames{ii},0);