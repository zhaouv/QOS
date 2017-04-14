function varargout = T1_1(varargin)
% T1_1: T1
% bias, drive and readout all one qubit
% 
% <_o_> = T1_1('qubit',_c&o_,'biasAmp',<[_f_]>,'biasDelay',0,...
%       'backgroundWithZBias',b,...
%       'time',[_i_],...
%       'notes',<_c_>,'gui',<_b_>,'save',<_b_>)
% _f_: float
% _i_: integer
% _c_: char or char string
% _b_: boolean
% _o_: object
% a&b: default type is a, but type b is also acceptable
% []: can be an array, scalar also acceptable
% {}: must be a cell array
% <>: optional, for input arguments, assume the default value if not specified
% arguments order not important as long as they form correct pairs.

% Yulin Wu, 2016/12/27

import qes.*
import data_taking.public.xmon.T1_111
args = util.processArgs(varargin,{'biasAmp',0,'biasDelay',0,'backgroundWithZBias',true,...
    'gui',false,'notes','','save',true});
varargout{1} = T1_111('biasQubit',args.qubit,'biasAmp',args.biasAmp,'biasDelay',args.biasDelay,...
    'backgroundWithZBias',args.backgroundWithZBias,'driveQubit',args.qubit,...
    'readoutQubit',args.qubit,'time',args.time,'notes',args.notes,'gui',args.gui,'save',args.save);
end