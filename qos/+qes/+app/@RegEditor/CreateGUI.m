function CreateGUI(obj)
% create gui

% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    BkGrndColor = [0.941   0.941   0.941];
    winSize = [0,0,112,70];
    obj.guiHandles.reWin = figure('Units','characters','MenuBar','none',...
        'ToolBar','none','NumberTitle','off','Name','QOS | Registry Editor',...
        'Resize','off','HandleVisibility','callback','Color',BkGrndColor,...
        'DockControls','off','Position',winSize);
    movegui(obj.guiHandles.reWin,'center');
%     obj.guiHandles.basepanel=uipanel(...
%         'Parent',obj.guiHandles.reWin,...
%         'Units','characters',...
%         'Position',panelpossize,...
%         'backgroundColor',BkGrndColor,...
%         'Title','',...
%         'BorderType','none',...
%         'HandleVisibility','callback',...
%         'visible','on',...
%         'Tag','parameterpanel','DeleteFcn',{@GUIDeleteCallback});

    pos = [0.25,winSize(4)-1.5,11,1];
    obj.guiHandles.SelectUserTitle = uicontrol('Parent',obj.guiHandles.reWin,'Style','text','string','User:',...
        'FontSize',10,'FontUnits','points','HorizontalAlignment','Left','Units','characters','Position',pos);
 
    pos(1) = pos(1)+pos(3)+1;
    pos(3) = 27;
    obj.guiHandles.SelectUser = uicontrol('Parent',obj.guiHandles.reWin,'Style','popupmenu','String',obj.userList,...
        'value',1,'FontSize',9,'FontUnits','points','HorizontalAlignment','Left',...
        'ForegroundColor',[0.5,0.5,1],'BackgroundColor',[0.9,1,0.8],'Units','characters','Position',pos,'Callback',{@SelectUserCallback},...
        'Tooltip','Select user');
    if ~isempty(obj.qs.user)
        obj.userList = obj.userList(2:end);
        set(obj.guiHandles.SelectUser,'String',obj.userList);
        idx = qes.util.find(obj.qs.user, obj.userList);
        if isempty(idx) || numel(idx) > 1
            error('BUG! this should not happen!');
        end
        set(obj.guiHandles.SelectUser,'Value',idx);
    end

    pos = get(obj.guiHandles.SelectUserTitle,'Position');
    pos(2) = pos(2)- 2;
    obj.guiHandles.SelectSessionTitle = uicontrol('Parent',obj.guiHandles.reWin,'Style','text','string','Session:',...
        'FontSize',10,'FontUnits','points','HorizontalAlignment','Left','Units','characters','Position',pos);
    
    pos(1) = pos(1)+pos(3)+1;
    pos(3) = 27;
    obj.guiHandles.SelectSession = uicontrol('Parent',obj.guiHandles.reWin,'Style','popupmenu','string','_Not Set_',...
        'value',1,'FontSize',9,'FontUnits','points','HorizontalAlignment','Left',...
        'ForegroundColor',[0.5,0.5,1],'BackgroundColor',[0.9,1,0.8],'Units','characters','Position',pos,'Callback',{@SelectSessionCallback},...
        'Tooltip','Select session.','Enable','off');
    if ~isempty(obj.sessionList)
        set(obj.guiHandles.SelectSession,'String',obj.sessionList,'Enable','on');
        if ~isempty(obj.qs.session)
            obj.sessionList = obj.userList(2:end);
            set(obj.guiHandles.SelectSession,'String',obj.sessionList);
            idx = qes.util.find(obj.qs.session,obj.sessionList);
            if isempty(idx) || numel(idx) > 1
                error('BUG! this should not happen!');
            end
            set(obj.guiHandles.SelectSession,'Value',idx,'Enable','on');
            set(obj.guiHandles.iniBtn,'Enable','on');
            obj.createUITree();
        end
    end

    pos_ = pos;
    pos = get(obj.guiHandles.SelectSessionTitle,'Position');
    pos(2) = pos(2)-3;
    pos(3) = pos_(1)+pos_(3)-pos(1);
    pos(4) =2;
    obj.guiHandles.iniBtn = uicontrol('Parent',obj.guiHandles.reWin,'Style','pushbutton','string','Initialize',...
        'FontSize',10,'FontUnits','points',...
        'Units','characters','Position',pos,'Callback',{@InitializeCallback},...
        'Tooltip','Create hardware objects.','Enable','off');

    obj.guiHandles.regTable = uitable('Parent',obj.guiHandles.reWin,...
         'Data',[],...
         'ColumnName',{'Key','Value'},...
         'ColumnFormat',{'char','char'},...
         'ColumnEditable',[false,true],...
         'ColumnWidth',{170,170},...
         'RowName',[],...
         'CellEditCallback',@saveValue,...
         'Position',[210,5,360,910]);

    if ~isempty(obj.qs.user) && ~isempty(obj.qs.session)
    	obj.createUITree();
    end
     
    function saveValue(src,entdata)
        if strcmp(entdata.PreviousData,entdata.EditData)
            return;
        end
        tdata = get(src,'Data');
        name = tdata{entdata.Indices(1),1};
        try
            switch obj.nodeParent
                case 'session settings'
                    obj.qs.saveSSettings({obj.nodeName, name},entdata.EditData);
                case 'hardware settings'
                    obj.qs.saveHwSettings({obj.nodeName, name},entdata.EditData);
            end
        catch ME
            set(obj.guiHandles.regTable,'Data',obj.TableData(obj.nodeName,obj.nodeParent));
            msgbox(getReport(ME,'extended','hyperlinks','off'));
        end
    end

    function SelectUserCallback(src,ent)
        if get(src,'Value') == 1 && isempty(obj.qs.user)
            return;
        end
        user = obj.userList{get(src,'Value')};
        if strcmp(user,obj.qs.user)
            return;
        end
        if strcmp(obj.userList{1},'_Not set_')
            obj.userList(1) = [];
            set(src,'Value',get(src,'Value')-1,...
                'String',obj.userList);
        end
        obj.qs.user = user;
        if isfield(obj.guiHandles,'mtree') && isvalid(obj.guiHandles.mtree)
            delete(obj.guiHandles.mtree);
        end
        set(obj.guiHandles.regTable,'Data',[]);
        obj.sessionList = [];
        set(obj.guiHandles.SelectSession,'Value',1,'String',{'_Not set_'},'Enable','off');
        set(obj.guiHandles.iniBtn,'Enable','off');
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
        if ~isempty(obj.qs.session)
            obj.sessionList = obj.sessionList(2:end);
            set(obj.guiHandles.SelectSession,'String',obj.sessionList);
            idx = qes.util.find(obj.qs.session,obj.sessionList);
            if isempty(idx) || numel(idx) > 1
                error('BUG! this should not happen!');
            end
            set(obj.guiHandles.SelectSession,'Value',idx,'Enable','on');
            set(obj.guiHandles.iniBtn,'Enable','on','String','Initialize');
            obj.createUITree();
        end
    end
    function SelectSessionCallback(src,ent)
        if get(src,'Value') == 1 && isempty(obj.qs.session)
            return;
        end
        session = obj.sessionList{get(src,'Value')};
        if strcmp(session,obj.qs.session)
            return;
        end
        if strcmp(obj.sessionList{1},'_Not set_')
            obj.sessionList(1) = [];
            set(src,'Value',get(src,'Value')-1,...
                'String',obj.sessionList);
        end
        obj.qs.SS(session);
        if isfield(obj.guiHandles,'mtree') && isvalid(obj.guiHandles.mtree)
            delete(obj.guiHandles.mtree);
        end
        set(obj.guiHandles.regTable,'Data',[]);
        obj.createUITree();
        set(obj.guiHandles.iniBtn,'Enable','on','String','Initialize');
    end
    function InitializeCallback(src,ent)
        set(src,'Enable','off','String','Initializing...');
        pause(0.1);
        try
            obj.qs.CreateHw();
        catch ME
            msgbox(getReport(ME,'extended','hyperlinks','off'));
        end
        set(src,'String','Initialization Done');
    end
end