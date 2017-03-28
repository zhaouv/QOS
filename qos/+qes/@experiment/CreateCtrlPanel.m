function CreateCtrlPanel(obj)
    % Experiment control panel

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    h = findall(0,'tag',['QOS | Experiment | Control Panel',obj.name]);
    if ~isempty(h)
        figure(h);
        set(h,'Visible','on');
        obj.ctrlpanel = h;
        return;
    end

    BkGrndColor = [1,1,1];
    scrsz = get(0,'ScreenSize');
    MessWinWinSz = [0.35,0.425,0.3,0.10];
    rw = 1440/scrsz(3);
    rh = 900/scrsz(4);
    MessWinWinSz(3) = rw*MessWinWinSz(3);
    MessWinWinSz(4) = rh*MessWinWinSz(4);
    % set the window position on the center of the screen
    MessWinWinSz(1) = (1 - MessWinWinSz(3))/2;
    MessWinWinSz(2) = (1 - MessWinWinSz(4))/2;
    
    obj.ctrlpanel = figure('Menubar','none','NumberTitle','off','Units','normalized ','Position',MessWinWinSz,...
            'Name',['QOS | Experiment: ',obj.name,' | Control Panel'],'Color',BkGrndColor,...
            'tag',['QOS|Experiment|Ctrlpanel',obj.name],'resize','off',...
            'HandleVisibility','callback','CloseRequestFcn',{@CtrlpanelClose});
    warning('off');
    jf = get(obj.ctrlpanel,'JavaFrame');
    jf.setFigureIcon(javax.swing.ImageIcon(...
        im2java(qes.ui.icons.qos1_32by32())));
    warning('on');
    handles.obj = obj;
    handles.CtrlpanelWin = obj.ctrlpanel; 
    panel = uipanel('parent',obj.ctrlpanel,'Position',[0.025,0.425,0.95,0.60],...
        'BackgroundColor',BkGrndColor,'BorderType','none');
%    handles.ProgressBar = waitbar2a(0,panel,'BarColor',[1 0 0; 0 1 0]); % varied color
    handles.ProgressBar = qes.ui.waitbar2a(0,panel,'BarColor',[0.694,0.839,0.196]);
    handles.AbortRunButton = uicontrol('Parent', obj.ctrlpanel,...
        'Style','Pushbutton','Foreg',[1,0,0],'String','Run/Abort',...
          'FontUnits','normalized','Fontsize',0.5,'FontWeight','bold',...
          'Units','normalized',...
          'Tooltip','Run the experiment if idle, abort the experiment if running.',...
          'Position',[0.075,0.1,0.40,0.3],'Callback',{@AbortFunc});
    handles.PauseButton = uicontrol('Parent', obj.ctrlpanel,...
        'Style','Pushbutton','String','Pause/Resume',...
          'FontUnits','normalized','Fontsize',0.5,'FontWeight','bold',...
          'Units','normalized',...
          'Tooltip','Pause or resume the running experiment(has a lag, do not click repeatedly.).',...
          'Position',[0.525,0.1,0.40,0.3],'Callback',{@PauseFunc});
   guidata(obj.ctrlpanel,handles);
   obj.UpdateProgress();
end

function AbortFunc(hObject,eventdata)
    handles = guidata(hObject);
    if handles.obj.running
        choice = questdlg(...
            'This will stop the experiment objet and erase data, please confirm:',...
            'Confirm Abort','Yes','Cancel','Cancel');
    else
        choice = questdlg(...
            'Run the experiment, please confirm:',...
            'Confirm Run','Yes','Cancel','Cancel');
    end
    switch choice
        case 'Yes'
            if handles.obj.running
                handles.obj.abort = true;
                if handles.obj.paused % abort action only excecuted when experiment is running.
                    handles.obj.RunExperiment();
                end
            else
                handles.obj.Run();
            end
        otherwise
            return;
    end
end

function PauseFunc(hObject,eventdata)
    handles = guidata(hObject);
    if ~handles.obj.running
        return;
    end
    if ~handles.obj.paused % running
        handles.obj.pause = true; % submit a pause request
    else
        handles.obj.paused = false; % order of these two lines is important!
        handles.obj.log.timestamp(end+1) = now;
        handles.obj.log.event{end+1} = 'resume measurement';
        handles.obj.RunExperiment(); % continue running the experiment.
    end
end

function CtrlpanelClose(hObject,eventdata)
    handles = guidata(hObject);
    if isstruct(handles) && isa(handles.obj,'Experiment') && isvalid(handles.obj)
        handles.obj.ctrlpanel = [];
    end
    delete(gcbf);
end