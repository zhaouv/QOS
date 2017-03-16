function varargout = setF01(varargin)
% set qubit idle point to a desired frequency by changing dc bias
%
% <_f_> = zdc2f01('qubit',_c&o_,...
%       'f01',_f_
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
    
    % Yulin Wu, 2017/2/8

    args = util.processArgs(varargin,{'gui',false,'save',true});
	q = copy(getQubits(args,{'qubit'})); % we need to modify the qubit properties, better make a copy to avoid unwanted modifications to the original.
    
    error('phased out');
	
	varargout{1} = [];
end