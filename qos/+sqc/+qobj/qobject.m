classdef (Abstract = true) qobject < handle & dynamicprops & matlab.mixin.Copyable
    %
    
% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        name@char = ''
    end
    properties (SetAccess = private)
        id@uint32 % globally unique id
    end
    methods
        function obj = qobject(name)
            if nargin
                obj.name = name;
            end
            persistent nextid
            if isempty(nextid)
                nextid = uint32(1); 
            end
            obj.id = nextid;
            nextid  = nextid + uint32(1);
        end
    end
    methods (Hidden = true)
        function b = eq(obj1, obj2)
            b = false;
            if ischar(obj1)
                if strcmp(obj1,obj2.name)
                    b = true;
                end
            elseif ischar(obj2)
                if strcmp(obj1.name,obj2)
                    b = true;
                end
            else 
                if strcmp(obj1.name,obj2.name)
                    b = true;
                end
            end
        end
    end
end