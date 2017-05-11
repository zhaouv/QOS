classdef logclass < handle

    
    properties 
        model
        logs
    end
        
    methods(Static)
        function func=replace(replacestr)
            persistent refunc;
            if nargin
                if ~strcmp(replacestr,'getreplacefunc')
                    eval(['refunc=@' replacestr ';'])  
                end
            end
            if isempty(refunc)
                error('replace empty')
            end
            func = @logclass;
            if nargin
                if strcmp(replacestr,'getreplacefunc')
                    func = refunc;
                end
            end
        end
    end
    
    methods
        function obj=logclass(varargin)
            func=logclass.replace('getreplacefunc');          
            if nargin
                obj.logs={obj.time();'create';char(func);varargin};
                obj.model=func(varargin{:});
            else
                obj.logs={obj.time();'create';char(func)};
                obj.model=func();
            end
        end
        
 
        function timestr=time(obj) %#ok<MANU>
            timestr=datestr(now,'yyyymmdd_HH:MM:SS.FFF');
        end

        function disp(obj)
            disp(obj.model)
        end
        
        function obj=subsasgn(obj,s,val)
            obj.logs(1,end+1)={obj.time()};
            obj.logs(2,end)={'set'};
            obj.logs(3,end)={val};
            tempindex=4;
            for i=s
                obj.logs(tempindex,end)={i.type};
                tempindex=tempindex+1;
                obj.logs(tempindex,end)={i.subs};
                tempindex=tempindex+1;
            end
            %
            obj.model=subsasgn(obj.model,s,val);
        end
        function sref=subsref(obj,s)
            if strcmp(s(1).subs,'logs')
                sref=obj.logs;
                return
            end
            if strcmp(s(1).subs,'model')
                sref=obj.model;
                return
            end
            obj.logs(1,end+1)={obj.time()};
            obj.logs(2,end)={'get'};
            tempindex=4;
            for i=s
                obj.logs(tempindex,end)={i.type};
                tempindex=tempindex+1;
                obj.logs(tempindex,end)={i.subs};
                tempindex=tempindex+1;
            end
            %
            sref=[];
            try
                sref=subsref(obj.model,s);
            catch
                builtin('subsref',obj.model,s);%无返回值时会跳到这里
            end
            %
            obj.logs(3,end)={sref};
        end
    end
end
