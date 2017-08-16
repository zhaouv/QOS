function CreateGUI(obj)
% create gui

% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com


    BkGrndColor = [0.941   0.941   0.941];
    winSize = obj.winSize;
%     obj.guiHandles.reWin = figure('Units','characters','MenuBar','none',...
%         'ToolBar','none','NumberTitle','off','Name','QOS | Registry Editor',...
%         'Resize','off','HandleVisibility','callback','Color',BkGrndColor,...
%         'DockControls','off','Position',winSize,'CloseRequestFcn',@exitFcn);
%     function exitFcn(~,~)
%         obj.delete();
%     end


%     obj.guiHandles.reWin = figure('Units','characters','MenuBar','none',...
%         'ToolBar','none','NumberTitle','off','Name','QOS | Registry Editor',...
%         'Resize','off','HandleVisibility','callback','Color',BkGrndColor,...
%         'DockControls','off','Position',winSize,'Visible','off');
    


obj.guiHandles.reWin = figure('Units','normalized','MenuBar','none',...
        'ToolBar','none','NumberTitle','off','Name','QOS | Registry Editor',...
        'HandleVisibility','callback','Color',BkGrndColor,...
        'DockControls','off','Position',winSize,'Visible','off');


    warning('off');
    jf = get(obj.guiHandles.reWin,'JavaFrame');
    jf.setFigureIcon(javax.swing.ImageIcon(...
        im2java(qes.ui.icons.qos1_32by32())));
    warning('on');
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

    obj.guiHandles.reWin.Units='pixels';
    mainlayout=uix.Grid('parent',obj.guiHandles.reWin,'padding',2);
    
    leftlayout=uix.Grid('parent',mainlayout);
    rightlayout=uix.Grid('parent',mainlayout,'padding',2);
    mainlayout.Widths=[250 -1];
    
    leftuplayout=uix.Grid('parent',leftlayout);
    leftdownlayout=uix.Grid('parent',leftlayout,'padding',2);
    leftlayout.Heights=[130 -1];
    
    selectlayout=uix.Grid('parent',leftuplayout,'padding',2);
    buttonlayout=uix.Grid('parent',leftuplayout,'padding',2);
    leftuplayout.Heights=[-3 -1];
    
    %selectlayout
    obj.guiHandles.SelectUserTitle = uicontrol('Parent',selectlayout,'Style','text','string','User:',...
        'FontSize',9,'FontUnits','points','HorizontalAlignment','Left','Units','characters');
    obj.guiHandles.SelectHwTitle = uicontrol('Parent',selectlayout,'Style','text','string','Hardware:',...
        'FontSize',9,'FontUnits','points','HorizontalAlignment','Left','Units','characters');
    obj.guiHandles.SelectSessionTitle = uicontrol('Parent',selectlayout,'Style','text','string','Session:',...
        'FontSize',9,'FontUnits','points','HorizontalAlignment','Left','Units','characters');
    %
    obj.guiHandles.SelectUser = uicontrol('Parent',selectlayout,'Style','popupmenu','String',obj.userList,...
        'value',1,'FontSize',9,'FontUnits','points','HorizontalAlignment','Left',...
        'ForegroundColor',[0.5,0.5,1],'BackgroundColor',[0.9,1,0.8],'Units','characters','Callback',{@SelectUserCallback},...
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
    obj.guiHandles.SelectSession = uicontrol('Parent',selectlayout,'Style','popupmenu','string','_Not Set_',...
        'value',1,'FontSize',9,'FontUnits','points','HorizontalAlignment','Left',...
        'ForegroundColor',[0.5,0.5,1],'BackgroundColor',[0.9,1,0.8],'Units','characters','Callback',{@SelectSessionCallback},...
        'Tooltip','Select session.','Enable','off');
    obj.guiHandles.SelectHw = uicontrol('Parent',selectlayout,'Style','popupmenu','string','_Not Set_',...
        'value',1,'FontSize',9,'FontUnits','points','HorizontalAlignment','Left',...
        'ForegroundColor',[0.5,0.5,1],'BackgroundColor',[0.9,1,0.8],'Units','characters','Callback',{@SelectHwCallback},...
        'Tooltip','Select hardware group.','Enable','on');
    %
    obj.guiHandles.copyUser = uicontrol('Parent',selectlayout,'Style','pushbutton','string','C',...
        'FontSize',10,'FontUnits','points',...
        'Units','characters','Callback',{@CopyCallback,1},...
        'Tooltip','copy current user settings group.');
    obj.guiHandles.copySession = uicontrol('Parent',selectlayout,'Style','pushbutton','string','C',...
        'FontSize',10,'FontUnits','points',...
        'Units','characters','Callback',{@CopyCallback,2},...
        'Tooltip','copy current session.');
    obj.guiHandles.copyHwSettings = uicontrol('Parent',selectlayout,'Style','pushbutton','string','C',...
        'FontSize',10,'FontUnits','points',...
        'Units','characters','Callback',{@CopyCallback,3},...
        'Tooltip','copy current hardware settings group.');
    %
    obj.guiHandles.deleteUser = uicontrol('Parent',selectlayout,'Style','pushbutton','string','X',...
        'FontSize',10,'FontUnits','points','ForegroundColor',[1,0,0],...
        'Units','characters','Callback',{@deleteCallback,1},...
        'Tooltip','delete current user settings group.');
    obj.guiHandles.deleteSession = uicontrol('Parent',selectlayout,'Style','pushbutton','string','X',...
        'FontSize',10,'FontUnits','points','ForegroundColor',[1,0,0],...
        'Units','characters','Callback',{@deleteCallback,2},...
        'Tooltip','delete current session.');
    obj.guiHandles.deleteHwSettings = uicontrol('Parent',selectlayout,'Style','pushbutton','string','X',...
        'FontSize',10,'FontUnits','points','ForegroundColor',[1,0,0],...
        'Units','characters','Callback',{@deleteCallback,3},...
        'Tooltip','delete current hardware settings group.');
    %
    selectlayout.Widths=[60 -1 20 20];
    selectlayout.Heights=[-1 -1 -1];
    
    
    %buttonlayout
    obj.guiHandles.iniBtn = uicontrol('Parent',buttonlayout,'Style','pushbutton','string','Initialize',...
        'FontSize',10,'FontUnits','points',...
        'Units','characters','Callback',{@InitializeCallback},...
        'Tooltip','Create hardware objects.','Enable','off');
    
    %rightlayout
    ColumnWidth = {130,130,500};
    obj.guiHandles.regTable = uitable('Parent',rightlayout,...
         'Data',[],...
         'ColumnName',{'Key','Value','Annotation'},...
         'ColumnFormat',{'char','char'},...
         'ColumnEditable',[false,true,false],...
         'ColumnWidth',ColumnWidth,...
         'RowName',[],...
         'CellEditCallback',@saveValue,...
         'Units','characters');
     
     %leftdownlayout
     obj.treecontainer=uicontainer('Parent',leftdownlayout,'Units','normalized');
     
    if ~isempty(obj.sessionList)
        set(obj.guiHandles.SelectSession,'String',obj.sessionList,'Enable','on');
        if ~isempty(obj.qs.session)
            obj.sessionList = obj.sessionList(2:end);
            set(obj.guiHandles.SelectSession,'String',obj.sessionList);
            idx = qes.util.find(obj.qs.session,obj.sessionList);
            if isempty(idx) || numel(idx) > 1
                throw(MException('QOS_RegEditor:CorruptedDatabase',...
                    sprintf('database corrupted, selected session: %s points is an non existent session.',obj.qs.session)));
            end
            set(obj.guiHandles.SelectSession,'Value',idx,'Enable','on');
        end
    end
    
    if ~isempty(obj.hwList)
        set(obj.guiHandles.SelectHw,'String',obj.hwList);
        if ~isempty(obj.qs.hardware)
            obj.hwList = obj.hwList(2:end);
            set(obj.guiHandles.SelectHw,'String',obj.hwList);
            idx = qes.util.find(obj.qs.hardware,obj.hwList);
            if isempty(idx) || numel(idx) > 1
                throw(MException('QOS_RegEditor:CorruptedDatabase',...
                    sprintf('database corrupted, selected hardware group: %s points is an non existent hardware group.', obj.qs.hardware)));
            end
            set(obj.guiHandles.SelectHw,'Value',idx);
            set(obj.guiHandles.iniBtn,'Enable','on');
        end
    end

    if ~isempty(obj.qs.user) && ~isempty(obj.qs.session) &&...
            ~isempty(obj.qs.hardware)
    	obj.createUITree();
    end
%     
%     fpos = get(obj.guiHandles.reWin,'Position');
%     set(obj.guiHandles.reWin,'Position',fpos+1);
%     set(obj.guiHandles.reWin,'Position',fpos);
%     drawnow;
%     
    obj.tblRefreshTmr = timer('BusyMode','drop','ExecutionMode','fixedSpacing',...
            'ObjectVisibility','off','Period',obj.tblRefreshPeriond,...
            'TimerFcn',{@refreshTableData});
    % start(obj.tblRefreshTmr);
    
    function refreshTableData(~,~)
        if ~isvalid(obj.guiHandles.regTable) || isempty(obj.nodeName) || isempty(obj.nodeParent)
            return;
        end
        set(obj.guiHandles.regTable,'Data',obj.TableData(obj.nodeName,obj.nodeParent));
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
            qes.ui.msgbox(getReport(ME,'extended','hyperlinks','off'),'Saving failed.');
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
        if isfield(obj.guiHandles,'mtree') && ishghandle(obj.guiHandles.mtree)
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
        if isfield(obj.guiHandles,'mtree') && ishghandle(obj.guiHandles.mtree)
            delete(obj.guiHandles.mtree);
        end
        set(obj.guiHandles.regTable,'Data',[]);
        obj.createUITree();
    end
    function SelectHwCallback(src,ent)
        if get(src,'Value') == 1 && isempty(obj.qs.hardware)
            return;
        end
        hw = obj.hwList{get(src,'Value')};
        if strcmp(hw,obj.qs.hardware)
            return;
        end
        if strcmp(obj.hwList{1},'_Not set_')
            obj.hwList(1) = [];
            set(src,'Value',get(src,'Value')-1,...
                'String',obj.hwList);
        end
        obj.qs.SHW(hw);
        if isfield(obj.guiHandles,'mtree') && ishghandle(obj.guiHandles.mtree)
            delete(obj.guiHandles.mtree);
        end
        set(obj.guiHandles.regTable,'Data',[]);
        obj.createUITree();
        set(obj.guiHandles.iniBtn,'Enable','on','String','Initialize');
    end
    function InitializeCallback(src,ent)
        set(src,'Enable','off','String','Initializing...');
        drawnow;
        try
            obj.qs.CreateHw();
        catch ME
            qes.ui.msgbox(getReport(ME,'extended','hyperlinks','off'));
        end
        set(src,'String','Initialization Done');
    end
    function deleteCallback(src,ent,typ)
        % todo...
    end
    function copyCallback(src,ent,typ)
        % todo...
    end

    if obj.qs.hwCreated
		set(obj.guiHandles.iniBtn,'String','Initialization Done','Enable','off');
    end
    
    set(obj.guiHandles.reWin,'Visible','on');
end