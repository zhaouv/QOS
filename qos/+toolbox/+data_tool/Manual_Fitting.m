function Manual_Fitting(x,y)
% do curve fitting by manually tunning parameters

% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if numel(x) ~= numel(y)
        error('x y size not match.');
    end
    if numel(x) < 2
        error('scalar data.');
    end
    if ~isreal(x) || ~isreal(y)
        error('can not do fitting for complex data.');
    end

    system = lower(system_dependent('getos'));
    if any([strfind(system, 'microsoft windows xp'),...
            strfind(system, 'microsoft windows Vista'),...
            strfind(system, 'microsoft windows 7'),...
            strfind(system, 'microsoft windows server 2008'),...
            strfind(system, 'microsoft windows server 2003')])
        InfoDispHeight = 5; % characters
        SelectDataUILn = 30;
        panelpossize = [0,0,250,40];
    elseif any([strfind(system, 'microsoft windows 10'),...
            strfind(system, 'microsoft windows server 10'),...
            strfind(system, 'microsoft windows server 2012')])
        InfoDispHeight = 6; % characters
        SelectDataUILn = 35;
        panelpossize = [0,0,300,40];
    else
        InfoDispHeight = 5; % characters
        SelectDataUILn = 30; % characters
        panelpossize = [0,0,250,40]; % characters
    end
    
    BkGrndColor = [0.941   0.941   0.941];
    handles.mainwin = figure('Units','characters','MenuBar','none',...
        'ToolBar','none','NumberTitle','off','Name','QES | Manual Curve Fitting',...
        'Resize','off','HandleVisibility','callback','Color',BkGrndColor,...
        'DockControls','off');
    ParentUnitOrig = get(handles.mainwin,'Units');
    set(handles.mainwin,'Units','characters');
    ParentPosOrig = get(handles.mainwin,'Position');
    set(handles.mainwin,'Position',[ParentPosOrig(1),ParentPosOrig(2),panelpossize(3),panelpossize(4)]);
    set(handles.mainwin,'Units',ParentUnitOrig); % restore to original units.
    movegui(handles.mainwin,'center');
    
    handles.basepanel=uipanel(...
        'Parent',handles.mainwin,...
        'Units','characters',...
        'Position',panelpossize,...
        'backgroundColor',BkGrndColor,...
        'Title','',...
        'BorderType','none',...
        'HandleVisibility','callback',...
        'visible','on',...
        'Tag','parameterpanel','DeleteFcn',{});
    
    pos  = [11,0.8,15,4];
    pos(1) = 12;
    pos(3) = 120;
    pos(2) = 4;
    pos(4) = 35;
    handles.mainax = axes('Parent',handles.basepanel,'Visible','on','HandleVisibility','callback',...
        'HitTest','off','XTick',[],'YTick',[],'Box','on','Units','characters',...
        'Position',pos);
    ND = numel(x);
    if ND < 30
        MarkerSize = 21;
    elseif ND < 50
        MarkerSize = 18;
    elseif ND < 150
        MarkerSize = 15;
    elseif ND < 300
        MarkerSize = 12;
    elseif ND < 600
        MarkerSize = 9;
    elseif ND < 1200
        MarkerSize = 6;
    else
        MarkerSize = 3;
    end
    plot(handles.mainax,x,y,'.b','MarkerSize',MarkerSize);
    xlabel(handles.mainax,'x');
    ylabel(handles.mainax,'y');
    
    pos(1) = pos(1)+pos(3)+4;
    pos(2) = pos(2)+pos(4)-1;
    pos(3) = 17;
    pos(4) = 1.1;
    handles.FitFcnTitle = uicontrol('Parent',handles.basepanel,'Style','text','string','Fit fcn:',...
        'FontSize',10,'FontUnits','points','HorizontalAlignment','Left','Units','characters','Position',pos);

    pos(1) = pos(1)+pos(3)+1;
    pos(2) = pos(2)-0.3;
    pos(3) = 94;
    pos(4) = 1.5;
    handles.FitFcnEdtBox = uicontrol('Parent',handles.basepanel,'Style','edit','string',...
        'fit function, e.g.: y = p1*sin(x/p2+p3)+p4*x+p5, p1,...,p5 are parameters to fit',...
        'FontSize',10,'FontUnits','points','FontAngle','oblique','ForegroundColor',[0.5,0.5,1],...
        'BackgroundColor',[0.9,1,0.8],'HorizontalAlignment','Left','Units','characters','Position',pos,...
        'Callback',{@FitFcnChanged});
    
    SliderBackGroundColor = [0.7,0.8,1];
    MAX_NUM_PARAMETERS = 7;
    %% P1
    pos = get(handles.FitFcnTitle,'Position');
    pos(2) = pos(2)-2;
    handles.P1Title = uicontrol('Parent',handles.basepanel,'Style','text','string','P1:0.5','Visible','off',...
        'FontSize',10,'FontUnits','points','HorizontalAlignment','Left','Units','characters','Position',pos);
    
    pos_lb(1) = pos(1)+pos(3)+1;
    pos_lb(2) = pos(2)-0.3;
    pos_lb(3) = 12;
    pos_lb(4) = 1.5;
    handles.P1LB = uicontrol('Parent',handles.basepanel,'Style','edit','string','0','Visible','off',...
        'FontSize',10,'FontUnits','points','FontAngle','oblique','ForegroundColor',[0.5,0.5,1],...
        'BackgroundColor',[0.9,1,0.8],'HorizontalAlignment','Left','Units','characters','Position',pos_lb);
    
    pos_ub = pos_lb;
    pos_ub(1) = pos_lb(1)+pos_lb(3)+1+69;
    pos_ub(3) = 12;
    handles.P1UB = uicontrol('Parent',handles.basepanel,'Style','edit','string','1','Visible','off',...
        'FontSize',10,'FontUnits','points','FontAngle','oblique','ForegroundColor',[0.5,0.5,1],...
        'BackgroundColor',[0.9,1,0.8],'HorizontalAlignment','Left','Units','characters','Position',pos_ub);
    
    pos_sld = pos_lb;
    pos_sld(1) = pos_lb(1)+pos_lb(3)+1;
    pos_sld(3) = pos_ub(1)-1-pos_sld(1);
    handles.P1SLD = uicontrol('Parent',handles.basepanel,'Style','slider','Max',1,'Min',0,'Visible','off',...
        'BackgroundColor',SliderBackGroundColor,'Units','characters','Position',pos_sld,'Value',0.5);
    
    %% P2
    pos = get(handles.P1Title,'Position');
    pos(2) = pos(2)-2;
    handles.P2Title = uicontrol('Parent',handles.basepanel,'Style','text','string','P2:0.5','Visible','off',...
        'FontSize',10,'FontUnits','points','HorizontalAlignment','Left','Units','characters','Position',pos);
    
    pos_lb(1) = pos(1)+pos(3)+1;
    pos_lb(2) = pos(2)-0.3;
    pos_lb(3) = 12;
    pos_lb(4) = 1.5;
    handles.P2LB = uicontrol('Parent',handles.basepanel,'Style','edit','string','0','Visible','off',...
        'FontSize',10,'FontUnits','points','FontAngle','oblique','ForegroundColor',[0.5,0.5,1],...
        'BackgroundColor',[0.9,1,0.8],'HorizontalAlignment','Left','Units','characters','Position',pos_lb);
    
    pos_ub = pos_lb;
    pos_ub(1) = pos_lb(1)+pos_lb(3)+1+69;
    pos_ub(3) = 12;
    handles.P2UB = uicontrol('Parent',handles.basepanel,'Style','edit','string','1','Visible','off',...
        'FontSize',10,'FontUnits','points','FontAngle','oblique','ForegroundColor',[0.5,0.5,1],...
        'BackgroundColor',[0.9,1,0.8],'HorizontalAlignment','Left','Units','characters','Position',pos_ub);
    
    pos_sld = pos_lb;
    pos_sld(1) = pos_lb(1)+pos_lb(3)+1;
    pos_sld(3) = pos_ub(1)-1-pos_sld(1);
    handles.P2SLD = uicontrol('Parent',handles.basepanel,'Style','slider','Max',1,'Min',0,'Visible','off',...
        'BackgroundColor',SliderBackGroundColor,'Units','characters','Position',pos_sld,'Value',0.5);
    
    %% P3
    pos = get(handles.P2Title,'Position');
    pos(2) = pos(2)-2;
    handles.P3Title = uicontrol('Parent',handles.basepanel,'Style','text','string','P3:0.5','Visible','off',...
        'FontSize',10,'FontUnits','points','HorizontalAlignment','Left','Units','characters','Position',pos);
    
    pos_lb(1) = pos(1)+pos(3)+1;
    pos_lb(2) = pos(2)-0.3;
    pos_lb(3) = 12;
    pos_lb(4) = 1.5;
    handles.P3LB = uicontrol('Parent',handles.basepanel,'Style','edit','string','0','Visible','off',...
        'FontSize',10,'FontUnits','points','FontAngle','oblique','ForegroundColor',[0.5,0.5,1],...
        'BackgroundColor',[0.9,1,0.8],'HorizontalAlignment','Left','Units','characters','Position',pos_lb);
    
    pos_ub = pos_lb;
    pos_ub(1) = pos_lb(1)+pos_lb(3)+1+69;
    pos_ub(3) = 12;
    handles.P3UB = uicontrol('Parent',handles.basepanel,'Style','edit','string','1','Visible','off',...
        'FontSize',10,'FontUnits','points','FontAngle','oblique','ForegroundColor',[0.5,0.5,1],...
        'BackgroundColor',[0.9,1,0.8],'HorizontalAlignment','Left','Units','characters','Position',pos_ub);
    
    pos_sld = pos_lb;
    pos_sld(1) = pos_lb(1)+pos_lb(3)+1;
    pos_sld(3) = pos_ub(1)-1-pos_sld(1);
    handles.P3SLD = uicontrol('Parent',handles.basepanel,'Style','slider','Max',1,'Min',0,'Visible','off',...
        'BackgroundColor',SliderBackGroundColor,'Units','characters','Position',pos_sld,'Value',0.5);
    
    %% P4
    pos = get(handles.P3Title,'Position');
    pos(2) = pos(2)-2;
    handles.P4Title = uicontrol('Parent',handles.basepanel,'Style','text','string','P4:0.5','Visible','off',...
        'FontSize',10,'FontUnits','points','HorizontalAlignment','Left','Units','characters','Position',pos);
    
    pos_lb(1) = pos(1)+pos(3)+1;
    pos_lb(2) = pos(2)-0.3;
    pos_lb(3) = 12;
    pos_lb(4) = 1.5;
    handles.P4LB = uicontrol('Parent',handles.basepanel,'Style','edit','string','0','Visible','off',...
        'FontSize',10,'FontUnits','points','FontAngle','oblique','ForegroundColor',[0.5,0.5,1],...
        'BackgroundColor',[0.9,1,0.8],'HorizontalAlignment','Left','Units','characters','Position',pos_lb);
    
    pos_ub = pos_lb;
    pos_ub(1) = pos_lb(1)+pos_lb(3)+1+69;
    pos_ub(3) = 12;
    handles.P4UB = uicontrol('Parent',handles.basepanel,'Style','edit','string','1','Visible','off',...
        'FontSize',10,'FontUnits','points','FontAngle','oblique','ForegroundColor',[0.5,0.5,1],...
        'BackgroundColor',[0.9,1,0.8],'HorizontalAlignment','Left','Units','characters','Position',pos_ub);
    
    pos_sld = pos_lb;
    pos_sld(1) = pos_lb(1)+pos_lb(3)+1;
    pos_sld(3) = pos_ub(1)-1-pos_sld(1);
    handles.P4SLD = uicontrol('Parent',handles.basepanel,'Style','slider','Max',1,'Min',0,'Visible','off',...
        'BackgroundColor',SliderBackGroundColor,'Units','characters','Position',pos_sld,'Value',0.5);
    
    %% P5
    pos = get(handles.P4Title,'Position');
    pos(2) = pos(2)-2;
    handles.P5Title = uicontrol('Parent',handles.basepanel,'Style','text','string','P5:0.5','Visible','off',...
        'FontSize',10,'FontUnits','points','HorizontalAlignment','Left','Units','characters','Position',pos);
    
    pos_lb(1) = pos(1)+pos(3)+1;
    pos_lb(2) = pos(2)-0.3;
    pos_lb(3) = 12;
    pos_lb(4) = 1.5;
    handles.P5LB = uicontrol('Parent',handles.basepanel,'Style','edit','string','0','Visible','off',...
        'FontSize',10,'FontUnits','points','FontAngle','oblique','ForegroundColor',[0.5,0.5,1],...
        'BackgroundColor',[0.9,1,0.8],'HorizontalAlignment','Left','Units','characters','Position',pos_lb);
    
    pos_ub = pos_lb;
    pos_ub(1) = pos_lb(1)+pos_lb(3)+1+69;
    pos_ub(3) = 12;
    handles.P5UB = uicontrol('Parent',handles.basepanel,'Style','edit','string','1','Visible','off',...
        'FontSize',10,'FontUnits','points','FontAngle','oblique','ForegroundColor',[0.5,0.5,1],...
        'BackgroundColor',[0.9,1,0.8],'HorizontalAlignment','Left','Units','characters','Position',pos_ub);
    
    pos_sld = pos_lb;
    pos_sld(1) = pos_lb(1)+pos_lb(3)+1;
    pos_sld(3) = pos_ub(1)-1-pos_sld(1);
    handles.P5SLD = uicontrol('Parent',handles.basepanel,'Style','slider','Max',1,'Min',0,'Visible','off',...
        'BackgroundColor',SliderBackGroundColor,'Units','characters','Position',pos_sld,'Value',0.5);
    
    
    %% P6
    pos = get(handles.P5Title,'Position');
    pos(2) = pos(2)-2;
    handles.P6Title = uicontrol('Parent',handles.basepanel,'Style','text','string','P6:0.5','Visible','off',...
        'FontSize',10,'FontUnits','points','HorizontalAlignment','Left','Units','characters','Position',pos);
    
    pos_lb(1) = pos(1)+pos(3)+1;
    pos_lb(2) = pos(2)-0.3;
    pos_lb(3) = 12;
    pos_lb(4) = 1.5;
    handles.P6LB = uicontrol('Parent',handles.basepanel,'Style','edit','string','0','Visible','off',...
        'FontSize',10,'FontUnits','points','FontAngle','oblique','ForegroundColor',[0.5,0.5,1],...
        'BackgroundColor',[0.9,1,0.8],'HorizontalAlignment','Left','Units','characters','Position',pos_lb);
    
    pos_ub = pos_lb;
    pos_ub(1) = pos_lb(1)+pos_lb(3)+1+69;
    pos_ub(3) = 12;
    handles.P6UB = uicontrol('Parent',handles.basepanel,'Style','edit','string','1','Visible','off',...
        'FontSize',10,'FontUnits','points','FontAngle','oblique','ForegroundColor',[0.5,0.5,1],...
        'BackgroundColor',[0.9,1,0.8],'HorizontalAlignment','Left','Units','characters','Position',pos_ub);
    
    pos_sld = pos_lb;
    pos_sld(1) = pos_lb(1)+pos_lb(3)+1;
    pos_sld(3) = pos_ub(1)-1-pos_sld(1);
    handles.P6SLD = uicontrol('Parent',handles.basepanel,'Style','slider','Max',1,'Min',0,'Visible','off',...
        'BackgroundColor',SliderBackGroundColor,'Units','characters','Position',pos_sld,'Value',0.5);
    
    %% P7
    pos = get(handles.P6Title,'Position');
    pos(2) = pos(2)-2;
    handles.P7Title = uicontrol('Parent',handles.basepanel,'Style','text','string','P7:0.5','Visible','off',...
        'FontSize',10,'FontUnits','points','HorizontalAlignment','Left','Units','characters','Position',pos);
    
    pos_lb(1) = pos(1)+pos(3)+1;
    pos_lb(2) = pos(2)-0.3;
    pos_lb(3) = 12;
    pos_lb(4) = 1.5;
    handles.P7LB = uicontrol('Parent',handles.basepanel,'Style','edit','string','0','Visible','off',...
        'FontSize',10,'FontUnits','points','FontAngle','oblique','ForegroundColor',[0.5,0.5,1],...
        'BackgroundColor',[0.9,1,0.8],'HorizontalAlignment','Left','Units','characters','Position',pos_lb);
    
    pos_ub = pos_lb;
    pos_ub(1) = pos_lb(1)+pos_lb(3)+1+69;
    pos_ub(3) = 12;
    handles.P7UB = uicontrol('Parent',handles.basepanel,'Style','edit','string','1','Visible','off',...
        'FontSize',10,'FontUnits','points','FontAngle','oblique','ForegroundColor',[0.5,0.5,1],...
        'BackgroundColor',[0.9,1,0.8],'HorizontalAlignment','Left','Units','characters','Position',pos_ub);
    
    pos_sld = pos_lb;
    pos_sld(1) = pos_lb(1)+pos_lb(3)+1;
    pos_sld(3) = pos_ub(1)-1-pos_sld(1);
    handles.P7SLD = uicontrol('Parent',handles.basepanel,'Style','slider','Max',1,'Min',0,'Visible','off',...
        'BackgroundColor',SliderBackGroundColor,'Units','characters','Position',pos_sld,'Value',0.5);
    
    function FitFcnChanged(src,evnt)
        handles.FitFcn = [];
        FitFcnStr = get(handles.FitFcnEdtBox,'String');
        FitFcnStr = regexprep(FitFcnStr,'[Yy]\s*=\s*','');
        if isempty(strfind(FitFcnStr,'x'))
            msgbox('Incorrect fitting function format.','modal');
            return;
        end
        FitFcnStr = regexprep(FitFcnStr,'@\s*\(\s*x\s*\)\s*','@(x)');
        idx = strfind(FitFcnStr,'@(x)');
        if isempty(idx)
            FitFcnStr = ['@(x)',FitFcnStr];
        else
            FitFcnStr = FitFcnStr(idx:end);
        end
        FitFcnStr = strtrim(FitFcnStr);
        [startIdx,endIndex] = regexpi(FitFcnStr,'[Pp]\d+');
        if any(endIndex - startIdx > 1)
            msgbox('Incorrect fitting function format, parameters with more than one digit index(e.g., p20) are not allowed.','modal');
            return;
        end
        NP = numel(startIdx);
        PIdx = NaN*ones(1,NP);
        for ii = 1:NP
            PIdx(ii) = str2double(FitFcnStr(startIdx(ii)+1));
        end
        PIdx = sort(unique(PIdx));
        NP = numel(PIdx);
        if NP > MAX_NUM_PARAMETERS
            msgbox(['Maximum number of fitting paprameters is ',num2str(MAX_NUM_PARAMETERS,'%0.0f'),...
                ', found ', num2str(NP,'%0.0f'),' in the given fitting function.'],'modal');
            return;
        end
        for ii = 1:NP
            FitFcnStr = strrep(FitFcnStr,['P',num2str(PIdx(ii),'%0.0f')],['p',num2str(ii,'%0.0f')]);
            FitFcnStr = strrep(FitFcnStr,['p',num2str(PIdx(ii),'%0.0f')],['p',num2str(ii,'%0.0f')]);
        end
        
        fcnheader = '@(x';
        for ii = 1:NP
            fcnheader = [fcnheader,',p',num2str(ii,'%0.0f')];
        end
        fcnheader = [fcnheader,')'];
        try
            handles.FitFcn = str2func(strrep(FitFcnStr,'@(x)',fcnheader));
            set(handles.FitFcnEdtBox,'String',regexprep(FitFcnStr,'@\(x(,\w+){0,}\)','y = '));
        catch
            msgbox('Incorrect fitting function format.','modal');
            return;
        end
        set(handles.P1Title,'Visible','off');
        set(handles.P1LB,'Visible','off');
        set(handles.P1UB,'Visible','off');
        set(handles.P1SLD,'Visible','off');

        set(handles.P2Title,'Visible','off');
        set(handles.P2LB,'Visible','off');
        set(handles.P2UB,'Visible','off');
        set(handles.P2SLD,'Visible','off');

        set(handles.P3Title,'Visible','off');
        set(handles.P3LB,'Visible','off');
        set(handles.P3UB,'Visible','off');
        set(handles.P3SLD,'Visible','off');

        set(handles.P4Title,'Visible','off');
        set(handles.P4LB,'Visible','off');
        set(handles.P4UB,'Visible','off');
        set(handles.P4SLD,'Visible','off');

        set(handles.P5Title,'Visible','off');
        set(handles.P5LB,'Visible','off');
        set(handles.P5UB,'Visible','off');
        set(handles.P5SLD,'Visible','off');

        set(handles.P6Title,'Visible','off');
        set(handles.P6LB,'Visible','off');
        set(handles.P6UB,'Visible','off');
        set(handles.P6SLD,'Visible','off');

        set(handles.P7Title,'Visible','off');
        set(handles.P7LB,'Visible','off');
        set(handles.P7UB,'Visible','off');
        set(handles.P7SLD,'Visible','off');
        
        for ii = 1:NP
            if ii == 1
                set(handles.P1Title,'Visible','on','string','P1:0.5');
                set(handles.P1LB,'Visible','on','string','0');
                set(handles.P1UB,'Visible','on','string','1');
                set(handles.P1SLD,'Visible','on','Max',1,'Min',0,'Value',0.5);
            end
            if ii == 2
                set(handles.P2Title,'Visible','on','string','P2:0.5');
                set(handles.P2LB,'Visible','on','string','0');
                set(handles.P2UB,'Visible','on','string','1');
                set(handles.P2SLD,'Visible','on','Max',1,'Min',0,'Value',0.5);
            end
            if ii == 3
                set(handles.P3Title,'Visible','on','string','P3:0.5');
                set(handles.P3LB,'Visible','on','string','0');
                set(handles.P3UB,'Visible','on','string','1');
                set(handles.P3SLD,'Visible','on','Max',1,'Min',0,'Value',0.5);
            end
            if ii == 4
                set(handles.P4Title,'Visible','on','string','P4:0.5');
                set(handles.P4LB,'Visible','on','string','0');
                set(handles.P4UB,'Visible','on','string','1');
                set(handles.P4SLD,'Visible','on','Max',1,'Min',0,'Value',0.5);
            end
            if ii == 5
                set(handles.P5Title,'Visible','on','string','P5:0.5');
                set(handles.P5LB,'Visible','on','string','0');
                set(handles.P5UB,'Visible','on','string','1');
                set(handles.P5SLD,'Visible','on','Max',1,'Min',0,'Value',0.5);
            end
            if ii == 6
                set(handles.P6Title,'Visible','on','string','P6:0.5');
                set(handles.P6LB,'Visible','on','string','0');
                set(handles.P6UB,'Visible','on','string','1');
                set(handles.P6SLD,'Visible','on','Max',1,'Min',0,'Value',0.5);
            end
            if ii == 7
                set(handles.P7Title,'Visible','on','string','P7:0.5');
                set(handles.P7LB,'Visible','on','string','0');
                set(handles.P7UB,'Visible','on','string','1');
                set(handles.P7SLD,'Visible','on','Max',1,'Min',0,'Value',0.5);
            end
        end    
    end
end