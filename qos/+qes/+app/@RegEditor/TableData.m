function table_data = TableData(obj,name,parentName)
% 

% Copyright 2017 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com
    
    switch parentName
        case 'hardware settings'
            s = obj.qs.loadHwSettings(name);
            anno = struct();
            if isfield(obj.keyAnnotation.hardware.(s.type),'comm')
                anno = obj.keyAnnotation.hardware.comm;
            end
            if isfield(s,'name') && isfield(obj.keyAnnotation.hardware,s.name)
                fname = fieldnames(obj.keyAnnotation.hardware.(s.name));
                for ii = 1:numel(fname)
                    anno.(fname{ii}) = obj.keyAnnotation.hardware.(s.name).(fname{ii});
                end
            end 
        case 'session settings'
            s = obj.qs.loadSSettings(name);
            anno = struct();
            if isfield(s, 'type') && isfield(obj.keyAnnotation.qobject,s.type)
                if isfield(obj.keyAnnotation.qobject.(s.type),'comm')
                    anno = obj.keyAnnotation.qobject.(s.type).comm;
                end
                if isfield(s, 'class') && isfield(obj.keyAnnotation.qobject.(s.type),s.class)
                    fname = fieldnames(obj.keyAnnotation.qobject.(s.type).(s.class));
                    for ii = 1:numel(fname)
                        anno.(fname{ii}) = obj.keyAnnotation.qobject.(s.type).(s.class).(fname{ii});
                    end
                end
            end 
        otherwise
            throw(MException('QOS_RegEditor:unrecognizedInput',...
                '%s is an unrecognized parentName option.', parentName));
    end
    table_data = Struct2TableData(s,anno,'');
end

function table_data = Struct2TableData(data,anno,prefix)
    table_data = {};
    fn = fieldnames(data);
    for ww = 1:numel(fn)
        Value = data.(fn{ww});
        if isempty(Value)
            key = [prefix,fn{ww}];
            key_ = strrep(key,'.','__');
            if isfield(anno,key_)
                annotation = anno.(key_);
            else
                annotation = '';
            end
            table_data = [table_data;{key,'',annotation}];
        elseif isstruct(Value)
			numElements = numel(Value);
			if numElements == 1
                table_data_ = Struct2TableData(Value,anno,[prefix,fn{ww},'.']);
                table_data = [table_data;table_data_];
			else
				table_data_ = {};
				for ii = 1:numel(Value)
					table_data_ = [table_data_;...
						Struct2TableData(Value(ii),anno,[prefix,fn{ww},...
						'(',num2str(ii,'%0.0f'),').'])];
				end
				table_data = [table_data;table_data_];
			end
		elseif iscell(Value)
			numElements = numel(Value);
			table_data_ = '';
			for uu = 1:numElements
				if isstruct(Value{uu})
					table_data_ = [table_data_; Struct2TableData(Value{uu},anno,...
						[prefix,fn{ww},'{',num2str(uu,'%0.0f'),'}.'])];
                else
                    key = [prefix,fn{ww},'{',num2str(uu,'%0.0f'),'}'];
                    key_ = strrep(key,'.','__');
                    if isfield(anno,key_)
                        annotation = anno.(key_);
                    else
                        annotation = '';
                    end
% 					table_data_ = [table_data_;...
% 						[{key},value2Str(Value{uu})]];
                    table_data_ = [table_data_;{key,value2Str(Value{uu}),annotation}];
                end
            end
			table_data = [table_data;table_data_];
        else
            key = [prefix,fn{ww}];
            key_ = strrep(key,'.','__');
            if isfield(anno,key_)
                annotation = anno.(key_);
            else
                annotation = '';
            end
			table_data = [table_data;{[prefix,fn{ww}],value2Str(Value),annotation}];
		end
    end
end

function s = value2Str(Value)
    % Value: not struct, not cell
    if isempty(Value)
        s = '';
    elseif ischar(Value)
        s = Value;
    elseif isnumeric(Value)
        if numel(Value) == 1
            s = qes.util.num2strCompact(Value);
        else
            sz = size(Value);
            if numel(sz) > 2 || all(sz>1)
                s = 'numeric matrix';
            else
                s = '[';
                for uu = 1:numel(Value)
                    s = [s,',',qes.util.num2strCompact(Value(uu))];
                end
                s = [s,']'];
                if numel(s)>2
                    s(2) = [];
                end
            end
        end
    elseif islogical(Value)
        if numel(Value) == 1
            if Value
                s = 'true';
            else
                s = 'false';
            end
        else
            sz = size(Value);
            if numel(sz) > 2 || all(sz>1)
                s = 'logical matrix';
            else
                ls = {'false','true'};
                lsIdx = uint8(Value)+1;
                s = '[';
                for uu = 1:numel(Value)
                    s = [s,',',ls{lsIdx(ii)}];
                end
                s = [s,']'];
            end
        end
    elseif isstruct(Value)
        s = 'stuct or struct array.';
    elseif iscell(Value)
        s = 'cell or cell array.';
    else
        classname = class(Value(1));
        if numel(Value) == 1
            s = ['''',classname, ''' class object'];
        else
            s = ['''',classname, ''' class object array or matrix'];
        end
    end

end