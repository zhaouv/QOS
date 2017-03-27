function CreatGUI(obj)
%{
%%
addpath('DAC');
addpath('mainfile');
%
addpath('qos')
import qes.*
import sqc.wv.*
import qes.util.*
import qes.hwdriver.sync.*
import data_taking.public.xmon.*
import qes.hwdriver.*
%%
%dpo70404c = tcpip('10.0.0.100', 5025);
dpo70404c =visa('agilent','TCPIP0::C500014-70KC::inst0::INSTR');
% fopen(dpo70404c);
osc = Oscilloscope.GetInstance('tekdpo7000',dpo70404c,'tekdpo7000');
%%
addpath('layout');
osc.CreatGUI
%%
%}
    %layout
    %addpath('layout')
    obj.uihandles.init=0;
    obj.uihandles.add=0;
    obj.uihandles.mtimer=[];
    obj.uihandles.hfig=figure('pos',[50,50,1000,550], 'Name', 'OSC','NumberTitle', 'off','DeleteFcn',@(o,e)delfunc(obj,o,e) );
    %obj.uihandles.hfig=figure('pos',[50,50,1000,550], 'Name', 'OSC','MenuBar', 'none','Toolbar', 'none','NumberTitle', 'off' );
    mainlayout=uix.Grid('parent',obj.uihandles.hfig);
    axeslayout=uix.Grid('parent',mainlayout);
    osclayout=uix.Grid('parent',mainlayout,'padding',10);
    mainlayout.Heights=[-5 -0.5];

    %osclayout
    obj.uihandles.clearbutton=uicontrol('parent',osclayout,'string','clear');
    obj.uihandles.measures=zeros(1,8);
    for index2=1:8
        obj.uihandles.measures(index2)=uicontrol('parent',osclayout,'style','edit',...
                'string',['Measure' num2str(index2)],'tag',['Measure' num2str(index2)]);
    end
    obj.uihandles.addbutton=uicontrol('parent',osclayout,'string','add');
%     obj.uihandles.convertbutton=uicontrol('parent',osclayout,'string','convert');
    osclayout.Widths=[-1,zeros(1,8)-1,-1];
    
    %callback
    set(obj.uihandles.clearbutton,'callback',@(o,e)clearosc(obj,o,e));
    set(obj.uihandles.addbutton,'callback',@(o,e)addosc(obj,o,e));
%     set(obj.uihandles.convertbutton,'callback',@(o,e)convertosc(obj,o,e));

    obj.uihandles.axes1layout=uix.TabPanel( 'Parent', axeslayout);
    obj.uihandles.axes2layout=uix.TabPanel( 'Parent', axeslayout);
    
    obj.uihandles.ha1=axes( 'Parent',uicontainer( 'Parent',obj.uihandles.axes2layout),'Position',...
        [0.1,0.1,0.8,0.9]);
    axesvbox=uix.VBox('parent',obj.uihandles.axes2layout);
    obj.uihandles.axes2layout.TabTitles={'div','V'};
    obj.uihandles.has=zeros(1,4);
    for index3=1:4
        obj.uihandles.has(index3)=axes('Position',[0.05 0.1 0.9 0.9],'parent',uicontainer('parent',axesvbox));    
    end
    osc.datasource='ch1,ch2,ch3,ch4';
    obj.uihandles.Period=0.1;
    
    %%
    function plottick(obj,o,e)  %#ok<INUSD>
        %     osc.CreatGUI
        colc=[[0    0.4470    0.7410];[0.8500    0.3250    0.0980];[0.9290    0.6940    0.1250];[0.4940    0.1840    0.5560]];
        datas=GetoscMeasure(obj);
        divs=obj.getdatanow();
        divs=divs/32768*5;
        waves=divs;
        for index1=1:4
            POSition=str2double(query(obj.interfaceobj,['CH' num2str(index1) ':POSition?']));%0 V -> ? div
            SCALe=str2double(query(obj.interfaceobj,['CH' num2str(index1) ':SCALe?']));% 1 div=? V
            waves(:,index1)=(waves(:,index1)-POSition)*SCALe;
        end
        for index1=1:8
            set(obj.uihandles.measures(index1),'string',num2str(datas(index1)));
        end
        t=linspace(-datas(10)*datas(9)/100,(1-datas(10)/100)*datas(9),datas(11));
        %
        aline=divs;
            tempa=obj.uihandles.ha1;
            cla(tempa);
            plot(t,aline,'parent',tempa);
            set(tempa,'YLim',[-5 5]);
            line([0 0],get(tempa,'YLim'),'color','r','parent',tempa);
            grid(tempa,'on');
        for index1 = 1:4
            tempa=obj.uihandles.has(index1);
            cla(tempa);
            plot(t,waves(:,index1),'parent',tempa,'color',colc(index1,:));
            line([0 0],get(tempa,'YLim'),'color','r','parent',tempa);
            grid(tempa,'on');
        end 
        %
        if obj.uihandles.add
            obj.uihandles.add=0;
            tempvbox=uix.VBox('parent',obj.uihandles.axes1layout);
            aline=divs;
                tempa=axes('Position',[0.05 0.15 0.9 0.85],'parent',uicontainer('parent',tempvbox));
                plot(t,aline,'parent',tempa);
                set(tempa,'YLim',[-5 5]);
                line([0 0],get(tempa,'YLim'),'color','r','parent',tempa);
                grid(tempa,'on');
            for index1 = 1:4
                aline=waves(:,index1);
                tempa=axes('Position',[0.05 0.1 0.9 0.9],'parent',uicontainer('parent',tempvbox));
                plot(t,aline,'parent',tempa,'color',colc(index1,:));
                line([0 0],get(tempa,'YLim'),'color','r','parent',tempa);
                grid(tempa,'on');
            end 
            tempvbox.Heights=[-4,zeros(1,4)-1];
        end
        fPos=obj.uihandles.hfig.Position;
        obj.uihandles.hfig.Position=fPos+0.01;
        obj.uihandles.hfig.Position=fPos;
    end

    function clearosc(obj,o,e) %#ok<INUSD>
        if ~obj.uihandles.init
            initosc(obj)
        end
        for i = obj.uihandles.axes1layout.Children
            delete(i)
        end
    end

    function addosc(obj,o,e) %#ok<INUSD>
        if ~obj.uihandles.init
            initosc(obj)
        end
        obj.uihandles.add=1;
    end

%     function convertosc(obj,o,e)
%     end

    function initosc(obj)
        obj.uihandles.init=1;
        t = timer;
        obj.uihandles.mtimer=t;
        t.TimerFcn = @(o,e)plottick(obj,o,e);
        t.Period = obj.uihandles.Period;
        t.ExecutionMode = 'fixedSpacing';
        start(t)
    end

    function delfunc(obj,o,e) %#ok<INUSD>
        try
            stop(obj.uihandles.mtimer);
            delete(obj.uihandles.mtimer);
        catch e
        end
        obj.uihandles.init=0;
    end

    function datas=GetoscMeasure(obj)
        %val = str2double(query(obj.interfaceobj,'MEASUrement:MEAS2:VALue?'));
        datas=zeros(11,1);
        for index1=1:8
            try
                datas(index1)=str2double(query(obj.interfaceobj,['MEASUrement:MEAS' num2str(index1) ':VALue?']));
                if datas(index1)>1e35
                    datas(index1)=0;
                end
            catch e
                datas(index1)=0;
            end
        end
        datas(9)=obj.horizontalscale;
        datas(10)=obj.horizontalposition;
        datas(11)=obj.datastop;
        % t=linspace(-obj.osc.horizontalscale/100.0*obj.osc.horizontalscale,(1-obj.osc.horizontalscale/100.0)*obj.osc.horizontalscale,obj.osc.datastop)
        % t=linspace(-datas(10)*datas(9)/100,(1-datas(10)/100)*datas(9),datas(11))
    end
end