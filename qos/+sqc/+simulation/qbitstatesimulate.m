function result=qbitstatesimulate(celljsonorfile)
% zhaouv https://zhaouv.github.io/

warning('替换为 qutipenv=localconfig.pythonconfig.qutipenv;统一配置?否则若放入qos中会容易在移植时出bug')
qutipenv='C:\Users\ZhaoUV\AppData\Local\conda\conda\envs\qutip-env\python.exe';
%[~,qutipenv,~]=pyversion;%如果默认的python环境有qutip,使用此句即可

%{
%example1
jsonstr=['[["h","cz1","rx90"],',...
    '["h","cz3","cz5"],',...
    '["h","cz2","cz6"],',...
    '["h","cz4","ry-90"]]'];
result=sqc.simulation.qbitstatesimulate(jsonstr)

%>>result = 
%>>
%>>  包含以下字段的 struct:
%>>
%>>    real: [16×1 double]
%>>    imag: [16×1 double]
%%

%example2
tempcell='[["","","ry90","cz1","rx-90","ry-90","","rx-90","cz1","","ry90","rx90"],["rx-90","ry90","rx90","cz2","","ry90","x","ry-90","cz2","rx-90","ry-90","rx90"]]';
tempcell=jsondecode(tempcell);
len=size(tempcell{1},1);
result=cell(len,1);
for index=1:size(tempcell{1},1)
    result{len+1-index}=sqc.simulation.qbitstatesimulate(tempcell);
    tempcell={{tempcell{1}{1:end-1}}';{tempcell{2}{1:end-1}}'};
end
result

%>>result =
%>>
%>>  12×1 cell 数组
%>>
%>>    [1×1 struct]
%>>    [1×1 struct]
%>>    [1×1 struct]
%>>    [1×1 struct]
%>>    [1×1 struct]
%>>    [1×1 struct]
%>>    [1×1 struct]
%>>    [1×1 struct]
%>>    [1×1 struct]
%>>    [1×1 struct]
%>>    [1×1 struct]
%>>    [1×1 struct]

%目前只支持cell和json不支持文件
%}

if ~nargin
    celljsonorfile='[["","","ry90","cz1","rx-90","ry-90","","rx-90","cz1","","ry90","rx90"],["rx-90","ry90","rx90","cz2","","ry90","x","ry-90","cz2","rx-90","ry-90","rx90"]]';
end

if iscell(celljsonorfile)
    stringorfile=tempcell2str(celljsonorfile);
else
    celljsonorfile=jsondecode(celljsonorfile);    
    stringorfile=tempcell2str(celljsonorfile);
end
%stringorfile=',,ry90,cz1,rx-90,ry-90,,rx-90,cz1,,ry90,rx90#rx-90,ry90,rx90,cz2,,ry90,x,ry-90,cz2,rx-90,ry-90,rx90';



mpath = mfilename('fullpath');
i=findstr(mpath,'\'); %#ok<FSTR>
mpath=mpath(1:i(end));

command=[qutipenv,' ',mpath,'qbitstatesimulate.py ',stringorfile];
[status, result]=system(command);
if ~(status==0)
    error(result)
end

result=jsondecode(result);

end

function str=tempcell2str(tempcell)
%tempcell=jsondecode('[["","","ry90","cz1","rx-90","ry-90","","rx-90","cz1","","ry90","rx90"],["rx-90","ry90","rx90","cz2","","ry90","x","ry-90","cz2","rx-90","ry-90","rx90"]]');
str='';
for line = tempcell'
    for onegate = line{1}'
        str=[str,onegate{1},','];
    end
    str=[str(1:end-1),'#'];
end
str=str(1:end-1);
end