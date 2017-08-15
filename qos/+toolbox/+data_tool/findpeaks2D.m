function pks = findpeaks2D(x,z)
    pks = NaN*ones(3,size(z,1));
    for ii = 1:size(z,1)
        index = find(~isnan(z(ii,:)));
        if numel(index) < 3
            continue;
        end
        yi = z(ii,index);
        yi = yi - min(smooth(yi,3));
        xi = x(index);
        r = range(yi);
        [~,locs,~,~] = findpeaks(yi,'SortStr','descend','MinPeakHeight',r/3,...
            'MinPeakProminence',r/3,'MinPeakDistance',numel(yi)/5,...
            'WidthReference','halfprom','NPeaks',3);
        pks(1:numel(locs),ii) = xi(locs);
    end
end