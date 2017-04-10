function saveSettings(spath, field,value)
% save settings
% examples:
% s = qes.util.saveSettings('F:\program\qes_settings',{'yulin','session1','q2','r_delay'},value)

% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com


    if isempty(field)
        error('saveSettings:noField','field must be specified in saving settings value.');
    end
%     if ~iscell(field)
%         if ~ischar(field)
%             error('saveSettings:invalidInput','fileds should be a cell array of char strings or a char string.');
%         else
%             if strcmp('name',field)
%                 error('saveSettings:invalidInput','the value of filed ''name'' is of critical importance thus not allowed to be changed by saveSettings.');
%             end
%             field = {field};
%         end
%     elseif strcmp('name',field{end})
%         error('saveSettings:invalidInput','the value of filed ''name'' is of critical importance thus not allowed to be changed by saveSettings.');
%     end
    
    settings_exists = false;
    isJson = false;
    try
        for ii = 1:numel(field)
            if ~isempty(regexp(field{ii},'{\d+}', 'once')) || ~isempty(strfind(field{ii},'.'))
                isJson = true;
                break;
            end
        end
        if isJson
            old_value = [];
        else
            old_value = qes.util.loadSettings(spath, field);
        end
        settings_exists = true;
    catch ME
        if strcmp(ME.identifier,'loadSettings:invalidInput')
            warning('saveSettings:addNewField','field %s not found, this field will be add into the setttings.', field);
        else
            rethrow(ME);
        end
    end
    try
        if strcmp(class(old_value),class(value))
            sz_o = size(old_value);
            sz_n = size(value);
            if length(sz_o) == length(sz_n) && all(sz_o == sz_n) && all(old_value == value) % case of cell is neganected
                return;
            end
        end
    catch
    end
    numFields = numel(field);
    fileinfo = dir(spath);
    numFiles = numel(fileinfo);
    if ~settings_exists && numFiles == 1 % field not exist, add it
        
        return;
    end
    for ii = 1:numFiles
        if strcmp(fileinfo(ii).name,'.') || strcmp(fileinfo(ii).name,'..')
            continue;
        end
        if fileinfo(ii).isdir && strcmp(fileinfo(ii).name,field{1})
            field(1) = [];
            qes.util.saveSettings(fullfile(spath,fileinfo(ii).name),field,value);
            return;
        end
        if fileinfo(ii).isdir || length(fileinfo(ii).name) < 5 || ~strcmp(fileinfo(ii).name(end-2:end),'key')
            continue;
        end
        fname = fileinfo(ii).name(1:end-4);
        if length(field{1}) >= length(fname) && strcmp(fname,field{1}(1:length(fname)))
            field_ = {};
            for uu = 1:numel(field)
                field_ = [field_, strsplit(field{uu},'.')];
            end
            qes.util.saveJson(fullfile(spath,fileinfo(ii).name),field_,value);
        elseif numFields == 1
            ln_field = numel(field{1});
            if length(fileinfo(ii).name)-3 >= ln_field &&...
                    strcmp(fileinfo(ii).name(1:ln_field),field{1})
                switch fileinfo(ii).name(ln_field+1)
                    case '@'
                        if ~ischar(value)
                            error('saveSettings:invalidInput','value type of the current settings field is char string, %s given.', class(value));
                        end
                        newfilename = [field{1},'@',value,'.key'];
                        movefile(fullfile(spath,fileinfo(ii).name),fullfile(spath,newfilename));
                        % regist old_value to history
                        history_dir = fullfile(spath,'_history');
                        if ~exist(history_dir,'dir')
                            mkdir(history_dir);
                        end
                        history_file = fullfile(history_dir,[field{1},'.his']);
                        if ~exist(history_file,'file') ||...
                                numel(dir(history_file)) > 1 % a folder
                            fid = fopen(history_file,'w');
                        else
                            fid = fopen(history_file,'a+');
                        end
                        fprintf(fid,'%s\t%s\r\n',datestr(now,'yyyy-mm-dd HH:MM:SS:FFF'),old_value);
                        fclose(fid);
                        return;
                    case '=' % in case of numeric settings value, we allow the caller to convert the numeric value to a string, this is usefull since
                        % only the caller knows how much number of digits to
                        % use in converting to char string.
                        if ~isnumeric(value)
                            if ~ischar(value)
                                error('saveSettings:invalidInput',...
                                	'value type of the current settings field is numeric, %s given.', class(value));
                            else
                                value = regexprep(value,'\s+','');
                                value = regexprep(value,',\.',',0\.');
                                value = regexprep(value,'\[\.','[0\.');
                                if isnan(str2double(value)) &&...
                                	isempty(regexp(value,'[(\d+(\.\d+){0,1},)*(\d+(\.\d+){0,1}])', 'once'))
                                    error('saveSettings:invalidInput',...
                                         'value type of the current settings field is numeric, %s given.', value);
                                end
                                value = regexprep(value,'[\[\]]','');
                            end
                        end
                        if ~ischar(value) % if not converted to char string already by caller.
                            str = '';
                            for ww = 1:numel(value)
                                str = [str,',',qes.util.num2strCompact(value(ww))];
                            end
                            value = str(2:end);
                        end
                        newfilename = [field{1},'=',value,'.key'];
                        movefile(fullfile(spath,fileinfo(ii).name),fullfile(spath,newfilename));
                        % regist old_value to history
                        history_dir = fullfile(spath,'_history');
                        if ~exist(history_dir,'dir')
                            mkdir(history_dir);
                        end
                        history_file = fullfile(history_dir,[field{1},'.his']);
                        if ~exist(history_file,'file') ||...
                                numel(dir(history_file)) > 1 % a folder
                            fid = fopen(history_file,'w');
                        else
                            fid = fopen(history_file,'a+');
                        end
                        fprintf(fid,'%s\t%0.5e\r\n',datestr(now,'yyyy-mm-dd HH:MM:SS:FFF'),old_value);
                        fclose(fid);
                        return;
                end
            end
        end
    end
end