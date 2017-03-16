function SaveData(obj,force)
    % force: force saving(default: false), if true, do saving
    % even if the last saving is less than 30 seconds ago.
    % call SaveData without extra arguments will save data once at most
    % every 30 seconds, this is to avoid too much disc I/O which
    % might be considerably slow.

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if nargin == 1
        force = false;
    end
    if ~obj.running && ~force
                     % when the process is stopped by 'Abort' rather than process completion, 
                     % the object is reset and data is erased from buffer, do a in this case
                     % SaveData will save an empty cell to disk.
                     % when stopped by process completion, data is
                     % kept is buffer until the next run.
        return;
    end
    persistent LastSavingTime

    if ~force && ~isempty(LastSavingTime) && now - LastSavingTime < 6.9440e-04 % 60 seconds
        return;
    end
    Data = obj.data;
    SweepVals = obj.sweepvals;
    ParamNames = obj.paramnames;
    SwpMainParam = obj.swpmainparam;
    Config = obj.settings;
    Config.measurement_names = obj.measurementnames;
    Config.plotfcn = '';
    Log = obj.log;
    if ~isempty(obj.plotfcn)
        Config.plotfcn = func2str(obj.plotfcn);
    end
    NumSwps = numel(obj.sweeps);
    SwpData = cell(1,NumSwps);
    for nn = 1:NumSwps
        SwpData{nn} = obj.sweeps(nn).swpdata;
    end
    Notes = obj.notes;

    maxnumtries = 5;
    for ii = 1: maxnumtries
        try
            save(obj.datafilename,'SweepVals','ParamNames','SwpMainParam','Data','SwpData','Notes','Config','Log');
        catch
            if ii < 5
                continue;
            end
             % this happens when some other program(a backup software for example) is accessing the datafile,
             % it is not problem if it dose not happen constantly.
            warning('Experiment:SaveDataFail',[datestr(now,'dd mmm HH:MM:SS'),10,'Uable to save datafile.']);
        end
    end
    LastSavingTime = now;
end