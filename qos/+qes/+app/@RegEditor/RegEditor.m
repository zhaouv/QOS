classdef (Sealed = true)RegEditor < handle
    % Registry editor
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties

    end
    properties (SetAccess = private, GetAccess = private)
        qs
        nodeParent
        nodeName
    end
    methods
        function obj = RegEditor()
            try
                obj.qs = qes.qSettings.GetInstance();
            catch
                throw(MException('QOS_RegEditor:qSettingsNotCreated',...
                    'qSettings not created: create the qSettings object, set user and select session first.'));
            end
            CreateGUI(obj);
        end
    end
    methods (Access = private)
        CreateGUI(obj)
        t = CreateUITree(obj)
        table_data = TableData(obj,name,parentName)
    end
    methods (Static)
    end
end