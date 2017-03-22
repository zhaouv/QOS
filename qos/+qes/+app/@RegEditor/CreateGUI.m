function CreateGUI(obj)
% create gui

% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    OPSYSTEM = lower(system_dependent('getos'));
    if any([strfind(OPSYSTEM, 'microsoft windows xp'),...
            strfind(OPSYSTEM, 'microsoft windows Vista'),...
            strfind(OPSYSTEM, 'microsoft windows 7'),...
            strfind(OPSYSTEM, 'microsoft windows server 2008'),...
            strfind(OPSYSTEM, 'microsoft windows server 2003')])
        InfoDispHeight = 5; % characters
        SelectDataUILn = 30;
        panelpossize = [0,0,260,45];
        mainaxshift = 4;
    elseif any([strfind(OPSYSTEM, 'microsoft windows 10'),...
            strfind(OPSYSTEM, 'microsoft windows server 10'),...
            strfind(OPSYSTEM, 'microsoft windows server 2012')])
        InfoDispHeight = 6; % characters
        SelectDataUILn = 35;
        panelpossize = [0,0,258.5,45];
        mainaxshift = 5;
    else
        InfoDispHeight = 5; % characters
        SelectDataUILn = 30; % characters
        panelpossize = [0,0,260,45]; % characters
        mainaxshift = 4;
    end

    BkGrndColor = [0.941   0.941   0.941];
    handles.dataviewwin = figure('Units','characters','MenuBar','none',...
        'ToolBar','none','NumberTitle','off','Name','QOS | Registry Editor',...
        'Resize','off','HandleVisibility','callback','Color',BkGrndColor,...
        'DockControls','off','Position',[0,0,112,70]);
    movegui(handles.dataviewwin,'center');
%     handles.basepanel=uipanel(...
%         'Parent',handles.dataviewwin,...
%         'Units','characters',...
%         'Position',panelpossize,...
%         'backgroundColor',BkGrndColor,...
%         'Title','',...
%         'BorderType','none',...
%         'HandleVisibility','callback',...
%         'visible','on',...
%         'Tag','parameterpanel','DeleteFcn',{@GUIDeleteCallback});
    
    rootNode = CreateUITree(obj);
    handles.mtree = uitree('v0', 'Root', rootNode,'Parent',handles.dataviewwin,'Position',[5,5,200,800]);
    set(handles.mtree,'NodeSelectedCallback', @SelectFcn);
    handles.mtree.expand(rootNode);
    function SelectFcn(tree,~)
        nodes = tree.SelectedNodes;
        if isempty(nodes)
            return;
        end
        node = nodes(1);
        if ~node.isLeaf
            return;
        end
        name = get(node,'Name');
        parentName = get(get(node,'Parent'),'Name');
        obj.nodeName = name;
        obj.nodeParent = parentName;
        set(handles.InfoTable,'Data',obj.TableData(name,parentName));
    end

    handles.InfoTable = uitable('Parent',handles.dataviewwin,...
         'Data',[],...
         'ColumnName',{'Key','Value'},...
         'ColumnFormat',{'char','char'},...
         'ColumnEditable',[false,true],...
         'ColumnWidth',{180,180},...
         'RowName',[],...
         'CellEditCallback',@saveValue,...
         'Position',[210,5,360,910]);
     
    function saveValue(src,entdata)
        if strcmp(entdata.PreviousData,entdata.EditData)
            return;
        end
        tdata = get(src,'Data');
        name = tdata{entdata.Indices(1),1};
        try
            switch obj.nodeParent
                case 'user settings'
                    obj.qs.saveSSettings({obj.nodeName, name},entdata.EditData);
                case 'hardware settings'
                    obj.qs.saveHwSettings({obj.nodeName, name},entdata.EditData);
            end
        catch ME
            set(handles.InfoTable,'Data',obj.TableData(obj.nodeName,obj.nodeParent));
            msgbox(getReport(ME,'extended','hyperlinks','off'));
        end
    end

end