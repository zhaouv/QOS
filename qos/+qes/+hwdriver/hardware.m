classdef (Abstract = true) hardware < qes.qHandle
    % base class for all hardware
    %

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    methods
        function obj = hardware(name)
            if nargin == 0 || isempty(name)
                error('Hardware:UnNamedError', 'name empty, hardwares object properties are looked up in settings by name, so a hardware must be given a name.');
            end
            obj = obj@qes.qHandle(name);
            obj.temperory = false;
        end
        function delete(obj)
            obj.temperory = true; % remove object from pool
        end
    end
end