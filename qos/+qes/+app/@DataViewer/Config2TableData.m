function table_data = Config2TableData(Config)
% 

% Copyright 2017 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    table_data = {};
    if isfield(Config,'fcn')
        table_data = [table_data;{'function',Config.fcn}];
    end
    if isfield(Config,'args')
        table_data = [table_data;Struct2TableData(Config.args,'args.')];
    end
    if isfield(Config,'session_settings')
        table_data = [table_data;Struct2TableData(Config.session_settings,'s.')];
    end
    if isfield(Config,'hw_settings')
        table_data = [table_data;Struct2TableData(Config.hw_settings,'hw.')];
    end
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