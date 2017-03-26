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
        userList
        sessionList
        
        guiHandles
    end
    methods
        function obj = RegEditor()
            try
                obj.qs = qes.qSettings.GetInstance();
 
            catch
                qsRootDir = uigetdir(pwd,'Select the registry directory:');
                if isempty(qsRootDir)
                    throw(MException('QOS_RegEditor:createQSettingsError',...
                            'registry directory not selected.'));
                end
                try
                    obj.qs = qes.qSettings.GetInstance(qsRootDir);
                catch
                    throw(MException('QOS:qSettingsCreationErr','qSettings object can not be created.'));
                end
            end
            userList_ = {'_Not set_'};
            fInfo = dir(fullfile(obj.qs.root));
            for ii = 1:numel(fInfo)
                if fInfo(ii).isdir &&...
                        ~ismember(fInfo(ii).name,{'.','..','calibration','hardware'}) &&...
                        ~qes.util.startsWith(fInfo(ii).name,'_')
                    userList_ = [userList_,{fInfo(ii).name}];
                end
            end
            obj.userList = userList_;
            if ~isempty(obj.qs.user)
                fInfo = dir(fullfile(obj.qs.root,obj.qs.user));
                sessionList_ = {'_Not set_'};
                for ii = 1:numel(fInfo)
                    if fInfo(ii).isdir &&...
                            ~ismember(fInfo(ii).name,{'.','..'}) &&...
                            ~qes.util.startsWith(fInfo(ii).name,'_')
                        sessionList_ = [sessionList_,{fInfo(ii).name}];
                    end
                end
                obj.sessionList = sessionList_;
            end
            CreateGUI(obj);
        end
        function createUITree(obj)
            fInfo = dir(fullfile(obj.qs.root,obj.qs.user,obj.qs.session));
            SSGroups = {};
            for ii = 1:numel(fInfo)
                if ~fInfo(ii).isdir || strcmp(fInfo(ii).name,'.')||...
                        strcmp(fInfo(ii).name,'..') ||...
                        qes.util.startsWith(fInfo(ii).name,'_')
                    continue;
                end
                SSGroups = [SSGroups, {fInfo(ii).name}];
            end
            selectedSSGroups = ['public',obj.qs.loadSSettings('selected')];
            ss = uitreenode('v0', 'session settings', [obj.qs.user, '-',obj.qs.session], '.NULL', false);
            ss.setIcon(im2java(qes.app.RegEditor.ico_user()));
            for ii = 1:numel(SSGroups)
                node = uitreenode('v0', SSGroups{ii},  SSGroups{ii},  [], true);
                if qes.util.ismember(SSGroups{ii},selectedSSGroups) ||...
                        strcmp(SSGroups{ii},'public')
                    node.setIcon(im2java(qes.app.RegEditor.ico_qobject()));
                else
                    node.setIcon(im2java(brighten(qes.app.RegEditor.ico_qobject(),0.95)));
                end
                ss.add(node);
            end
            fInfo = dir(fullfile(obj.qs.root,'hardware',...
                qes.util.loadSettings(obj.qs.root,{'hardware','selected'})));
            HwSGroups = {};
            for ii = 1:numel(fInfo)
                if ~fInfo(ii).isdir || strcmp(fInfo(ii).name,'.')||...
                        strcmp(fInfo(ii).name,'..') ||...
                        qes.util.startsWith(fInfo(ii).name,'_')
                    continue;
                end
                HwSGroups = [HwSGroups, {fInfo(ii).name}];
            end
            selectedHwSGroups = obj.qs.loadHwSettings('selected');
            hws = uitreenode('v0', 'hardware settings', 'hardware', '.NULL', false);
            hws.setIcon(im2java(qes.app.RegEditor.ico_hardware_pci()));
            for ii = 1:numel(HwSGroups)
                node = uitreenode('v0', HwSGroups{ii},  HwSGroups{ii},  [], true);
                if qes.util.ismember(HwSGroups{ii},selectedHwSGroups)
                    node.setIcon(im2java(qes.app.RegEditor.ico_hardwave_chip()));
                else
                     node.setIcon(im2java(brighten(qes.app.RegEditor.ico_hardwave_chip(),0.7)));
                end
                hws.add(node);
            end

            % Root node
            rootNode = uitreenode('v0', 'registry', 'registry', [], false);
            rootNode.setIcon(im2java(qes.app.RegEditor.ico_settings()));
            rootNode.add(hws);
            rootNode.add(ss);
        
            obj.guiHandles.mtree = uitree('v0', 'Root', rootNode,...
                'Parent',obj.guiHandles.reWin,'Position',[5,5,200,600]);
            set(obj.guiHandles.mtree,'NodeSelectedCallback', @SelectFcn);
            obj.guiHandles.mtree.expand(rootNode);

            function SelectFcn(tree,~)
                nodes = tree.SelectedNodes;
                if isempty(nodes) || ~nodes(1).isLeaf
                    return;
                end
                node = nodes(1);
                name = get(node,'Name');
                parentName = get(get(node,'Parent'),'Value');
                obj.nodeName = name;
                obj.nodeParent = parentName;
                set(obj.guiHandles.regTable,'Data',obj.TableData(name,parentName));
            end
        end
        
        function delete(obj)
            if ~isempty(obj.guiHandles) &&...
                    isfield(obj.guiHandles,'reWin') &&...
                    isvalid(obj.guiHandles.reWin)
                close(obj.guiHandles.reWin);
            end
        end
    end
    methods (Access = private)
        CreateGUI(obj)
        t = CreateUITree(obj)
        table_data = TableData(obj,name,parentName)
    end
    methods (Static)
		cm = ico_settings()
		cm = ico_user()
		cm = ico_hardware_pci()
		cm = ico_hardwave_chip()
		cm = ico_qobject()
    end
end