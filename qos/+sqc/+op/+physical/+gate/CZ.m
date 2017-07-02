function g = CZ(control_q, target_q)
	% controled Z gate
    
% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com
	import sqc.op.physical.gate.*
    
%     aczSettingsKey = sprintf('%c_%2.3f_%c_%2.3f',...
%                 control_q.name,control_q.f01/1e9,...
%                 target_q.name,target_q.f01/1e9);
            
    aczSettingsKey = sprintf('%s_%s',control_q.name,target_q.name);
            
    QS = qes.qSettings.GetInstance();
    scz = QS.loadSSettings({'shared','g_cz',aczSettingsKey});
    
	switch scz.typ
		case {'acz','ACZ'}
			g = ACZ(control_q, target_q, scz);
		otherwise
			error('unrecognized ACZ gate type: %s, available z gate options are: acz',...
				scz.typ);
	end
end
