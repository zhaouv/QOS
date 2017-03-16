function zplsAmp2Detune(qName,auto)

%
% <[_f_]> = zplsAmp2Detune('qubit',_c&o_,...
%       'gui',<_b_>,'save',<_b_>)
% _f_: float
% _i_: integer
% _c_: char or char string
% _b_: boolean
% _o_: object
% a&b: default type is a, but type b is also acceptable
% []: can be an array, scalar also acceptable
% {}: must be a cell array
% <>: optional, for input arguments, assume the default value if not specified
% arguments order not important as long as the form correct pairs.
	
    
    % Yulin Wu, 2017/1/8
	
	error('to be implemented.');
    
    fcn_name = 'zplsAmp2Detune'; % this and args will be saved with data
    import toolbox.data_tool.fitting.*
    import data_taking.public.xmon.spectroscopy1_zdc
    import data_taking.public.xmon.bringup.iq2prob

    if nargin < 2 % in case of auto, data will not be shown and automatically update settings without requesting use decision.
        auto = false;
    end
    
    args.qubit = qName;
	q = data_taking.public.util.getQubits(args,{'qubit'});
    
    f01_ini = q.zdc_amp2f01_freqUnit*polyval(q.zdc_amp2f01,0);
    function f_ = sweep_freq(bias_)
        f01_est = q.zdc_amp2f01_freqUnit*polyval(q.zdc_amp2f01,bias_);
        f_ = q.t_zdc2freqFreqStep*floor((f01_est-q.t_zdc2freqFreqSrchRng/2)/q.t_zdc2freqFreqStep):...
            q.t_zdc2freqFreqStep:...
            q.t_zdc2freqFreqStep*ceil((f01_est+q.t_zdc2freqFreqSrchRng/2)/q.t_zdc2freqFreqStep);
    end

%     r_iq2prob_01rPoint_backup = q.r_iq2prob_01rAngle;
%     r_iq2prob_01rAngle_backup = q.r_iq2prob_01rAngle;
%     r_iq2prob_01threshold_backup = q.r_iq2prob_01threshold;
%     r_iq2prob_01polarity_backup = q.r_iq2prob_01polarity;

    last_iq2prob_cal_freq = f01_ini;
    QS = qes.qSettings.GetInstance();

    bias = [];
    f01 = f01_ini;
    P = {};
    Frequency = {};
    while true
        if isempty(bias)
            bias = 0;
            f = sweep_freq(bias);
            e0 = spectroscopy1_zdc('qubit',qName,'bias',bias(end),'drive_freq',f,'save',false,'gui',false);
            P = e0.data;
            Frequency = {f};
            [~,midx] = max(P{end});
            f01 = f(midx);
            continue;
        end
        stopBiasForward = false;
        stopBiasBackward = false;
        if f01(1) > f01(end)
            stopBiasForward = true;
        elseif f01(1) < f01(end)
            stopBiasBackward = true;
        end
        if numel(bias) < 10
            df = q.t_zdc2freqFreqSrchRng/10;
        else
            df = q.t_zdc2freqFreqSrchRng/5;
        end
        if ~stopBiasForward
            zdc_amp2f01_ = q.zdc_amp2f01;
            if numel(f01) <= 3
                zdc_amp2f01_(end) = zdc_amp2f01_(end) - (f01(1) - df)/q.zdc_amp2f01_freqUnit;
                r = roots(zdc_amp2f01_);
                r = sort(r(isreal(r)));
                if isempty(r) % zdc_amp2f01 must be a real polynomial of degree 1, a real polynomial of degree 1 has a root root for sure 
                    error('zdc_amp2f01 setting for qubit %s is not a real polynomial of degree 1.', q.name);
                end
                db  = min(abs([r -  bias(1),r -  bias(end)]));
            else
                if polyval(zdc_amp2f01_,bias(end)) >=  polyval(zdc_amp2f01_,bias(end-1))
                    zdc_amp2f01_(end) = zdc_amp2f01_(end) - (f01(end) + df)/q.zdc_amp2f01_freqUnit;
                else
                    zdc_amp2f01_(end) = zdc_amp2f01_(end) - (f01(end) - df)/q.zdc_amp2f01_freqUnit;
                end
                r = roots(zdc_amp2f01_);
                db = sort(r(isreal(r))) - bias(end);
                db = db(db>0);
                if isempty(db)
                    db = dbForward;
                else
                    db = db(1);
                    if db > 3*dbForward;
                        db = dbForward;
                    end
                end
            end
            bias = [bias,bias(end)+db];
            f = sweep_freq(bias(end));
            e = spectroscopy1_zdc('qubit',qName,'bias',bias(end),'drive_freq',f,'save',false,'gui',false);
            P = [P, e.data];
            Frequency = [Frequency,{f}];
            [~,midx] = max(P{end});
            f01 = [f01,f(midx)];
            dbForward = db;
            if abs(last_iq2prob_cal_freq - f01(end)) > 10e6
                q.f01 = f01(end);
                iq2prob(q,10000,true);
                q.r_iq2prob_01rAngle = QS.loadSSettings({q.name,'r_iq2prob_01rPoint'});
                q.r_iq2prob_01rAngle = QS.loadSSettings({q.name,'r_iq2prob_01rAngle'});
                q.r_iq2prob_01threshold = QS.loadSSettings({q.name,'r_iq2prob_01threshold'});
                q.r_iq2prob_01polarity = QS.loadSSettings({q.name,'r_iq2prob_01polarity'});
                last_iq2prob_cal_freq = f01(end);
            end
        end
        if ~stopBiasBackward
            zdc_amp2f01_ = q.zdc_amp2f01;
            if numel(f01) <= 3
                zdc_amp2f01_(end) = zdc_amp2f01_(end) - (f01(1) - df)/q.zdc_amp2f01_freqUnit;
                r = roots(zdc_amp2f01_);
                r = sort(r(isreal(r)));
                if isempty(r) % zdc_amp2f01 must be a real polynomial of degree 1, a real polynomial of degree 1 has a root root for sure 
                    error('zdc_amp2f01 setting for qubit %s is not a real polynomial of degree 1.', q.name);
                end
                db  = -min(abs([r -  bias(1),r -  bias(end)]));
            else
                if polyval(zdc_amp2f01_,bias(1)) >=  polyval(zdc_amp2f01_,bias(2))
                    zdc_amp2f01_(end) = zdc_amp2f01_(end) - (f01(1) + df)/q.zdc_amp2f01_freqUnit;
                else
                    zdc_amp2f01_(end) = zdc_amp2f01_(end) - (f01(1) - df)/q.zdc_amp2f01_freqUnit;
                end
                r = roots(zdc_amp2f01_);
                db = sort(r(isreal(r))) - bias(1);
                db = db(db<0);
                if isempty(db)
                    db = dbBackward;
                else
                    db = db(end);
                    if db < 3*dbBackward;
                        db = dbBackward;
                    end
                end
            end
            bias = [bias(1)+db, bias];
            f = sweep_freq(bias(1));
            e = spectroscopy1_zdc('qubit',qName,'bias',bias(1),'drive_freq',f,'save',false,'gui',false);
            P = [e.data, P];
            Frequency = [{f}, Frequency];
            [~,midx] = max(P{1});
            f01 = [f(midx),f01];
            dbBackward = db;
            if abs(last_iq2prob_cal_freq - f01(1)) > 10e6
                q.f01 = f01(1);
                iq2prob(q,10000,true);
                q.r_iq2prob_01rAngle = QS.loadSSettings({q.name,'r_iq2prob_01rPoint'});
                q.r_iq2prob_01rAngle = QS.loadSSettings({q.name,'r_iq2prob_01rAngle'});
                q.r_iq2prob_01threshold = QS.loadSSettings({q.name,'r_iq2prob_01threshold'});
                q.r_iq2prob_01polarity = QS.loadSSettings({q.name,'r_iq2prob_01polarity'});
                last_iq2prob_cal_freq = f01(1);
            end
        end
        try
            zdc_amp2f01_backup = q.zdc_amp2f01;
            num_data_points = numel(bias);
            if num_data_points > 24
                pf = polyfit(bias,f01/q.zdc_amp2f01_freqUnit,3);
            elseif num_data_points > 12
                pf = polyfit(bias,f01/q.zdc_amp2f01_freqUnit,2);
            else
                pf = polyfit(bias,f01/q.zdc_amp2f01_freqUnit,1);
            end
            q.zdc_amp2f01 = pf;
        catch
            q.zdc_amp2f01 = zdc_amp2f01_backup;
        end
        plotAndSave(bias,Frequency,P,f01);
        if abs(f01_ini - f01(end)) > q.zdc_amp2fFreqRng && abs(f01_ini - f01(1)) > q.zdc_amp2fFreqRng
            break;
        end
    end
    function plotAndSave(bias_,Frequency_,P_,f01_)
        persistent ax
        if isempty(ax) || ~isvalid(ax)
            hf = figure('NumberTitle','off','Name','z dc bias to f01','HandleVisibility','callback');
            ax = axes('parent',hf);
        end
        num_biases = numel(bias);
        all_freq = cell2mat(Frequency_);
        f_ = min(all_freq):q.t_zdc2freqFreqStep:max(all_freq);
        num_freq = numel(f_);
        prob = NaN*ones(num_biases,num_freq);
        for ww = 1:num_biases
            for hh = 1:numel(Frequency_{ww})
                prob(ww,f_ == Frequency_{ww}(hh)) = P_{ww}(hh);
            end
        end
        h = pcolor(bias_,f_,prob','parent',ax);
        set(h,'EdgeColor', 'none');
        hold(ax,'on');
        bi = linspace(bias_(1),bias_(end),200);
        plot(ax,bi,q.zdc_amp2f01_freqUnit*polyval(q.zdc_amp2f01,bi),'--','color',[1,1,1],'LineWidth',2);
        plot(ax,bias_,f01_,'o','MarkerEdgeColor',[0,0,0],'MarkerFaceColor',[1,1,1],'MarkerSize',6,'LineWidth',1);
        xlabel(ax,'z dc bias amplitude');
        ylabel(ax,'frequency (Hz)');
        hold(ax,'off');
        colormap(ax,jet(128));
        colorbar('peer',ax);
        drawnow;
        e0.data{1} = prob;
        e0.sweepvals{1}{1} = bias_;
        e0.sweepvals{2}{1} = f_;
        e0.addSettings({'dc_bias','f01'},{bias_,f01_});
        e0.SaveData();
%         % temp, save for demo;
%         saveas(h,['F:\data\matlab\20161221\zdc2f01\',datestr(now,'mmddHHMMSS'),'.png']);
    end

    updateSettings = false;
    if ~auto
        choice = questdlg('Update settings?', ...
            'Update settings', ...
            'Yes','No','No');
        switch choice
            case 'Yes'
                updateSettings = true;
        end
    else
        updateSettings = true;
    end
    if updateSettings
        QS = qes.qSettings.GetInstance();
        QS.saveSSettings({q.name,'zdc_amp2f01'},q.zdc_amp2f01);
    end
end