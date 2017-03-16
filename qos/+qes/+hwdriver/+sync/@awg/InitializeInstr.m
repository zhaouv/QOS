function [varargout] = InitializeInstr(obj)
%

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    ErrorMsg = [];
    % todo:
    % set ext trig level, slop, impedance etc
    
    
    if ~strcmp(obj.interfaceobj.Status,'closed')
         fclose(obj.interfaceobj); 
    end
    TYP = lower(obj.drivertype);
    switch TYP
        case {'tek5000','tek5k'}
            % AWG: Tecktronix AWG 5000
            obj.interfaceobj.Timeout = 120;   % seconds, this may need be increased in some special applictions
            obj.interfaceobj.InputBufferSize = 20000000; % bytes, should be enough for most applications
            obj.interfaceobj.OutputBufferSize = 20000000; % bytes, should be enough for most applications
            obj.interfaceobj.ByteOrder = 'littleEndian';
            obj.nchnls = 4;
        case {'tek7000','tek7k'}
            % AWG: Tecktronix AWG 7000
            obj.interfaceobj.Timeout = 120;   % seconds, this may need be increased in some special applictions
            obj.interfaceobj.InputBufferSize = 50000000; % bytes, should be enough for most applications
            obj.interfaceobj.OutputBufferSize = 50000000; % bytes, should be enough for most applications
            obj.interfaceobj.ByteOrder = 'littleEndian';
            obj.nchnls = 2;
        case {'tek70000','tek70k'}
            % AWG: Tecktronix AWG 70000
            obj.interfaceobj.Timeout = 900;   % seconds, this may need be increased in some special applictions
                                          % note: maximum timeout is 1000.
            obj.interfaceobj.InputBufferSize = 100000000; % bytes, should be enough for most applications
            obj.interfaceobj.OutputBufferSize = 100000000; % bytes, should be enough for most applications
            obj.interfaceobj.ByteOrder = 'littleEndian';
            obj.nchnls = 2;
        case {'ustc_da_v1'}
            obj.vpp = 65536;
            obj.nchnls = obj.interfaceobj.numChnls;
			obj.samplingRate = obj.interfaceobj.samplingRate;
        otherwise
            error('AWG:SetInterfaceObj','Unsupported awg: ''%s''', TYP);
    end
    fopen(obj.interfaceobj);
    
    
    varargout{1} = ErrorMsg;
end