classdef blochSphere < handle
    % blochSphere visulizes single qubit states
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        showToolbar = false
        showMenubar = false
        drawHistory = false % draw history or not
        arrorTransparency
        color % numStates by 3 to specify color for each state, default is all red
        title = 'Bloch Sphere'
    end
    properties (SetAccess = private)
        numStates
    end
    properties (GetAccess = private, SetAccess = private)
        ax       
        states = {}

        theta
        phi
        
        handles
        arrows
        historyLine
    end
    properties (GetAccess = private, Constant = true)
        SPHERE_RESOLUTION = 128
        SPHERE_TRANSPARENCY = 0.2
    end
    methods
        function obj = blochSphere(ax_, ns)
            if nargin ~=0 
                obj.ax = ax_;
            end
            if nargin < 2
                obj.numStates = 1;
            else
                obj.numStates = ns;
            end
            obj.states = cell(1,obj.numStates);
            obj.arrorTransparency = ones(1,obj.numStates);
            obj.color = repmat([1,0,0],obj.numStates,1);
            obj.arrows = NaN*ones(1,obj.numStates);
            obj.historyLine = NaN*ones(1,obj.numStates);
            
            obj.theta = NaN*ones(1,obj.numStates);
            obj.phi = NaN*ones(1,obj.numStates);
        end
        function set.drawHistory(obj,val)
            val = logical(val);
            if val == obj.drawHistory
                return;
            end
            if ~val
                for ii = 1:obj.numStates
                    if ishghandle(obj.historyLine(ii))
                        delete(obj.historyLine(ii));
                    end
                end
            else
                obj.checkFigure(obj);
                for ii = 1:obj.numStates
                    obj.historyLine(ii) = line(NaN, NaN, NaN,...
                        'Marker','.','Color', obj.color(ii,:),...
                        'LineStyle','none');
                end
            end
            obj.drawHistory = val;
        end
        function addState(obj,state,stateIdx,drawNow)
            if nargin < 3
                stateIdx = 1;
            end
            if nargin < 4
                drawNow = false;
            end
            if isempty(state)
                obj.states{stateIdx} = [];
                obj.theta(stateIdx) = NaN;
                obj.phi(stateIdx) = NaN;
                if drawNow
                    obj.checkFigure(obj);
                    obj.plotStateArrow(obj,stateIdx);
                end
                return;
            end
            if ~isa(state,'sqc.qs.state')
                throw(MException('QOS_blochSphere:invalidInput',...
                    'sate not a quantum state.'));
            end
            if size(state.v,2) ~= 2
                throw(MException('QOS_blochSphere:invalidInput',...
                    'state not a single qubit quantum state.'));
            end
            if stateIdx > obj.numStates
                throw(MException('QOS_blochSphere:stateIdxOutOfRange',...
                    sprintf('stateIdx %0.0f out of range, maximum: %0.0f.',...
                    stateIdx, obj.numStates)));
            end
            obj.states{stateIdx} = state;
            
            vs = obj.states{stateIdx}.v;
            a = angle(vs(1));
%             if obj.drawHistory
%                 idx = find(~isnan(obj.theta_his(:,stateIdx)),1,'last');
%                 if isempty(idx)
%                     obj.theta_his = [obj.theta_his;NaN*ones(1,ns)];
%                     obj.phi_his = [obj.phi_his;NaN*ones(1,ns)];
%                     idx = size(obj.phi_his,1);
%                 end
%                 obj.theta_his(idx,stateIdx) = obj.theta(stateIdx);
%                 obj.phi_his(idx,stateIdx) = obj.phi(stateIdx);
%             end
            obj.theta(stateIdx) = real(2*acos(vs(1)*exp(-1j*a)));
            obj.phi(stateIdx) = real(...
                log((vs(2)*exp(-1j*a))/sin(obj.theta(stateIdx)/2))/1j);
            if drawNow
                obj.checkFigure(obj);
                obj.plotStateArrow(obj,stateIdx);
            end
        end
        function draw(obj)
            ns = obj.numStates;
            obj.checkFigure(obj);
            for ii = 1:ns
                obj.plotState(obj,ii);
            end
        end
        function clear(obj)
            
        end
    end
    methods (Access = private, Static  = true)
        function plotSphere(obj)
            [xSph, ySph, zSph] = sphere(obj.SPHERE_RESOLUTION);
            obj.handles.sphere = surf(obj.ax, xSph, ySph, zSph, ones(size(zSph)), ...
                            'FaceColor', 'blue', 'EdgeColor', 'none', ...
                            'FaceAlpha', obj.SPHERE_TRANSPARENCY);
            obj.handles.lightSource = light();
            obj.handles.lightSource.Style = 'infinite';  % or local
            obj.handles.lightSource.Color = [1,1,1];
            obj.handles.lightSource.Position = [1,0,1];
            line( [-1.2 1.2], [0 0],  [0 0],  'Color', 'b', 'LineStyle', '-','parent',obj.ax);
            line( [0 0],  [-1.2 1.2], [0 0],  'Color', 'b', 'LineStyle', '-','parent',obj.ax);
            line( [0 0],  [0 0],  [-1.2 1.2], 'Color', 'b', 'LineStyle', '-','parent',obj.ax);
            text(1.4,0,0,'|0>+|1>','parent',obj.ax);
            text(-1.4,0,0,'|0>-|1>','parent',obj.ax);
            text(0,1.4,0,'|0>+i|1>','parent',obj.ax);
            text(0,-1.4,0,'|0>-i|1>','parent',obj.ax);
            text(0,0,1.4,'|0>','parent',obj.ax);
            text(0,0,-1.4,'|1>','parent',obj.ax);
            angle = linspace( 0, 2*pi, 128);
            sinA = sin(angle);
            cosA = cos(angle);
            zeroA = zeros(size(angle));
            line(sinA,  cosA,  zeroA, 'Color', 'b', 'LineStyle', ':','parent',obj.ax);
            line(zeroA, sinA,  cosA,  'Color', 'b', 'LineStyle', ':','parent',obj.ax);
            line(sinA,  zeroA, cosA,  'Color', 'b', 'LineStyle', ':','parent',obj.ax);
            set(obj.ax,'XLim',[-1.2,1.2],'YLim',[-1.2,1.2],'ZLim',[-1.2,1.2],'Visible','off');
            daspect(obj.ax, [1 1 1]);
        end
        function checkFigure(obj)
            if isempty(obj.ax) || ~ishghandle(obj.ax)
                hf = qes.ui.qosFigure(obj.title,false);
                set(hf,'ToolBar','none','MenuBar','none');
                obj.ax = axes('Parent',hf,'Position',[-0.25,-0.25,1.5,1.5]);
                if obj.showToolbar
                    set(hf,'ToolBar','figue');
                end
                if obj.showMenubar
                    set(hf,'MenuBar','figue');
                end
            end
            if ~isfield(obj.handles,'sphere') || isempty(obj.handles.sphere) ||...
                    ~ishghandle(obj.handles.sphere)
                obj.plotSphere(obj);
            end
        end
        function plotState(obj,stateIdx)
            if isnan(obj.phi(stateIdx))
                if ishghandle(obj.arrows(stateIdx))
                    delete(obj.arrows(stateIdx));
                end
                return;
            end
            [xCur yCur zCur] = sph2cart(obj.phi(stateIdx), pi/2-obj.theta(stateIdx), 1);
            if ishghandle(obj.arrows(stateIdx))
                delete(obj.arrows(stateIdx));
            end
            obj.arrows(stateIdx) = qes.ui.mArrow3([0,0,0],[xCur,yCur,zCur],...
                    'color',obj.color(stateIdx,:),'stemWidth',0.015,...
                    'facealpha',obj.arrorTransparency(stateIdx));
            if obj.drawHistory
                xData = get(obj.historyLine(stateIdx),'XData');
                yData = get(obj.historyLine(stateIdx),'YData');
                zData = get(obj.historyLine(stateIdx),'ZData');
                set(obj.historyLine(stateIdx),...
                    'XData',[xData,xCur],...
                    'YData',[yData,yCur],...
                    'ZData',[zData,zCur]);
            end
        end
        function plotHistory(obj)
            if ~obj.drawHistory
                return;
            end
            if numel(obj.handles.trace) == 1 && isnan(obj.handles.trace)
                ns = numel(obj.states);
                for ii = 1:ns
                    obj.handles.hisLine(ii) =...
                        line(obj.xHis, handles.yHis, handles.zHis, 'Marker','.','Color', 'b');
                end
            end
        end
    end
end

