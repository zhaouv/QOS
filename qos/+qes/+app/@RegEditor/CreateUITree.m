function t = CreateUITree(obj)
    %
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
    selectedSSGroups = ['public',obj.qs.loadSSettings('selected')];
    selectedHwSGroups = obj.qs.loadHwSettings('selected');
    
    ss = uitreenode('v0', 'session settings', [obj.qs.user, '-',obj.qs.session], '.NULL', false);
	ss.setIcon(im2java(qes.app.RegEditor.ico_user()));
    for ii = 1:numel(selectedSSGroups)
		node = uitreenode('v0', selectedSSGroups{ii},  selectedSSGroups{ii},  [], true);
		node.setIcon(im2java(qes.app.RegEditor.ico_qobject()));
        ss.add(node);
    end

    hws = uitreenode('v0', 'hardware settings', 'hardware', '.NULL', false);
	hws.setIcon(im2java(qes.app.RegEditor.ico_hardware_pci()));
    for ii = 1:numel(selectedHwSGroups)
		node = uitreenode('v0', selectedHwSGroups{ii},  selectedHwSGroups{ii},  [], true);
		node.setIcon(im2java(qes.app.RegEditor.ico_hardwave_chip()));
        hws.add(node);
    end

    % Root node
    t = uitreenode('v0', 'registry', 'registry', [], false);
	t.setIcon(im2java(qes.app.RegEditor.ico_settings()));
    t.add(hws);
    t.add(ss);
end