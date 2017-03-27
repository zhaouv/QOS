function Value = num2strCompact(Value)
    % a compact and smarter version of MATLAB num2str
    % num2str(1e8,'%e'):	'1.000000e+08'
    % num2str(1e8):         '1e8'
    % num2str(1e-8):        '1e-8'

% Copyright 2016 Yulin Wu, USTC, China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    if abs(Value) > 1e3 ||...
            (abs(Value) < 1e-3 && round(Value) ~= Value)
        Value = num2str(Value,'%0.5e');
    else 
        if round(Value) == Value
            Value = num2str(Value,'%0.0f');
        else
            Value = num2str(Value,'%0.5f');
        end
    end
    Value = regexprep(Value,'.\d*0+e','e');
    Value = regexprep(Value,'(e\+*0+)|(e\+)','e');
    Value = regexprep(Value,'e\-*0+','e-');
    if numel(Value)>1 && Value(1) == '+'
        Value(1) = [];
    end
end