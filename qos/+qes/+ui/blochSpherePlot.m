function ax = blochSpherePlot( varargin )
% blochSpherePlot Displays the Bloch sphere representation of a system
%   blochSpherePlot plots a transulcent sphere to a set of axes and draws a
%   radial line to represent the supplied state. Optionally, a trace
%   representing the historical states will be drawn on the sphere.
%
%   The function returns a handle to the axes it drew the plot on.
%
%   Syntax :
%
%     ax = blochSpherePlot( theta, phi)
%       Plot a Bloch sphere into the current axes with the state being
%       displayed at inclination 'theta' and azimuthal angle 'phi'. The axes are
%       cleared before plotting.
%
%     ax = blochSpherePlot( theta, phi, 'replot')
%       Plot a Bloch sphere into the current axes to a set of axes that
%       blochSpherePlot has plotted to before. The current state is drawn as a
%       radial line, and a line on the surface of the sphere joins each of the
%       previous theta,phi pairs blochSpherePlot has been called with since
%       the last call without 'replot' appended.
%
%     ax = blochSpherePlot( 'ClearHistory' )
%       Do not plot anything, but clear the plot history, and remove the current
%       state from the plot.
%
%     ax = blochSpherePlot( ax, ...)
%       All of the preceeding calling patterns can be modified to plot to a 
%       specified set of axes by adding an axes handle to the start of the 
%       argument list.
%
%   N.B. this function will write to the UserData property of the axes, so
%   nobody else should.
%
%   Examples : 
%
%     Plot a Bloch sphere with theta = 0.5 and phi = 1 :
%       ax = blochSpherePlot( 1, 0.5);
%     Now plot 2 extra theta,phi pairs, with a history line joining the previous
%     states :
%       blochSpherePlot( ax, 2, 1, 'replot');
%       blochSpherePlot( ax, 2, 1.5, 'replot');

% Copyright 2009 The MathWorks, Inc.

%   Parse the input arguments


% If the first argument is an axis handle :
%   The two argument patterns are (axes handle, string) or ...
%   (axes handle, theta, phi, ...). Hence we ensure that we have 2 arguments, 
%   with the second a string, or at least 3 arguments, for the first argument
%   to plausibly be an axes handle.
%   We have to go through these contortions, as if we are called with an
%   argument pattern such as (theta, phi), with theta = 0, ishghandle(theta)
%   would be true (as 0 is the root handle). Thus we cannot dummly siphon off
%   the first argument with no regard for context.
if ( (nargin == 2 && ischar(varargin{2})) || (nargin > 2) ) && ...
                        ishandle( varargin{1} )
    % Capture the handle and remove it from the argument list.
    ax = varargin{1};
    remainingArgs = {varargin{2:end}};
 else
    % We will use the current axes
    ax = gca;
    remainingArgs = varargin;
end


% Ensure the correct number of arguments, noting that we will have already
% removed the axis handle from remainingArgs, if a valid axis handle was the 
% first argument.
if ~any( length(remainingArgs) == [1 2 3] )
    error('Wavefunction:invalidArgument', 'Incorrect number of arguments');
end



% Flags for all of the different possible modes.
modePlot = 0;
modeReplot = 1;
modeClearHistory = 2;


if length(remainingArgs) == 1
    % If the 'ClearHistory' mode is to be selected
    if strcmp( remainingArgs{1}, 'ClearHistory' ) 
        mode = modeClearHistory;
    else
        error('Wavefunction:invalidArgument', ...
                        'Unknown string argument ''%s''', remainingArgs{1});
    end
elseif length(remainingArgs) == 3
    if strcmp(remainingArgs{3},'replot')
        mode = modeReplot;
    else
        error('Wavefunction:invalidArgument', ...
                'Unknown string argument ''%s''',remainingArgs{3});
    end
else
    mode = modePlot;
end



% A parameter setting the maximum change in angle between two theta,phi pairs
% before extra line segments are added between the points to ensure that 
% the history line stays on the sphere surface. 
maxStretchAngle = 0.1;

% Handles to any UserData we previously stored in the axes
handles = get( ax, 'UserData');


%   Now we can generate the plot

%   Set our axes as the current axes, as 'line' only draws to the current
%   axes
% First, find the parent figure handle.
h = ancestor(ax,'Figure');

% Then set it as the current figure
set(0,'CurrentFigure',h);

% And set that figure's current axes
set(h,'CurrentAxes',ax);


if mode == modePlot || mode == modeReplot
    theta = remainingArgs{1};
    phi = remainingArgs{2};
    
    % Convert the current state to cartesian coordinates, noting the different 
    % coordinate definitions of sph2cart, and using a unit radius.
    numA = numel(phi);
    xCur = zeros(1,numA);
    yCur = zeros(1,numA);
    zCur = zeros(1,numA);
    for ii = 1:numA
        [xCur(ii) yCur(ii) zCur(ii)] = sph2cart( phi(ii), pi/2-theta(ii), 1);
    end
else
    theta = [];
    phi = [];
end


% If we need to redraw the complete plot
if mode == modePlot
    cla(ax);

    % Calculate the surface parameters for a unit radius sphere, centred on
    % zero.
    [xSph, ySph, zSph] = sphere(128);

    % Draw the sphere to the axes. Set the sphere to be blue and translucent.
    SPHERE_TRANSPARENCY =0.2;
    surf( ax, xSph, ySph, zSph, ones(size(zSph)), ...
                            'FaceColor', 'blue', 'EdgeColor', 'none', ...
                            'FaceAlpha', SPHERE_TRANSPARENCY);
    
    h = light;
    h.Style = 'infinite';  % local
    h.Color = [1,1,1];
    h.Position = [1,0,1];

    % Set the plot axes as invisible, and ensure that the aspect ratio is
    % such that our sphere is spherical.
    axis( ax, 'off');
    daspect( ax, [1 1 1]);

    % Draw the dotted/dashed x,y,z axis lines
    line( [-1.2 1.2], [0 0],  [0 0],  'Color', 'b', 'LineStyle', '-','parent',ax);
    line( [0 0],  [-1.2 1.2], [0 0],  'Color', 'b', 'LineStyle', '-','parent',ax);
    line( [0 0],  [0 0],  [-1.2 1.2], 'Color', 'b', 'LineStyle', '-','parent',ax);
    text(1.3,0,0,'|0>+|1>','parent',ax,'FontSize',14);
    text(-1.4,0,0,'|0>-|1>','parent',ax,'FontSize',14);
    text(0,1.4,0,'|0>+i|1>','parent',ax,'FontSize',14);
    text(0,-1.4,0,'|0>-i|1>','parent',ax,'FontSize',14);
    text(0,0,1.4,'|0>','parent',ax,'FontSize',14);
    text(0,0,-1.4,'|1>','parent',ax,'FontSize',14);
    
%     text(1.4,0,0,'X','parent',ax);
%     text(0,1.4,0,'Y','parent',ax);
%     text(0,0,1.4,'Z','parent',ax);
    
    set(ax,'XLim',[-1.2,1.2],'YLim',[-1.2,1.2],'ZLim',[-1.2,1.2]);

    % Draw dotted circles around theta=pi/2, phi=0 and phi=pi/2.
    angle = linspace( 0, 2*pi, 128);
    sinA = sin(angle);
    cosA = cos(angle);
    zeroA = zeros(size(angle));
    line( sinA,  cosA,  zeroA, 'Color', 'b', 'LineStyle', ':');
    line( zeroA, sinA,  cosA,  'Color', 'b', 'LineStyle', ':');
    line( sinA,  zeroA, cosA,  'Color', 'b', 'LineStyle', ':');

    
    % Finally, save the current state as to the history.
    
    handles.xHist = xCur;
    handles.yHist = yCur;
    handles.zHist = zCur;
    
    handles.historyLine = -1;
    
elseif mode == modeReplot
    % Delete the (old) radial data line.
    if ishandle(handles.dataLine)
        delete(handles.dataLine);
    end
    
    % Decide whether the change in angle between this this theta,phi and
    % the last is large enough to warrant extra interpolated points between
    % them. Note that we have to check if the last call cleared the history by
    % ensuring the presence of handles.lastPhi and handles.lastTheta
    if ~isempty( handles.lastPhi ) && ~isempty( handles.lastTheta ) && ...
              ( (phi-handles.lastPhi) > maxStretchAngle || ...
                (theta-handles.lastTheta) > maxStretchAngle )
        stretchAngle = max( phi-handles.lastPhi, theta-handles.lastTheta);
        
        % Number of interpolated points needed
        nInterp = ceil(stretchAngle / maxStretchAngle);
        
        % Generate the points
        interpPhi = linspace( handles.lastPhi, phi, nInterp);
        interpTheta = linspace( handles.lastTheta, theta, nInterp);
        
        % Remove the first point as it is already represented in the
        % history
        interpPhi = interpPhi(2:end);
        interpTheta = interpTheta(2:end);
        
        % Calculate the cartesian coordinates of the new points, and add
        % them to the history, using a unit radius.
        [interpX interpY interpZ] = sph2cart( interpPhi, pi/2-interpTheta, 1);
        
        handles.xHist = [handles.xHist interpX];
        handles.yHist = [handles.yHist interpY];
        handles.zHist = [handles.zHist interpZ];
    else
        % No interpolation needed, just add the current point to the
        % history
        handles.xHist = [handles.xHist xCur];
        handles.yHist = [handles.yHist yCur];
        handles.zHist = [handles.zHist zCur];
    end
    
    % And plot the history, creating a new line if one does not exist
    % already, otherwise updating the data of the current line.
    if ishandle(handles.historyLine)
        % Update current line
        set( handles.historyLine, 'XData', handles.xHist);
        set( handles.historyLine, 'YData', handles.yHist);
        set( handles.historyLine, 'ZData', handles.zHist);
    else
        handles.historyLine = ...
            line( handles.xHist, handles.yHist, handles.zHist, 'Color', 'b');
    end    
    
elseif mode == modeClearHistory
    % We need to delete both the radial line and the history line
    
    if ishandle( handles.dataLine )
        delete(handles.dataLine);
    end
    
    if ishandle( handles.historyLine )
        delete(handles.historyLine);
    end
    
    % And clear the history.
    handles.xHist = [];
    handles.yHist = [];
    handles.zHist = [];

end



% Plot the radial 'state' line itself.
if mode == modePlot || mode == modeReplot
    % Plot the (thick, red) radial data line.
%     handles.dataLine = line( [0 xCur], [0 yCur], [0 zCur], ...
%                                'Color', 'r', 'Linewidth', 2);
    if numA == 1
        handles.dataLine = qes.ui.mArrow3([0,0,0],[xCur(1),yCur(1),zCur(1)],...
            'color',[1,0,0],'stemWidth',0.02,...
            'facealpha',1);
    else
        fa = linspace(1,0.05,numA);
        handles.dataLine = [];
        for ii = numA:-1:1
            ho = qes.ui.mArrow3([0,0,0],[xCur(ii),yCur(ii),zCur(ii)],...
                'color',[1,0,0],'stemWidth',0.015,...
                'facealpha',fa(ii));
            handles.dataLine = [handles.dataLine,ho];
        end
    end
end



% Save the current values of theta, phi.
handles.lastPhi = phi;
handles.lastTheta = theta;


% Save the handles to the axes UserData in case we are called again in replot
% mode.
set(gca,'UserData',handles);