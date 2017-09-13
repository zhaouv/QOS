function filereplace(old_tag,new_tag,filepath)
if nargin<3
    QS = qes.qSettings.GetInstance();
    filepath=fullfile(QS.root,QS.user,QS.session);
end
files=dir(filepath);
for ii=3:numel(files)
    if files(ii).isdir
        cfolder=fullfile(files(ii).folder, files(ii).name);
        replacefile(old_tag,new_tag,cfolder)
        data_taking.public.util.filereplace(old_tag,new_tag,cfolder)
    end
end
end


function replacefile(old_tag,new_tag,folder)
files=dir(fullfile(folder,['*',old_tag,'*.*']));
if numel(files)~=0
    if ~isempty(new_tag)
        for ii=1:numel(files)
            oldfile=fullfile(files(ii).folder, files(ii).name);
            newfile=fullfile(files(ii).folder, replace(files(ii).name,old_tag,new_tag));
            movefile(oldfile,newfile)
        end
    elseif isempty(new_tag)
        for ii=1:numel(files)
            oldfile=fullfile(files(ii).folder, files(ii).name);
            delete(oldfile)
        end
    end
end
end
