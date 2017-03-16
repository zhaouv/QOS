function b = ismember(A,B)
    % check if A is a member of cell B
    
% Copyright 2016 Yulin Wu, USTC
% mail4ywu@gmail.com/mail4ywu@icloud.com

	assert(~iscell(A)&iscell(B))
    b = false;
    for ii  = 1:numel(B)
        if B{ii} == A
            b = true;
            break;
        end
    end
end