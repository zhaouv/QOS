%% test mw source signalcore
import qes.*
import qes.hwdriver.sync.*
QS = qSettings.GetInstance('D:\settings');
%%
iobj = signalCore5511a();
%%
mwSrc = mwSource.GetInstance('mwSrc_sc5511a',iobj);
%%
mwChnl = mwSrc.getChnl(2);
mwChnl.frequency = 6.9;
mwChnl.power = -10;
mwChnl.on = true;