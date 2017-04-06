function saveJson(fullfilename,fields,value,formatedArray)

% zhaouv https://zhaouv.github.io/

% type limit:
% : must be after field with no \n  

% format:
% array p*q*..=n num->[1*n num]
% formated -> []
% cell(p*q*..=n string)->[1*n string]
%

if ~qes.util.endsWith(fullfilename,'.key')
    fullfilename = [fullfilename,'.key'];
end
if nargin == 3
    formatedArray = false;
end
if ~formatedArray
    if ischar(value)
		if ~isempty(value) && value(1)=='['
			value=['a' value];
		else 
			value=['s"' value '"'];
		end
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
    elseif iscell(value)
        str='a[';
            for i=1:numel(value)
                if ~ischar(value{i}) && ~isnumeric(value{i})
                    error('not string or numeric in cell')
                end
                if isnumeric(value{i})
                    value{i} = qes.util.num2strCompact(value{i});
                else
                    value{i}=['"' value{i} '"'];
                end
                str=[str  value{i} ','];
            end
            value=[str(1:end-1) ']']; 
	else
        error('type error');
    end
else
    value=['a[' value ']'];
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