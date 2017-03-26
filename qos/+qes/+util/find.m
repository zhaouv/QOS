function idx = find(A,B)
    % find A in cell B, numbers, strings or any objects with an eq methods
    % idx = find(3, {'Hello', 3, anObject, 0});
    
% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

	assert(~iscell(A)&iscell(B))
    idx = [];
    if ischar(A)
        for ii  = 1:numel(B)
            if ~ischar(B{ii})
                continue;
            elseif strcmp(B{ii},A)
                idx = [idx, ii];
            end
        end
    else
        for ii  = 1:numel(B)
            if B{ii} == A
                idx = [idx, ii];
            end
        end
    end
end