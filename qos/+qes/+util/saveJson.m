function saveJson(fullfilename,fields,value)
% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    error('save fields in json files is not implemented yet.');
    
    error('save history is not implemented yet.');

    c = {};
    fid  = fopen(fullfilename,'r');
    while ~feof(fid)
        try
            c{end+1} = fgetl(fid);
        catch ME
            fclose(fid);
            rethrow(ME);
        end
    end
    fclose(fid);
    n = numel(c);
    str = '';
    for ii = 1:n
        idx = strfind(c{ii},'//');
        if ~isempty(idx)
            c{ii}(idx:end) = [];
        end
        c{ii}(c{ii}==10 & c{ii}==13) = [];
        str = [str,c{ii}];
    end
    [data, ~] = qes.util.parseJson(str);
end