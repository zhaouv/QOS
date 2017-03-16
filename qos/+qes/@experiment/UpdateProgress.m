function UpdateProgress(obj)
%

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    str1 = '';
    if isempty(obj.stepidx)
         obj.stepidx = zeros(1,numel(obj.sweeps));
    end
    for ii = 1:length(obj.swpsizes)
        tempstr = sprintf('Sweep %d: %d of %d', ii,obj.stepidx(ii),obj.swpsizes(ii));
        str1 = [str1,tempstr, ' | '];
    end
    if isempty(obj.starttime)
        Progress = 0;
        str2 = 'Idle';
    elseif obj.stepsdone == 0
        Progress = 0;
        if obj.paused
            str2 = ['Paused'];
        else
            str2 = ['Running'];
        end
    else
        Progress = obj.stepsdone/obj.totalsteps;
        str2 = [num2str(100*Progress,'%0.0f'), '%,'];
        TimeTaken = now - obj.starttime; % days
        TimeLeft = (obj.totalsteps-obj.stepsdone)/obj.stepsdone*TimeTaken*24;
        hh = floor(TimeLeft);
        mm = round(60*mod(TimeLeft,1));
        if obj.paused
            str2 = ['Paused: ',str2,'   ',...
                num2str(hh,'%0.0f'), ' hr ',num2str(mm,'%0.0f'),' min left'];
        else
            str2 = ['Running: ',str2,'   ',...
                num2str(hh,'%0.0f'), ' hr ',num2str(mm,'%0.0f'),' min left'];
        end
    end
    if obj.stepsdone == obj.totalsteps
        str2 = 'Done!';
    end
    if isempty(obj.ctrlpanel) ||~ishghandle(obj.ctrlpanel) % no ctrlpanel, print to command window
        home();
        disp(str1);
        disp(str2);
    else
        ProgressInfoStr = str2;
        handles = guidata(obj.ctrlpanel);
        qes.ui.waitbar2a(Progress, handles.ProgressBar,ProgressInfoStr);
    end
end