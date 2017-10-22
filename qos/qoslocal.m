classdef qoslocal < handle
% do not modify this file
properties (Constant,   Access = private)
qutipenv='tobereplace';
end
    
    methods(Static)
        function out=get(name)
            mname=mfilename('fullpath');
            if mname(end)=='_'
                error('do not use qoslocal_.get, use qoslocal.get')
            end
            % if local_ do not exist,creat it
            try
                assert(exist([mname,'_.m'],'file')~=0);
            catch
                [~,pypath,~]= pyversion;
                fid=fopen([mname,'.m'],'r');
                str=fread(fid);
                fclose(fid);
                str=char(str');
                str=replace(str,'local < handle','local_ < handle');
                str=replace(str,',   Access = private','');
                str=replace(str,'do not modify this file','configure by modify this file');
                str=replace(str,'tobereplace',pypath);
                fid=fopen([mname,'_.m'],'w');
                fwrite(fid,str);
                fclose(fid);
                disp('first time to use qoslocal,creating file');
                out=qoslocal.(name);
                if strcmp(out,'tobereplace')
                    out=pypath;
                end
                pause(0.01);
                return;
            end
            out=qoslocal_.(name);
        end 
    end
end