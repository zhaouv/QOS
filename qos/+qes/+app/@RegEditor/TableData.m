function table_data = TableData(obj,name,parentName)
% 

% Copyright 2017 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com
    
    switch parentName
        case 'hardware settings'
            s = obj.qs.loadHwSettings(name);
        case 'user settings'
            s = obj.qs.loadSSettings(name);
        otherwise
            throw(MException('QOS_RegEditor:unrecognizedInput',...
                '%s is an unrecognized parentName option.', parentName));
    end
    
    table_data = Struct2TableData(s,'');
end

function table_data = Struct2TableData(data,prefix)
    table_data = {};
    fn = fieldnames(data);
    for ww = 1:numel(fn)
        Value = data.(fn{ww});
        if isempty(Value)
            Value = '';
            continue;
        end
        if isnumeric(Value)
            if numel(Value) == 1
                if abs(Value) < 1e3 && abs(Value) > 1e-3
                    Value = num2str(Value);
                else
                    Value = num2str(Value,'%0.3e');
                end
            else
                Value = 'numeric array or matrix';
            end
        elseif islogical(Value)
            if numel(Value) == 1
                if Value
                    Value = 'true';
                else
                    Value = 'false';
                end
            else
                Value = 'boolean array or matrix';
            end
        elseif ischar(Value)
            % pass
        elseif isstruct(Value)
            if numel(Value) == 1
				table_data_ = Struct2TableData(Value,[prefix,fn{ww},'.']);
				table_data = [table_data;table_data_];
				continue;
			else
				Value = 'struct array or matrix';
			end
        elseif iscell(Value)
            Value = 'cell';
        else
            classname = class(Value(1));
            if numel(Value) == 1
                Value = ['''',classname, ''' class object'];
            else
                Value = ['''',classname, ''' class object array or matrix'];
            end
        end
        table_data = [table_data;{[prefix,fn{ww}],Value}];
    end
end