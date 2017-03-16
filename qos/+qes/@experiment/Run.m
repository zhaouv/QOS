function Run(obj)
    % run experiment
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    
    if ~obj.IsValid()
        throw(MException('Experiment:InvalidObject',...
			'The object itself not valid or some of its handle class properties not valid.'));
    end
	if obj.runned
		throw(MException('Experiment:RunnedError',...
			'This experiment object has been runned already, when finished run, an experiment object releases all occuppied resources to be available for other applications, thus can not run again.'));
	end
    NumSweeps = numel(obj.sweeps);
    if NumSweeps == 0
        throw(MException('Experiment:noSweeps',...
			'The number of sweeps is zero, needs at least one sweep to run an experiment.'));
    end
    % in case of not the first run, swpidx and stepidx need to be
    % resetted, new datafile should also be created, otherwise the
    % experiment continues from the privious stop point and data
    % will be stored to the datafile of the previous run.
    if obj.showctrlpanel && (isempty(obj.ctrlpanel) ||~ishghandle(obj.ctrlpanel))
        obj.CreateCtrlPanel();
        obj.UpdateProgress();
    end
    obj.Reset();  % Reset sweep idexes etc.
    
    obj.datafilename = fullfile(obj.datapath,[obj.datafileprefix,...
        datestr(now,'_yymmddTHHMMSS'),num2str(99*rand(1),'%02.0f'),'_.mat']);
    NumMeasurements = numel(obj.measurements);
%             if NumMeasurements == 0
%                 error('Experiment:RunError','The number of measurements is zero, need at least one measurement to run an experiment!');
%             end
    if NumMeasurements > 0
        obj.data = cell(NumMeasurements,1);
        obj.totalsteps = prod(obj.swpsizes);
        for ii = 1:NumMeasurements
            if obj.measurements{ii}.numericscalardata
                if length(obj.swpsizes) == 1
                    obj.data{ii} = NaN*ones(obj.swpsizes,1);
                else
                    obj.data{ii} = NaN*ones(obj.swpsizes);
                end
            else
                if length(obj.swpsizes) == 1
                    obj.data{ii} = cell(obj.swpsizes,1);
                else
                    obj.data{ii} = cell(obj.swpsizes);
                end
            end
        end
    end
    NumSwps = length(obj.sweeps);
    obj.sweepvals = cell(1,NumSwps);
    obj.swpmainparam = ones(1,NumSwps);
    obj.paramnames = cell(1,NumSwps);
    for ii = 1:NumSwps
        obj.sweepvals{ii} = obj.sweeps(ii).vals;
        obj.paramnames{ii} = obj.sweeps(ii).paramnames;
        obj.swpmainparam(ii) = obj.sweeps(ii).mainparam;
    end
    NumMeasurements = length(obj.measurements);
    for ii = 1:NumMeasurements
        obj.measurementnames{ii} = obj.measurements{ii}.name;
    end
    obj.starttime = now;
    obj.log.timestamp(end+1) = now;
    obj.log.event{end+1} = 'run';
    obj.RunExperiment();
    notify(obj,'ExperimentStopped');
	obj.runned = true;

    if obj.stepsdone == obj.totalsteps % done
        obj.log.timestamp(end+1) = now;
        obj.log.event{end+1} = 'measurement done';
        obj.running = false;  
        obj.paused = false;
        if obj.savedata
            obj.SaveData(true);  % during the running process, data is
                             % saved every 30 seconds. at the end there might be
                             % some new data points not saved, so do a
                             % force saving!
        end
        obj.UpdateProgress(); % status is set within
        sound(qes.ui.sounds.notify2);
    end
    for mObj = obj.measurements
        mObj{1}.delete();
    end
    for swpObj = obj.sweeps
        swpObj.delete();
    end
	if ~isempty(obj.ctrlpanel) && ishghandle(obj.ctrlpanel)
        close(obj.ctrlpanel);  % this crashes matlab some times
    end
end