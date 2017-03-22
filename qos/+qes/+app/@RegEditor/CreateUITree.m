function t = CreateUITree(obj)
    %
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
    selectedSSGroups = ['public',obj.qs.loadSSettings('selected')];
    selectedHwSGroups = obj.qs.loadHwSettings('selected');
    
    ss = uitreenode('v0', 'user settings', 'user settings', '.NULL', false);
    for ii = 1:numel(selectedSSGroups)
        ss.add(uitreenode('v0', selectedSSGroups{ii},  selectedSSGroups{ii},  [], true));
    end

    hws = uitreenode('v0', 'hardware settings', 'hardware settings', '.NULL', false);
    for ii = 1:numel(selectedHwSGroups)
        hws.add(uitreenode('v0', selectedHwSGroups{ii},  selectedHwSGroups{ii},  [], true));
    end

    % Root node
    t = uitreenode('v0', 'Registry', 'Registry', [], false);
    t.add(hws);
    t.add(ss);
end