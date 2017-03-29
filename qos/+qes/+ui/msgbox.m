function msgbox(msg,title,modal)
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    if nargin < 3 || ~modal
        msgbox(msg,title);
    else
        msgbox(msg,title,'modal');
    end
end