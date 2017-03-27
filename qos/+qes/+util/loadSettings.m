function data = loadSettings(spath, fields)
% load settings
% examples:
% s = qes.util.loadSettings('F:\program\qes_settings',{'hardware','hwsettings1','ustcadda','ad_boards'})
% s = qes.util.loadSettings('F:\program\qes_settings',{'hardware','hwsettings1','ustcadda','ad_boards','ADC2'})
% s = qes.util.loadSettings('F:\program\qes_settings',{'hardware','hwsettings1','ustcadda','ad_boards','ADC2','records','demod_freq'})

% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    data = [];
    if nargin == 1 || isempty(fields)
        fields = {};
    end
    if ~iscell(fields)
        if ~ischar(fields)
            throw(MException('QOS_loadSettings:invalidInput',...
				sprintf('fileds should be a cell array of char strings or a char string.')));
        else
            fields = {fields};
        end
    end
    if ~isdir(spath)
        throw(MException('QOS_loadSettings:invalidInput',sprintf('''%s'' is not a valid directory.', spath)));
    end
    if ~exist(spath,'dir')
        throw(MException('QOS_loadSettings:settingsNotFound',...
					sprintf('directory: ''%s'' not found.', spath)));
    end
    numFields = numel(fields);
    for ii = 1:numFields
        if ~ischar(fields{ii})
            throw(MException('QOS_loadSettings:invalidInput',...
				sprintf('field name can not be a(n) ''%s'', char string only.', class(fields{ii}))));
        elseif ~isvarname(fields{ii})
            throw(MException('QOS_loadSettings:invalidInput',sprintf('invalid field name ''%s''', fields{ii})));
        end
    end
    fileinfo = dir(spath);
    numFiles = numel(fileinfo);
    for ii = 1:numFiles;
        if strcmp(fileinfo(ii).name,'.') || strcmp(fileinfo(ii).name,'..') ||...
                strcmp(fileinfo(ii).name(1),'_') % files, directories starts with an underscore are special purpose files/folders
            if ii == numFiles && ~isempty(fields)
                throw(MException('QOS_loadSettings:settingsNotFound',...
					sprintf('no such field ''%s'' found in settings.',fields{end})));
            end
            continue;
        end
        if isempty(fields) % load all
            if fileinfo(ii).isdir
                data.(fileinfo(ii).name) = qes.util.loadSettings(fullfile(spath,fileinfo(ii).name));
            elseif length(fileinfo(ii).name) < 5 || ~strcmp(fileinfo(ii).name(end-2:end),'key')
                continue;
            else
                cidx = strfind(fileinfo(ii).name(1:end-4),'@'); % char string
                nidx = strfind(fileinfo(ii).name(1:end-4),'='); % numeric
				didx = strfind(fileinfo(ii).name(1:end-4),'#'); % data
                cidx = [cidx, didx]; % defer data loading to when it is needed, we'd like the qubit object to be light weighted, 2017/2/11, Yulin
                if isempty(cidx) && isempty(nidx)
                    fieldname = fileinfo(ii).name(1:end-4);
                    if isvarname(fieldname)
                        data_ = qes.util.loadJson(fullfile(spath,fileinfo(ii).name));
                        if isempty(data_)
                            data.(fieldname) = []; % empty files are accepted
                        elseif isfield(data_,fieldname)
                            data.(fieldname) = data_.(fieldname);
                        else
                            data.(fieldname) = data_;
                        end
                    end
                elseif ~isempty(cidx) && cidx(end) > 1
                    fieldname = fileinfo(ii).name(1:cidx(end)-1);
                    if isvarname(fieldname)
%                        data.(fieldname) = strsplit(strtrim(fileinfo(ii).name(cidx(end)+1:end-4)),',');
                        if isfield(data,fieldname)
                            throw(MException('QOS_loadSettings:duplicateSettingsEntry','duplicate settings entry: %s', fieldname));
                        end
						data.(fieldname) = strtrim(fileinfo(ii).name(cidx(end)+1:end-4));
					end
                elseif ~isempty(nidx) && nidx(end) > 1
                    fieldname = fileinfo(ii).name(1:nidx(end)-1);
                    if isvarname(fieldname)
                        dstr = strtrim(fileinfo(ii).name(nidx(end)+1:end-4));
                        if isempty(dstr)
                            data_ = [];
                        else
                            isboolean = false;
                            if ~isempty(strfind(dstr,'true')) || ~isempty(strfind(dstr,'false')) ||...
                                  ~isempty(strfind(dstr,'True')) || ~isempty(strfind(dstr,'False'))  
                                isboolean = true;
                                dstr = regexprep(dstr,'[tT]rue','1');
                                dstr = regexprep(dstr,'[fF]alse','0');
                            end
                            data_ = cellfun(@str2double,strsplit(dstr,','));
                            if isboolean
                                data_ = logical(data_);
                            end
                        end
                        if isfield(data,fieldname)
                            throw(MException('QOS_loadSettings:duplicateSettingsEntry','duplicate settings entry: %s', fieldname));
                        end
                        data.(fieldname) = data_;
                    end
% 				elseif ~isempty(didx) && didx(end) > 1 % defer data loading to when needed, better to have the qubit object light weighted
%                     fieldname = fileinfo(ii).name(1:didx(end)-1);
%                     if isvarname(fieldname)
% %                        data.(fieldname) = strsplit(strtrim(fileinfo(ii).name(cidx(end)+1:end-4)),',');
% 						datafile = fullfile(spath,'_data',strtrim(fileinfo(ii).name(cidx(end)+1:end-4))));
% 						if ~exist(datafile,'file')
% 							throw(MException('QOS_loadSettings:invalidSettingsValue',...
% 								sprintf('data for field ''%s'' not found.', fields{1})));
% 						end
% 						try
% 							data.(fieldname) = load(datafile);
% 						catch
% 							throw(MException('QOS_loadSettings:invalidSettingsValue',...
% 								sprintf('failed in loading data for field ''%s''.', fields{1})));
% 						end
% 					end
                end
            end
        else % load a specific field
            data = struct();
            if fileinfo(ii).isdir && strcmp(fileinfo(ii).name,fields{1})
                fields(1) = [];
                data = qes.util.loadSettings(fullfile(spath,fileinfo(ii).name),fields);
                return;
            end
            if fileinfo(ii).isdir || length(fileinfo(ii).name) < 5 || ~strcmp(fileinfo(ii).name(end-2:end),'key')
                if ii == numFiles
                    throw(MException('QOS_loadSettings:settingsNotFound',...
						sprintf('no field ''%s'' found in settings.', fields{1})));
                end
                continue;
            end
            if strcmp(fileinfo(ii).name(1:end-4),fields{1})
                jdata = qes.util.loadJson(fullfile(spath,fileinfo(ii).name));
                if numFields == 1
                    if isfield(jdata,fields{1})
                        data = jdata.(fields{1});
                    else
                        data = jdata;
                    end
                    return;
                end
                for jj = 1:numFields
                    if jj == 1 && ~isfield(jdata,fields{1})
                        continue;
                    end
                    if ~isfield(jdata,fields{jj})
                        throw(MException('QOS_loadSettings:settingsNotFound',...
							sprintf('no field ''%s'' found in settings.', fields{1})));
                    end
                    if jj == numFields
                        data = jdata.(fields{jj});
                        if iscell(data) && numel(data) == 1
                            data = data{1};
                        end
                        return;
                    else
                        jdata = jdata.(fields{jj});
                        if iscell(jdata) && numel(jdata) == 1
                            jdata = jdata{1};
                        end
                    end
                end
            elseif numFields == 1
                ln_field = numel(fields{1});
                if length(fileinfo(ii).name)-3 >= ln_field &&...
                        strcmp(fileinfo(ii).name(1:ln_field),fields{1})
                    switch fileinfo(ii).name(ln_field+1)
                        case '@' % char
%                            dstr = strsplit(strtrim(fileinfo(ii).name(ln_field+2:end-4)),',');
                            data = strtrim(fileinfo(ii).name(ln_field+2:end-4));
                            return;
                        case '=' % numeric
                            dstr = strtrim(fileinfo(ii).name(ln_field+2:end-4));
                            if isempty(dstr)
                                data = [];
                                return;
                            end
                            isboolean = false;
                            if ~isempty(strfind(dstr,'true')) || ~isempty(strfind(dstr,'false')) ||...
                                  ~isempty(strfind(dstr,'True')) || ~isempty(strfind(dstr,'False'))  
                                isboolean = true;
                                dstr = regexprep(dstr,'[tT]rue','1');
                                dstr = regexprep(dstr,'[fF]alse','0');
                            end
                            data = cellfun(@str2double,strsplit(dstr,','));
                            if isboolean
                                data = logical(data);
                            end
                            return;
						case '#' % data
							datafile = fullfile(spath,'_data',strtrim(fileinfo(ii).name(ln_field+2:end-4)));
							if ~exist(datafile,'file')
								throw(MException('QOS_loadSettings:invalidSettingsValue',...
									sprintf('data for field ''%s'' not found.', fields{1})));
							end
							try
								data = load(datafile); % a loadable data file
							catch
								throw(MException('QOS_loadSettings:invalidSettingsValue',...
									sprintf('failed in loading data for field ''%s''.', fields{1})));
							end
                    end
                end
            end
        end
        if ii == numFiles && ~isempty(fields)
            throw(MException('QOS_loadSettings:settingsNotFound',...
				sprintf('no field ''%s'' found in settings.', fields{end})));
        end
    end
end