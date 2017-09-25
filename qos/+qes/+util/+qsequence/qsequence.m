function result = qsequence(inputstr)
mod = py.importlib.import_module('+qes.+util.+qsequence._main');  
%py.importlib.reload(mod);    
result=mod.mainfunc(inputstr);
result=jsondecode(char(result));
end
