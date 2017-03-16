function RunExperiment(obj)
    % This is a private method, call public method Run to run an experiment.
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    notify(obj,'ExperimentStarted'); % this has to be here, not outside this function.
    obj.running = true; % running
    NumSweeps = numel(obj.sweeps);
    NumMeasurements = numel(obj.measurements);
    persistent lastprogundationtime
    if isempty(lastprogundationtime)
        lastprogundationtime  = now;
    end
    persistent lastplottime
    if isempty(lastplottime)
        lastplottime  = now;
    end
    obj.UpdateProgress();
    obj.PlotData();
    while obj.swpidx > 0
        if obj.sweeps(obj.swpidx).IsDone()
            obj.sweeps(obj.swpidx).Reset();
            obj.stepidx(obj.swpidx) = obj.sweeps(obj.swpidx).idx;
            obj.swpidx = obj.swpidx - 1;
            continue;
        end
        obj.busy = true;
        if obj.abort
            return;
        end
        obj.stepidx(obj.swpidx) =  obj.sweeps(obj.swpidx).idx;
        obj.sweeps(obj.swpidx).Step();
        if obj.swpidx < NumSweeps
            obj.swpidx = obj.swpidx + 1;
            continue;
        end
        % Run measurements
        for ii = 1:NumMeasurements
            obj.measurements{ii}.Run();
        end
        % Get data
        for ii = 1:NumMeasurements
            tic;
            while 1
                if obj.measurements{ii}.dataready || toc > obj.measurements{ii}.timeout
                    idx = sub2ind_(size(obj.data{ii}),obj.stepidx);
                    obj.stepsdone = obj.stepsdone + 1;
                    if obj.measurements{ii}.numericscalardata
                        obj.data{ii}(idx) = obj.measurements{ii}.data;
                    else
                        obj.data{ii}(idx) =  {obj.measurements{ii}.data};
                    end
                    break;
                end
                pause(0.05);
            end
        end
       % save data
       if obj.savedata
           obj.SaveData(); % call SaveData without extra arguments will save data once
                           % at most every 30 seconds, this is to avoid too much
                           % disc I/O, which might be considerably slow.
       end
       if obj.showctrlpanel && (isempty(obj.ctrlpanel) ||~ishghandle(obj.ctrlpanel))
             obj.CreateCtrlPanel();
       end
       obj.busy = false;
       if now - lastprogundationtime > 5.7870e-05 % 5 seconds
            obj.UpdateProgress();
            lastprogundationtime = now;
       end
       if now - lastplottime > 5.7870e-05 % 5 seconds
            obj.PlotData();
            lastplottime = now;
       end
       % plot data
       
       if obj.paused || ~obj.running
           return;
       end
    end
    obj.UpdateProgress();
    obj.PlotData();
end

function ndx = sub2ind_(siz,subindx)
    % a modification of Matlab SUB2IND.
    siz = double(siz);
    lensiz = length(siz);
    if lensiz < 2
        error(message('MATLAB:sub2ind_:InvalidSize'));
    end

    numOfIndInput = length(subindx);
    if lensiz < numOfIndInput
        %Adjust for trailing singleton dimensions
        siz = [siz, ones(1,numOfIndInput-lensiz)];
    elseif lensiz > numOfIndInput
        %Adjust for linear indexing on last element
        siz = [siz(1:numOfIndInput-1), prod(siz(numOfIndInput:end))];
    end

    if numOfIndInput == 2

        v1 = subindx(1);
        v2 = subindx(2);
        if ~isequal(size(v1),size(v2))
            %Verify sizes of subscripts
            error('SubscriptVectorSize');
        end
        if any(v1(:) < 1) || any(v1(:) > siz(1)) || ...
           any(v2(:) < 1) || any(v2(:) > siz(2))
            %Verify subscripts are within range
            error('IndexOutOfRange');
        end
        %Compute linear indices
        ndx = v1 + (v2 - 1).*siz(1);

    else

        %Compute linear indices
        k = [1 cumprod(siz(1:end-1))];
        ndx = 1;
        s = size(subindx(1)); %For size comparison
        for i = 1:numOfIndInput
            v = subindx(i);
            %%Input checking
            if ~isequal(s,size(v))
                %Verify sizes of subscripts
                error('SubscriptVectorSize');
            end
            if (any(v(:) < 1)) || (any(v(:) > siz(i)))
                %Verify subscripts are within range
                error('IndexOutOfRange');
            end
            ndx = ndx + (v-1)*k(i);
        end
    end
end