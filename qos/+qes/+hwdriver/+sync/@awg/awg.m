classdef awg < qes.hwdriver.sync.instrument
    % arbitary waveform generator(awg) driver

% Copyright 2015 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        dynamicReserve
		irf % impulse response functions(numeric) of each channel
        iqCalDataSet
    end
    properties (SetAccess = private)
        nchnls      % number of channels(number of channels may differ even for the same awg model, so has to be set by user)
        % id of the waveforms of each channel
        waveforms
        vpp % output range: -vpp/2 to vpp/2
    end
    properties % (AbortSet = true) do not use AbortSet
        samplingRate      % sampling rate, unit: Hz
        runmode = 1    % 1/2..., implication depends on the specific awg model, for tek5014: 0,1,2,3-triggered(default)/sequence/gated/continues
        trigmode = 1  % 1/2, internal(default) or external
        triginterval    % trigger frequency = 1/triginterval (Hz), not needed if trigmode is external
    end
    methods (Access = private)
        function obj = awg(name,interfaceobj,drivertype)
            if isempty(interfaceobj)
                throw(MException('QOS_awg:InvalidInput',...
                    sprintf('Input ''%s'' can not be empty!','interfaceobj')));
            end
            if nargin < 3
                drivertype = [];
            end
            obj = obj@qes.hwdriver.sync.instrument(name,interfaceobj,drivertype);
            ErrMsg = obj.InitializeInstr();
            if ~isempty(ErrMsg)
                throw(MException('QOS_awg:InstSetError',sprintf('%s: %s', obj.name, ErrMsg)));
            end
            % set methods are not called during object creation for
            % properties with default value(not sure on this point), set
            % RunMode and TrigMode with default values.
            SetRunMode(obj);
            SetTrigMode(obj);
            
        end
        [varargout] = InitializeInstr(obj)
        SetSmplRate(obj)
        SetRunMode(obj)
        SetTrigMode(obj)
        SetTrigInterval(obj)
        val  = GetTrigInterval(obj)
    end
    methods (Static)
        obj = GetInstance(name,interfaceobj,drivertype)
    end
    methods (Access = private)
        [WaveformData, Vpp, Offset,MarkerData,MarkerVpp,MarkerOffset] = PrepareWvData_Tek70k(obj,WaveformObj)
        [WaveformData] = PrepareWvData_Tek5k7k(obj,WaveformObj,DAVpp,NB,software_delay)
    end
    methods
        Run(obj,N)
        SetTrigOutDelay(obj,chnl,val)
        StopContinuousWv(obj,WaveformObj)
        RunContinuousWv(obj,WaveformObj)
        function set.nchnls(obj,val)
            if ~isempty(obj.nchnls) && obj.nchnls ~= val
                throw(MException('QOS_awg:settingInmmutable',...
					'nchnls(number of channel) is an immutable property, once set, it is not allowed to be changed.'));
            end
            if isempty(val) || val <= 0 || ceil(val) ~=val
                throw(MException('QOS_awg:InvalidInput',...
					'nchnls value should be positive integer.'));
            end
            obj.nchnls = val;
            obj.waveforms = cell(obj.nchnls,1);
			obj.irf = cell(obj.nchnls,1);
        end
		function set.irf(obj,val)
			if ~iscell(val)
				throw(MException('QOS_awg:InvalidInput',...
					'irf not an cell array.'));
			end
			if size(val,1) ~= obj.nchnls || size(val,2) ~= 1
				throw(MException('QOS_awg:InvalidInput',...
					'size of irf not equal to number of channels'));
			end
			for ii = 1:obj.nchnls
				if ~isempty(val{ii}) && ~iscell(val{ii})
					throw(MException('QOS_awg:InvalidInput',...
						'irf for each channel should eighter be empty or a cell array of numeric functions.'));
				end
			end
			obj.irf = val;
		end
        function set.samplingRate(obj,val)
            if isempty(val) || val <= 0
                throw(MException('QOS_awg:InvalidInput','samplingRate value should be a positive number.'));
            end
            obj.samplingRate = val;
            SetSmplRate(obj);
        end
        function val = get.samplingRate(obj)
            % query from the instrument is to be implemented.
            val = obj.samplingRate;
        end
        function set.runmode(obj,val)
            if isempty(val) || val<0 || ceil(val) ~=val
                throw(MException('QOS_awg:InvalidInput','runmode value should be a positive integer.'));
            end
            obj.runmode = val;
            SetRunMode(obj);
        end
        function val = get.runmode(obj)
            % query from the instrument is to be implemented.
            val = obj.runmode;
        end
        function set.trigmode(obj,val)
            if isempty(val) || val<=0 || round(val) ~=val
                throw(MException('QOS_awg:InvalidInput','trigmode value can only be 0(internal) or 1(external).'));
            end
            if val >2
                val = 2;
            end
            obj.trigmode = val;
            SetTrigMode(obj);
        end
        function val = get.trigmode(obj)
            % query from the instrument is to be implemented in the future.
            val = obj.trigmode;
        end
        function set.triginterval(obj,val)
            if isempty(val) || val <= 0
                throw(MException('QOS_awg:InvalidInput','triginterval value should be a positive number.'));
            end
            obj.triginterval = val;
            SetTrigInterval(obj);
        end
        function val = get.triginterval(obj)
            % query from the instrument is to be implemented in the future.
            val = GetTrigInterval(obj);
            % val = obj.triginterval;
        end
        function ret = AddWaveform(obj,wvfrmobj,chnl)
            ret = 0;
            if ~isa(wvfrmobj,'Waveform') || ~IsValid(wvfrmobj)
                throw(MException('QOS_awg:notValidWaveform','wvfrmobj not valid or not a Waveform class object.'));
            end
            if ceil(chnl) ~=chnl || chnl <=0
                error('awg:AddWaveform','chnl should be a positive integer!');
            end
            if  isempty(obj.nchnls) || chnl > obj.nchnls
                throw(MException('QOS_awg:inconsistentChnl','chnl inconsistent with the awg or number of channels not set.'));
            end
            if ~isempty(obj.waveforms{chnl})
                if obj.waveforms{chnl} == wvfrmobj.id
                    return;
                end
                oldwvobj = qes.qHandle.FindByProp('id',obj.waveforms{chnl});
                if isempty(oldwvobj) % in such case, the waveform has been removed already
%                     warning('awg:AddWaveform','There is already a waveform object attached to this channel, this waveform will be removed.');
                else
                    oldwvobj{1}.awgchnl = [];
                    warning(['awg:AddWaveform',' Waveform ''',oldwvobj{1}.name,...
                        '''(id:', num2str(oldwvobj{1}.id,'%0.0f'),') seems to be running on the channel to output waveform ''',...
                        wvfrmobj.name, '''(id:', num2str(wvfrmobj.id,'%0.0f'),'), it will be removed.']);
                end
            end
            obj.waveforms{chnl} = wvfrmobj.id;
        end
        function mzeros = MixerZeros(obj,chnls,loFreq)
            % mixer zeros
            
            assert(numel(chnls) == 2);
            numIQCalDataSet = numel(obj.iqCalDataSet);
            if numIQCalDataSet == 0
                mzeros = [0,0];
                return;
            end
            for ii = 1:numIQCalDataSet
                % Error: obj.iqCalDataSet has no chnls!
%                 if all(obj.iqCalDataSet(ii).chnls == chnls)
%                     break;
%                 end
                if ii == numIQCalDataSet
                    mzeros = [0,0];
                    return;
                end
                f = obj.iqCalDataSet(ii).loFreq;
                iZero = obj.iqCalDataSet(ii).iZero;
                qZero  = obj.iqCalDataSet(ii).qZero;
            end
            if f > 1
                i0 = interp1(f,iZeros,loFreq,'pchip',0);
                q0 = interp1(f,qZeros,loFreq,'pchip',0);
            else
                idx = f==loFreq;
                i0 = iZero(idx);
                q0 = qZero(idx);
                if isempty(i0)
                    i0 = 0;
                    q0 = 0;
                end
            end
            mzeros = [i0,q0];
        end
    end
    methods (Hidden = true) % hidden, only to be indirectly called by methods of Waveform class objects
        SendWave(obj,WaveformObj)
        LoadWave(obj,WaveformObj)
    end
end