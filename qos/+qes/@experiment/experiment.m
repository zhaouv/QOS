classdef experiment < qes.qHandle
    % experiment

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

	properties
        sweeps      % array of sweeps
        measurements    % cell array of measurements
        plotdata@logical scalar = true; % plot live data or not
        datafileprefix % datafile prefix
        notes@char    % character string, any notes
        % save data or not
        savedata@logical scalar = true
        savesnap@logical scalar = false
        % axes for data plot, if not specified, an new axes is created
        showctrlpanel@logical scalar = true; % true(default)/false show dashbord or not
        % true/false(default) save snapshot with data or not
        plotaxes
        % default plot functions are provided for simple data sets, for
        % complex data, custum plotfunctions are needed.
        plotfcn % if empty, default built-in plotfunctions are used.
        
        data % some times we use an experiment object to save data in a easy way
        sweepvals
    end
    properties (SetAccess = private)
        settings
        running = false; % true/false: idle/running
        paused = false; %
        log % logging
    end
    properties (SetAccess = private, GetAccess = private)
        paramnames
        swpmainparam
        measurementnames
        datapath
        datafilename
        swpidx
        stepidx
        totalsteps
        stepsdone
        starttime % unit: days
        ctrlpanel   % control panel gui handle, empty if disabled(showctrlpanel = false)
        % abort = true: an abort action is pending, waiting for the on
        % going measurement operation to finish to execute
        abort@logical scalar  = false
        % pause = true: a pause action is pending, waiting for the on going
        % measurement operations to finish to execute, default: false(do not change).
        pause@logical scalar = false
		runned = false
    end
    properties (SetAccess = private, GetAccess = private, Hidden = true, SetObservable = true)
        busy = false; % true, experiment is busy: setting instruments, taking data etc.
    end
    properties (SetAccess = private, GetAccess = private, Hidden = true, Dependent = true)
        swpsizes
    end
    events % notify anyone who's interested that the experiment 
        ExperimentStarted  % is running or
        ExperimentStopped  % is stopped
    end
	methods
        function obj = experiment(settingsobj)
            obj = obj@qes.qHandle('');
            if nargin == 0 % if settingsobj not giving, get the existing instance or creat one
                try
                    settingsobj = qes.qSettings.GetInstance();
                catch
                    error('experiment:GetSettingsError','qes.qSettings not created or not conditioned, creat the qes.qSettings object, select user(by using SU) and select session(by using SS) first.');
                end
            end
            if ~isa(settingsobj,'qes.qSettings')
                error('experiment:InvalidInput','settingsobj is not a valid qes.qSettings class object!');
            end
            data_saving_path = settingsobj.loadSSettings('data_path');
            if isempty(data_saving_path) || ~ischar(data_saving_path) 
                error('experiment:InvalidSettings','data_path not set or not valid, check the settings file.');
            end
            if ~exist(data_saving_path,'dir')
                error('experiment:InvalidSettings','datadir ''%s'' not exist, check the settings file.', data_saving_path);
            end
            obj.datapath = data_saving_path;
            obj.sweeps = {};
            obj.measurements = {};

            obj.settings.hw_settings = settingsobj.loadHwSettings();
            obj.settings.session_settings = settingsobj.loadSSettings();
            obj.settings.user = settingsobj.user;
            obj.log.timestamp  = now;
            obj.log.event = {'object creation'};
            addlistener(obj,'busy','PostSet',@qes.experiment.ExePauseAbort);
        end
        function set.sweeps(obj, Sweeps)
            ln = numel(Sweeps);
            for ii = 1:ln
                if ~isa(Sweeps(ii),'qes.sweep') || ~isvalid(Sweeps(ii)) ||...
                     Sweeps(ii).size == 0
                    error('experiment:SetSweeps','At least one of the sweeps is not a valid Sweep class object or has zero sweep size!');
                end
            end
            obj.sweeps = Sweeps;
        end
%         function set.sweeps(obj, Sweeps)
%             if iscell(Sweeps)
%                 for ii = 1:length(Sweeps)
%                     if ~isa(Sweeps{ii},'qes.sweep') || ~isvalid(Sweeps{ii}) ||...
%                          Sweeps{ii}.size == 0
%                         error('experiment:SetSweeps','At least one of the sweeps is not a valid Sweep class object or has zero sweep size!');
%                     end
%                 end
%                 obj.sweeps = Sweeps;
%             else
%                 ln = numel(Sweeps);
%                 temp = cell(1,ln);
%                 for ii = 1:ln
%                     if ~isa(Sweeps(ii),'qes.sweep') || ~isvalid(Sweeps(ii)) ||...
%                          Sweeps(ii).size == 0
%                         error('experiment:SetSweeps','At least one of the sweeps is not a valid Sweep class object or has zero sweep size!');
%                     else
%                         temp(ii) = {Sweeps(ii)};
%                     end
%                 end
%                 obj.sweeps = temp;
%             end
%         end
        function set.measurements(obj, Measurements)
            if iscell(Measurements)
                for ii = 1:length(Measurements)
                    if ~isa(Measurements{ii},'Measurement') || ~isvalid(Measurements{ii})
                        error('experiment:SetMeasurements','At least one of the Measurements is not a valid Measurement class object!');
                    end
                end
                obj.measurements = Measurements;
            else
                ln = numel(Measurements);
                temp = cell(1,ln);
                if ln > 1
                    for ii = 1:ln
                        if ~isa(Measurements(ii),'Measurement') || ~isvalid(Measurements(ii))
                            error('experiment:SetMeasurements','At least one of the Measurements is not a valid Measurement class object!');
                        else
                            temp(ii) = {Measurements(ii)};
                        end
                    end
                else % Measurement is now callable
                    if ~isa(Measurements,'qes.measurement.measurement') || ~isvalid(Measurements)
                        error('experiment:SetMeasurements','At least one of the Measurements is not a valid measurement class object!');
                    else
                        temp = {Measurements};
                    end
                end
                obj.measurements = temp;
            end
        end
        function set.datafileprefix(obj, val)
            if ~isvarname(val)
                error('experiment:SetDatafileprefix','not a valid file name!');
            end
            obj.datafileprefix = val;
        end
        function addSettings(obj,fieldNames,vals)
            % add settings to save with data
            if ~iscell(fieldNames)
                fieldNames = {fieldNames};
            end
            if ~iscell(vals)
                fieldNames = {vals};
            end
            if numel(fieldNames) ~= numel(vals)
                error('experiment:inValidInput','fieldNames and vals length not match.');
            end
            for ii = 1:numel(fieldNames)
                % removed for convenience
%                 if ~isvarname(fieldNames{ii})
%                     error('experiment:inValidInput','%s is not a valid field name.', fieldNames{ii});
%                 end
%                 if isfield(obj.settings,fieldNames{ii})
%                     error('experiment:inValidInput','%s already exist in settings, overwriting an existing field is not allowed.', fieldNames{ii});
%                 end
                obj.settings.(fieldNames{ii}) = vals{ii};
            end
        end
        function set.showctrlpanel(obj,val)
            if ~islogical(val)
                if val == 0 || val == 1
                    val = logical(val);
                else
                    error('experiment:SetShowctrlpanel','showctrlpanel should be a bolean!');
                end
            end
            obj.showctrlpanel = val;
            if ~obj.showctrlpanel
                if ~isempty(obj.ctrlpanel) && ishghandle(obj.ctrlpanel)
                    close(obj.ctrlpanel);
                    obj.ctrlpanel = [];
                end
            end
        end
        function set.plotaxes(obj,val)
            if ~isempty(val) && ~ishghandle(val)
                error('experiment:SetPlotAxes','not a axes handle.');
            end
            obj.plotaxes = val;
        end
        function set.plotfcn(obj,val)
            if ~isempty(val) && ~isa(val,'function_handle')
                error('experiment:SetPlotFcn','not a function handle.');
            end
            obj.plotfcn = val;
        end
        function val = get.swpsizes(obj)
            if isempty(obj.sweeps)
                val = [];
                return;
            end
            val = arrayfun(@(x) x.size, obj.sweeps);
        end
        PlotData(obj)
        Run(obj)
        % some times we use an experiment object to save data in a easy way
        SaveData(obj,force)
        function bol = IsValid(obj)
            % check the validity of hanlde properties and the object itself
            if ~isvalid(obj)
                bol = false;
                return;
            end
            bol = true;
            for ii = 1:length(obj.sweeps)
                if ~IsValid(obj.sweeps(ii)) 
                    bol = false;
                    return;
                end
            end
            for ii = 1:length(obj.measurements)
                if ~IsValid(obj.measurements{ii})
                    bol = false;
                    return;
                end
            end
        end
        function delete(obj)
            if ~isempty(obj.ctrlpanel) && ishghandle(obj.ctrlpanel)
                if ~isempty(obj.plotaxes) && ishghandle(obj.plotaxes)
                    close(get(obj.plotaxes,'parent'));
                end
                close(obj.ctrlpanel);  % this crashes matlab some times
            end
        end
    end
    methods (Access = private, Hidden = true)
        RunExperiment(obj)
        UpdateProgress(obj)
        CreateCtrlPanel(obj)
        function Reset(obj)
            % Reset a running process. only to be called privatly.
            obj.data = {};
            obj.swpidx = 1;
            obj.stepidx = zeros(1,numel(obj.sweeps));
            for ii = 1:length(obj.sweeps)
                obj.sweeps(ii).Reset();
            end
            for ii = 1:length(obj.measurements)
                obj.measurements{ii}.Abort();
            end
            obj.stepsdone = 0;
            obj.starttime = [];
            obj.running = false; % idle
            obj.abort = false; % clear pending status
            obj.pause = false; % clear pending status
            obj.paused = false;
            obj.UpdateProgress();
            obj.log.timestamp  = now;
            obj.log.event = {'rest'}; % old log also cleared
        end
    end
    methods (Static = true, Access = protected, Hidden = true)
        function ExePauseAbort(metaProp,eventData)
            % execute pending abort or pause action
            obj = eventData.AffectedObject;
            if isempty(obj.busy) || obj.busy
                return;
            end
            if obj.abort % abort shadows pause
                obj.log.timestamp(end+1) = now;
                obj.log.event{end+1} = 'abort';
                SaveData(obj,1);
                obj.Reset();
                obj.abort = false; % clear pending status
            elseif obj.pause
                obj.log.timestamp(end+1) = now;
                obj.log.event{end+1} = 'pause';
                obj.paused = true;
                obj.pause = false; % clear pending status
            end
        end
    end
end