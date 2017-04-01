function saveJson(fullfilename,fields,value)

% zhaouv https://zhaouv.github.io/

% not support cell now

% type limit:
% array must be 1*n or n*1
% there's only one { in a row
% there's only one } in a row
% in last layer there must be some char after : before \n
if ischar(value)
    value=['s"' value '"'];
elseif isnumeric(value)
    if numel(value)==1
        value=['n' num2str(value)];
    else
        str='a[';
        for i=1:numel(value)
            str=[str num2str(value(i)) ','];
        end
        value=[str(1:end-1) ']']; 
    end
else
    error('type error');
end
%mod = py.importlib.import_module('python.saveJson');  
mod = py.importlib.import_module('+qes.+util.saveJson');  
py.importlib.reload(mod);    
result=cell(mod.func1(fullfilename,fields,value));

if result{1}== 1
    error('type error');
end
%if result{1}== 2
%    error('not a last layer');
%end
%if result{1}== 3
%    error('not in one row');
%end
if result{1}== 4
    error('index error');
end
if result{1}== 5
    error('not found');
end


end