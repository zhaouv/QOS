function temp_iq_stability(q,num_samples)
% temp

fcn_name = 'temp_iq_stability'; % this and args will be saved with data
import qes.*
import sqc.*
import sqc.op.physical.*

qubits = util.loadQubits();
if ~util.ismember(q,qubits)
    error('%s is not one of the selected qubits.',q);
end
qubit = qubits{util.find(q,qubits)};

X = gate.X(qubit);
X.Run();
R = measure.resonatorReadout(qubit);
R.delay = 16*ceil(qubit.qr_xy_piLn/16); 

num_reps = ceil(num_samples/qubit.r_avg);
iq_raw_1 = NaN*ones(num_reps,qubit.r_avg);
iq_raw_0 = NaN*ones(num_reps,qubit.r_avg);

hf = figure('Units','characters',...
            'NumberTitle','off','Name','QES | IQ Raw',...
            'Color',[1,1,1],...
            'DockControls','off');
ax1 = axes('parent',hf);

datafile_name = ['F:\data\matlab\20161221\zdc2f01\_iq_stability',datestr(now,'mmddHHMMSS')];

N = 3600*10;
iq_raw_1_mean = NaN*ones(1,N);
iq_raw_0_mean = NaN*ones(1,N);
Time = NaN*ones(1,N);

x_amp_backup = X.amp;
for ww = 1:N
    iq_raw_1 = NaN*ones(num_reps,qubit.r_avg);
    iq_raw_0 = NaN*ones(num_reps,qubit.r_avg);
    
    X.amp = x_amp_backup;
    X.mw_src{1}.on = true;
    for ii = 1:num_reps
        R.Run();
        iq_raw_1(ii,:) = R.extradata{1};
    end
    iq_raw_1 = iq_raw_1(:);
    iq_raw_1_mean(ww) = mean(iq_raw_1);

    X.amp = 0;
    X.mw_src{1}.on = false;
    for ii = 1:num_reps
        R.Run();
        iq_raw_0(ii,:) = R.extradata{1};
    end
    iq_raw_0 = iq_raw_0(:);
    iq_raw_0_mean(ww) = mean(iq_raw_0);
    
    Time(ww) = now;
    
    plot(ax1,iq_raw_0_mean,'b.');
    hold(ax1,'on');
    plot(ax1,iq_raw_1_mean(:),'r.');
    hold(ax1,'off');
    
    saveas(hf,[datafile_name,'.fig']);
    save([datafile_name,'.mat'],'iq_raw_0_mean','iq_raw_1_mean','Time');
end


end