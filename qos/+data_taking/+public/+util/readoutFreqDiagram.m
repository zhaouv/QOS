function readoutFreqDiagram(qubits,maxSidebandFreq)

%

% Copyright 2017 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if nargin < 2
        maxSidebandFreq = 500e6;
    end
    if nargin < 1
        qubits = {};
    end

    try
        QS = qes.qSettings.GetInstance();
    catch
        throw(MException('QOS_readoutFreqDiagram:qSettingsNotCreated',...
			'qSettings not created: create the qSettings object, set user and select session first.'));
    end
	
    if isempty(qubits)
        qubits = sqc.util.loadQubits();
    else
        if ~iscell(qubits)
            qubits = {qubits};
        end
        for ii = 1:numel(qubits)
            if isa(qubits{ii},'sqc.qobj.qubit')
                continue;
            elseif ischar(qubits{ii})
                qubits{ii} = sqc.util.qName2Obj(qubits{ii});
            else
                throw(MException('QOS_readoutFreqDiagram:illegalArgument',...
                    'at least one of qubits is not a qubit name or a qubit object.'));
            end
        end
    end
    numQs = numel(qubits);
    fr = NaN*ones(1,numQs);
    fci = NaN*ones(1,numQs);
    qNames = cell(1,numQs);
    for ii = 1:numQs
        fr(ii) = qubits{ii}.r_fr;
        fci(ii) = qubits{ii}.r_fc;
        qNames{ii} = qubits{ii}.name;
    end
    
    mfr = mean(fr)/1e9;
    flb = max(mfr)-maxSidebandFreq/1e9;
    fub = min(mfr)+maxSidebandFreq/1e9;
    
    h = qes.ui.qosFigure('Readout Resonator Freq. Diagram',true);
    pos = get(h,'Position');
    pos(2) = pos(2) - pos(4);
    pos(4) = 2*pos(4);
    set(h,'Position',pos);
    ax = axes('parent',h,'Box','on','XGrid','on','YGrid','on','GridLineStyle','--');
    pos = get(ax,'Position');
    pos(3) = 0.9*pos(3);
    set(ax,'Position',pos);
    hold(ax,'on');
    for ii = 1:numQs
        line([ii-0.5,ii+0.5],[fr(ii),fr(ii)]/1e9,...
            'Parent',ax,'LineStyle','-',...
            'LineWidth',2);
    end
    set(ax,'XTick',1:numQs,'XTickLabels',qNames);
    ylabel(ax,'frequency(GHz)');
    set(ax,'XLim',[0,numQs+1],'YLim',[flb,fub]);

    if numel(unique(fci)) == 1
        fc = fci(1);
    else
        warning('qubits have different readout fc values.');
        fc = 1e9*mfr;
    end
    fcline = line([0,numQs+1],[fc,fc]/1e9,...
            'Parent',ax,'LineStyle','--','Color',[1,0,0],...
            'LineWidth',2);

    sbFreqs = fr - fc;
    c_sbFreqs = (fc - sbFreqs)/1e9;
    c_sbFreqsline = fcline;
    for ii = 1:numQs
        c_sbFreqsline(ii) = line([0,numQs+1],[c_sbFreqs(ii),c_sbFreqs(ii)],...
            'Parent',ax,'LineStyle',':','Color',[1,0,0],...
            'LineWidth',1);
    end
        
    pos = [pos(1)+pos(3)+0.05 pos(2) 0.05 pos(4)];
    sld = uicontrol('Parent',h,'Style', 'slider',...
        'Min',flb,'Max',fub,'Value',mfr,...
        'Units','normalized','Position', pos,... 
        'Callback', @sldFunc); 
    
    function sldFunc(~,~)
        fc = 1e9*get(sld,'Value');
        set(fcline,'YData',[fc,fc]/1e9);
        sbFreqs = fr - fc;
        c_sbFreqs = (fc - sbFreqs)/1e9;
        for ii = 1:numQs
            set(c_sbFreqsline(ii),'YData',[c_sbFreqs(ii),c_sbFreqs(ii)]);
        end
    end

    pos = [pos(1)-0.1,pos(2)-0.1,0.2,0.05];
    saveBtn = uicontrol('Parent',h,'Style', 'pushbutton','FontSize',12,...
        'Units','normalized','Position', pos,'String','Save',... 
        'Callback', @Save);
    function Save(~,~)
        choice  = questdlg('Update settings?','Save options',...
                'Yes','No','No');
        if isempty(choice) || ~strcmp(choice, 'Yes')
            return;
        end
        for jj = 1:numQs
            QS.saveSSettings({qNames{jj},'r_fc'},fc);
        end
    end
end




