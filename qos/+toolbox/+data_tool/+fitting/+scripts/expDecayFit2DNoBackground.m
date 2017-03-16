%% load data
load('F:\data\matlab\20161221\_170104T16111910_.mat')
Data = Data{1};
sz = size(Data);
P = zeros(sz);
P0 = zeros(sz);
for ii = 1:sz(1)
    for jj = 1:sz(2)
        P(ii,jj) = Data{ii,jj}(1);
        P0(ii,jj) = Data{ii,jj}(2);
    end
end
x = SweepVals{1}{1};
y = SweepVals{2}{1}/2e3;
z = P-P0;
z = z';
figure();
imagesc(x,y,z); set(gca,'YDir','normal'); colormap(jet);
%% data: x, y, z
time = y;
bias = x;
z = z';
nb = length(bias);

plotfit = true;

%% data: zpa, t, P, Pb
% td_estimation = 15;
% x = unique(t);
% y = unique(zpa);
% nt = length(x);
% ny = length(bias);
% p = reshape(P,[nt,ny]);
% pb = reshape(Pb,[nt,ny]);
% z = p - pb;

%%
A = NaN*ones(1,nb);
B = NaN*ones(1,nb);
td = NaN*ones(1,nb);
tf = linspace(time(1),time(end),100);
if plotfit
    figure();
    plot(NaN);
    ax = gca;
    drawnow;
end
B0 = 0.45;
td0 = 10;
lb = [0.6*B0, 0.2*td0];
ub = [B0/0.6, 2*td0];
for ii = 1:nb
    
    
    [B_,td_,temp] = toolbox.data_tool.fitting.expDecayFitNoBackground(time,z(ii,:),B0,td0,lb,ub);
    
    wci(ii,:) = temp(2,:); %
    B(ii) = B_;
    td(ii) = td_;
    zf = toolbox.data_tool.fitting.expDecayNoBackground([B_,td_],tf);
    if plotfit
        plot(ax, time,z(ii,:));
        hold on;
        plot(ax,tf,zf,'r');
        plot(ax,temp(2,:),[zf(end),zf(end)],'g-+');
        plot(ax,td_,zf(end),'r+');
        hold off;
        drawnow;
    end
end

time = time;
td = td;
wci = wci;

figure();
imagesc(bias,time,z');
hold on;
errorbar(bias,td,td-wci(:,1)',wci(:,2)'-td,'ro-','MarkerSize',5,'MarkerFaceColor',[1,1,1]);
set(gca,'YDir','normal');
xlabel('Z Bias');
ylabel('Time (us)');
colormap(jet)

