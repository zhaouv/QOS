function idx = find(A,B)
    % find A in cell B
    
% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

	assert(~iscell(A)&iscell(B))
    idx = [];
    for ii  = 1:numel(B)
        if B{ii} == A
            idx = [idx, ii];
        end
    end
end