function PlotData(obj)
    % 

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    if ~obj.plotdata || isempty(obj.data) || isempty(obj.data{1})
        return;
    end
    if isempty(obj.plotaxes) || ~ishghandle(obj.plotaxes)
        h = figure('NumberTitle','off','Name',['Experiment: ',obj.name],'Color',[1,1,1]);
        obj.plotaxes = axes('Parent',h);
    end
    hold(obj.plotaxes,'off');
    if ~isempty(obj.plotfcn)
        try
            feval(obj.plotfcn,obj.data,obj.sweepvals,obj.paramnames,obj.swpmainparam,obj.measurementnames,obj.plotaxes);
        catch ME
            disp('Plotting failed, the given plot function unable to plot the current data set.');
            rethrow(ME)
        end
        return;
    end
    NumMeasurements = numel(obj.data);
    switch NumMeasurements
        case 0 % no measurements
            return;
        case 1 % single measuremts, almost all experiments are of this type
            try
                qes.util.plotfcn.OneMeas_Def(obj.data,obj.sweepvals,obj.paramnames,obj.swpmainparam,obj.measurementnames,obj.plotaxes);
            catch
                warning('Experiment:PlotFail','unable to plot, data might be too complex, a dedicated plotting function is needed.');
            end
        case 2
            warning('Experiment:PlotFail','data might be too complex, a dedicated plotting function is needed.');
            return;   % todo
        otherwise
            warning('Experiment:PlotFail','data might be too complex, a dedicated plotting function is needed.');
            return; % todo
    end
    drawnow;
end