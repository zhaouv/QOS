classdef (Abstract = true) waveform < qes.qHandle & matlab.mixin.Copyable
    % base class of all waveform classes
    % to plot a waveform in time domain:
    % wvfcn.Show(wvobj); or plotax = wvfcn.Show(wvobj); or wvfcn.Show(wvobj, ax);
    % in frequency domain:
    % wvfcn.Show(wvobj,[],true); to plot the frequency domain data;
    %
    % a call to a waveform object will evaluate its time domain function
    % if the frequency function indicator is not set or not true and
    % will evaluate the frequency domain funciton if set to true:
    % v = wvobj(t);         % evaluate time domain function
    % v = wvobj(f,true);	% evaluate frequency domain function
    % new_wvobj = wvobj{ln};   % buid a waveform object of the same
    % class of length ln
    % new_wvobj = wvobj{wv_struct};   % buid a waveform object from
    % a struct

% Copyright 2015 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com


    properties
        % waveform length, non negative integer, unit: 1/sampling frequency
        length
        df % mixing frequency in unit of sampling frequency, if empty(default), no frequency mixing
        phase % phase of frequency mxing
        % carrier frequency of iq waveform, used for iq mixer zero correction
        % and sideband correction, consider port this property into the awg/da
        % class in a future version
        fc
        % AWG class object to generate the waveform. Empty if not needed
        awg
        % channel number of the awg to generate the waveform, 1,2,3,... etc,
        % should be compatible with the awg object. Empty if not needed.
        awgchnl
        % float, da output delay, used for syncronization between channels, unit: 1/sampling frequency
        output_delay = 0
        % realize output_delay by using hardware output delay or not,
        % default, false, the output delay is realized by adding leading
        % zeros(up to integer number of sampling interval) and by modifying the
        % wave function(sub sampling interval adjustment, not
        % implemented yet, 2017/2/24, Yuln Wu).
        % realize output_delay by using hardware output delay for long
        % output_delay.
        hw_delay = false
    end
    properties (Dependent = true)
		% waveform is a I,Q tuple or just a simple real waveform.
        % if iq = true, needs two channels to ouput the waveform, one for I
        % and one for Q, the waveform data is complex, the real part for I
        % and the imaginary part for Q.
		iq
	end
	properties (SetAccess = public)
		% float, start time, unit: 1/sampling frequency, in case of IQ waveforms
        % t0 defines the initial phase
        t0 = 0 
        % sideband compensation for iq waveform
%       sb_comp
%		iq_zeros
    end
    methods
        function obj = waveform(ln)
            obj@matlab.mixin.Copyable();
            obj = obj@qes.qHandle();
            if nargin
                obj.length = ln;
            end
            
            % by default, waveforms are temperay and nameless, name
            % property of waveforms might be removed in future versions
            % to make waveform objects light weighted.
%             obj.name = ['untitled_',num2str(999999*rand(),'%06.0f')]; % set a default name
        end
        function set.length(obj,val)
%             if val < 0 || round(val) ~= val
%                 throw(MException('QOS_waveform:InvalidInput','length should be a non negative integer!'));
%             end
            if ~isempty(obj.length) && obj.length && (isa(obj,'qes.waveform.arithmetic') ||...
					isa(obj,'qes.waveform.sequence') || isa(obj,'qes.waveform.arbFcn'))
                throw(MException('QOS_waveform:setLengthError',...
					sprintf('length of %s object can not be set.',class(obj))));
            end
            obj.length = val;
        end
        function val = get.length(obj)
            if isa(obj,'qes.waveform.sequence')
                val = qes.waveform.sequence.GetLength(obj);
            else
                val = obj.length;
            end
        end
        function set.df(obj,val)
            oldDFEmpty = isempty(obj.df);
            newDFEmpty = isempty(val);
            if oldDFEmpty && newDFEmpty
                return;
            elseif oldDFEmpty && ~newDFEmpty
				if numel(obj.output_delay) == 1
					obj.output_delay = obj.output_delay*[1,1];
                end
                obj.df = val;
				obj.phase = 0;
            elseif ~oldDFEmpty && newDFEmpty
				obj.output_delay = obj.output_delay(1);
                obj.phase = [];
				obj.fc = [];
            else
                obj.df = val;
            end
        end
		function set.phase(obj,val)
			if ~isempty(val) && isempty(obj.df)
				throw(MException('QOS_waveform:InvalidInput','can not set phase on an non IQ waveform.'));
            end
            obj.phase = val;
		end
		function set.fc(obj,val)
			if ~isempty(val) && isempty(obj.df)
				throw(MException('QOS_waveform:InvalidInput','can not set carrier frequency on an non IQ waveform.'));
			end
		end
		function val = get.iq(obj)
			val = ~isempty(obj.df);
		end
        function set.awg(obj,val)
            if isempty(val)
                obj.awg = val;
                obj.awgchnl = [];
                return;
            end
            if (~isa(val,'qes.hwdriver.sync.awg') &&...
                    ~isa(val,'qes.hwdriver.ync.awg')) || ~IsValid(val)
                throw(MException('QOS_waveform:InvalidInput','awg should be a valid AWG class object.'));
            end
            obj.awg = val;
        end
        function set.awgchnl(obj,val)
            if isempty(val)
                obj.awgchnl = val;
%                 obj.temperory = true; % obsolete
                qes.qHandle.ListObj(obj);
%                 if ~isempty(obj.awg) && isa(obj.awg,'Hardware') && IsValid(obj.awg)
%                     try
%                         obj.awg.DelWave(obj.name);
%                     catch
%                     end
%                 end
                return;
            end
%             if ceil(val) ~=val || val <=0
%                 throw(MException('QOS_waveform:setAWGChnlError','awgchnl should be a positive integer!'));
%             end

            if isempty(obj.awg) || ~isa(obj.awg,'qes.hwdriver.hardware') || ~IsValid(obj.awg)
                throw(MException('QOS_waveform:setAWGChnlError',...
					'awg not set or not valid, awg channels can only be set after awg is set.'));
            end
            if  ~isempty(obj.awg) && IsValid(obj.awg) && ~isempty(obj.awg.nchnls) && any(val > obj.awg.nchnls)
                throw(MException('QOS_waveform:setAWGChnlError',...
					'channel number inconsistent with the awg object or number of channels of the awg object not set!'));
            end
            if obj.iq
                if numel(val) ~= 2
                    throw(MException('QOS_waveform:setAWGChnlError',...
						sprintf('An IQ waveform needs exactly two channels to do output, %0.0f given.',numel(val))));
                elseif val(1) == val(2)
                    throw(MException('QOS_waveform:setAWGChnlError',...
						'Can not output both I and Q on the same channel.'));
                end
            else
                if numel(val) > 1 && ~isa(obj,'qes.waveform.sequence')
                    throw(MException('QOS_waveform:setAWGChnlError',...
						'Only IQ waveforms needs two output channels!'));
                end
            end
            obj.awgchnl = val;
            
%             obj.awg.AddWaveform(obj,obj.awgchnl);
        end
        function set.output_delay(obj,val)
            if val < 0
                throw(MException('QOS_waveform:negativeOutputDelay','output_delay can not be a negative value.'));
            end
            obj.output_delay = val;
        end
%         function newobj = deepcopy(obj)
%             newobj = copy(obj);
% %             if isa(obj, 'qes.waveform.sequence')
% %                 for ii = 1:numel(obj.wvlist)
% %                     newobj.wvlist{ii} = copy(obj.wvlist{ii}); % here deep copy is not used to avoid possible looping
% %                     qes.qHandle.SetId(newobj.wvlist{ii});
% %                 end
% %             end
%             newobj.awg = obj.awg; % hardware objects can only be referenced, not copyable
% %             newobj.name = [obj.name, '_copy'];
%             qes.qHandle.SetId(newobj); % we need a new id
%         end
        function delete(obj)
            obj.awgchnl = []; % this will remove the waveform from the associated awg channel
        end
        
%         function DoAll(obj,N)
%             obj.SendWave();
%             obj.LoadWave();
%             obj.Run(N);
%         end
        % SendWave, LoadWave can not be combined into one function due to:
        % some awg/da supports storing many waveforms in its RAM by
        % SendWave and then select one of these wavefroms to run by
        % LoadWave or select several waveforms to build a sequence.
        % if the awg/da dose not support this functionality, LoadWave
        % simplity do nothing.
        function SendWave(obj)
            % send waveform data to awg instrument(RAM)
            if isempty(obj.awg) || ~IsValid(obj.awg)
                throw(MException('QOS_waveform:SendWaveError', 'awg not set or not valid!'));
            end
            obj.awg.SendWave(obj);
        end
        function LoadWave(obj)
            % Load wave data for running(loaded from RAM to SRAM)
            obj.awg.LoadWave(obj);
        end
        function Run(obj,N)
            if isempty(obj.awg) || ~isvalid(obj.awg)
                throw(MException('QOS_waveform:RunError', 'awg not set or not valid!'));
            end
            if isempty(obj.awgchnl)
                throw(MException('QOS_waveform:RunError', 'awgchnl not set!'));
            end
            obj.awg.Run(N);
        end
    end
	methods (Access = protected)
		function newobj = copyElement(obj)
			newobj = copyElement@matlab.mixin.Copyable(obj);
			qes.qHandle.SetId(newobj); % we need a new id
		end
	end
    methods (Access = 'public', Hidden=true)       
        function obj = plus(obj1,obj2)
            % add two waveforms together to produce a new woveform
            %
            function v = freqfcn(f)
                if isnumeric(obj1)
                    v = obj2.FreqFcn(obj2,f);
                    v(1) = v(1)+obj1*obj2.length();
                else
                    v = obj1.FreqFcn(obj1,f);
                    v(1) = v(1)+obj2*obj1.length();
                end
            end
            if isnumeric(obj1)
                obj2 = copy(obj2);
                t0_ = obj2.t0;
                obj2.t0 = 0;
                timefcn = @(t)obj2.TimeFcn(obj2,t)+obj1;
                obj = qes.waveform.arbFcn(obj2.length, timefcn, @freqfcn);
                obj.t0 = t0_;
				obj.df = obj2.df;
				obj.phase = obj2.phase;
				obj.fc = obj2.fc;
                return;
            elseif isnumeric(obj2)
                obj1 = copy(obj1);
                t0_ = obj1.t0;
                obj1.t0 = 0;
                timefcn = @(t)obj1.TimeFcn(obj1,t)+obj2;
                obj = qes.waveform.arbFcn(obj1.length, timefcn, @freqfcn);
                obj.t0 = t0_;
				obj.df = obj1.df;
				obj.phase = obj1.phase;
				obj.fc = obj1.fc;
                return;
            end
            % now it's ok to do arithmetics with two waveforms of different length
            obj = qes.waveform.arithmetic(1,obj1,obj2);
			
        %     obj.name = ['cbwv(', obj1.name, '_plus_',obj2.name,')'];
        %     if length(obj.name) > 50
        %         obj.name = [obj.name(1:118),'..._',num2str(999999*rand(),'%06.0f')];
        %     end

            % awg and awgchnl setting are removed for efficiency, setting dose not
            % bring much convinience anyway because in most case, the awg and channel
            % are set at the final step after all other waveform preparation operations
            % like arithmetics and concatinations are done.
        %     if  ~isempty(obj1.awg) && ~isempty(obj2.awg) && obj1.awg ~= obj2.awg
        %         warning('waveform:awgMismatch',...
        %             'The two waveform objects have different awg objects, awg object of the first waveform object is used!');
        %     end
        % %     if ~isempty(obj1.awgchnl) && ~isempty(obj2.awgchnl) && obj1.awgchnl ~= obj2.awgchnl
        % %         warning('waveform:awgchnlMismatch',...
        % %             'The two waveform objects have different awgchnls, awgchnl of the first waveform object is used!');
        % %     end
        end
        function obj = minus(obj1,obj2)
            % minus one waveform by another to produce a new woveform
            function v = freqfcn(f)
                if isnumeric(obj1)
                    v = obj2.FreqFcn(obj2,f);
                    v(1) = v(1)-obj1*obj2.length();
                else
                    v = obj1.FreqFcn(obj1,f);
                    v(1) = v(1)-obj2*obj1.length();
                end
            end
            if isnumeric(obj1)
                obj2 = copy(obj2);
                t0_ = obj2.t0;
                obj2.t0 = 0;
                timefcn = @(t)obj1-obj2.TimeFcn(obj2,t);
                obj = qes.waveform.arbFcn(obj2.length, timefcn, @freqfcn);
                obj.t0 = t0_;
				obj.df = obj2.df;
				obj.phase = obj2.phase;
				obj.fc = obj2.fc;
                return;
            elseif isnumeric(obj2)
                obj1 = copy(obj1);
                t0_ = obj1.t0;
                obj1.t0 = 0;
                timefcn = @(t)obj1.TimeFcn(obj1,t)-obj2;
                obj = qes.waveform.arbFcn(obj1.length, timefcn, @freqfcn);
                obj.t0 = t0_;
				obj.df = obj1.df;
				obj.phase = obj1.phase;
				obj.fc = obj1.fc;
                return;
            end
            % now it's ok to do arithmetics with two waveforms of different length
        %     if obj1.length ~= obj2.length
        %         error('waveform:ArithmeticError', 'Adding two waveform objects with different waveform length is not possible!');
        %     end
            obj = qes.waveform.arithmetic(2,obj1,obj2);
        %     obj.name = ['cbwv(', obj1.name, '_minus_',obj2.name,')'];
        %     if length(obj.name) > 50
        %         obj.name = [obj.name(1:118),'..._',num2str(999999*rand(),'%06.0f')];
        %     end

            % awg and awgchnl setting are removed for efficiency, setting dose not
            % bring much convinience anyway because in most case, the awg and channel
            % are set at the final step after all other waveform preparation operations
            % like arithmetics and concatinations are done.

        %     if  ~isempty(obj1.awg) && ~isempty(obj2.awg) && obj1.awg ~= obj2.awg
        %         warning('waveform:awgMismatch',...
        %             'The two waveform objects have different awg objects, awg object of the first waveform object is used!');
        %     end
        % %     if ~isempty(obj1.awgchnl) && ~isempty(obj2.awgchnl) && obj1.awgchnl ~= obj2.awgchnl
        % %         warning('waveform:awgchnlMismatch',...
        % %             'The two waveform objects have different awgchnls, awgchnl of the first waveform object is used!');
        % %     end
        end
        function obj = uminus(obj1)
            % uminus of a waveform object
            %

            obj1 = copy(obj1); % make a copy is important
            t0_ = obj1.t0;
            obj1.t0 = 0;
            timefcn = @(t)-obj1.TimeFcn(obj1,t);
            freqfcn = @(f)-obj1.FreqFcn(obj1,f);
            obj = qes.waveform.arbFcn(obj1.length, timefcn, freqfcn);
            obj.t0 = t0_;
			obj.df = obj1.df;
			obj.phase = obj1.phase;
			obj.fc = obj1.fc;
        end
        function obj = mtimes(obj1,obj2)
            % multiply two waveforms together to produce a new woveform
            %
            if isnumeric(obj1)
                obj2 = copy(obj2);
                t0_ = obj2.t0;
                obj2.t0 = 0;
                timefcn = @(t)obj1*obj2.TimeFcn(obj2,t);
                freqfcn = @(f)obj1*obj2.FreqFcn(obj2,f);
                obj = qes.waveform.arbFcn(obj2.length, timefcn, freqfcn);
                obj.t0 = t0_;
				obj.df = obj2.df;
				obj.phase = obj2.phase;
				obj.fc = obj2.fc;
                return;
            elseif isnumeric(obj2)
                obj1 = copy(obj1);
                t0_ = obj1.t0;
                obj1.t0 = 0;
                timefcn = @(t)obj2*obj1.TimeFcn(obj1,t);
                freqfcn = @(f)obj2*obj1.FreqFcn(obj1,f);
                obj = qes.waveform.arbFcn(obj1.length, timefcn, freqfcn);
                obj.t0 = t0_;
				obj.df = obj1.df;
				obj.phase = obj1.phase;
				obj.fc = obj1.fc;
                return;
            end
            obj = qes.waveform.arithmetic(3,obj1,obj2);
        %     obj.name = ['cbwv(', obj1.name, '_times_',obj2.name,')'];
        %     if length(obj.name) > 50
        %         obj.name = [obj.name(1:50),'..._',num2str(999999*rand(),'%06.0f')];
        %     end

            % awg and awgchnl setting are removed for efficiency, setting dose not
            % bring much convinience anyway because in most case, the awg and channel
            % are set at the final step after all other waveform preparation operations
            % like arithmetics and concatinations are done.

        %     if  ~isempty(obj1.awg) && ~isempty(obj2.awg) && obj1.awg ~= obj2.awg
        %         warning('waveform:awgMismatch',...
        %             'The two waveform objects have different awg objects, awg object of the first waveform object is used!');
        %     end
        % %     if ~isempty(obj1.awgchnl) && ~isempty(obj2.awgchnl) && obj1.awgchnl ~= obj2.awgchnl
        % %         warning('waveform:awgchnlMismatch',...
        % %             'The two waveform objects have different awgchnls, awgchnl of the first waveform object is used!');
        % %     end
        %     if ~isempty(obj1.awg)
        %         obj.awg = obj1.awg;
        %     elseif ~isempty(obj2.awg)
        %         obj.awg = obj2.awg;
        %     end
        %     if ~isempty(obj1.awgchnl)
        %         obj.awgchnl = obj1.awgchnl;
        %     elseif ~isempty(obj2.awgchnl)
        %         obj.awgchnl = obj2.awgchnl;
        %     end
        end
        function obj = mrdivide(obj1,obj2)
            % divide one waveform by another to produce a new woveform
            %
            if isnumeric(obj1)
				throw(MException('QOS_waveform:ArithmeticError','numeirc mrdivide is not implemented for waveform class object.'));
				% timefcn = @(t)obj1./obj2.TimeFcn(obj2,t);
                % freqfcn = [];
                % obj = qes.waveform.arbFcn(obj2.length, timefcn, freqfcn;
            elseif isnumeric(obj2)
                obj = copy(obj1)*(1/obj2);
                return;
            end
            obj = qes.waveform.arithmetic(4,obj1,obj2);
        %     obj.name = ['cbwv(', obj1.name, '_divide_',obj2.name,')'];
        %     if length(obj.name) > 50
        %         obj.name = [obj.name(1:118),'..._',num2str(999999*rand(),'%06.0f')];
        %     end


            % awg and awgchnl setting are removed for efficiency, setting dose not
            % bring much convinience anyway because in most case, the awg and channel
            % are set at the final step after all other waveform preparation operations
            % like arithmetics and concatinations are done.

        %     if  ~isempty(obj1.awg) && ~isempty(obj2.awg) && obj1.awg ~= obj2.awg
        %         warning('waveform:awgMismatch',...
        %             'The two waveform objects have different awg objects, awg object of the first waveform object is used!');
        %     end
        % %     if ~isempty(obj1.awgchnl) && ~isempty(obj2.awgchnl) && obj1.awgchnl ~= obj2.awgchnl
        % %         warning('waveform:awgchnlMismatch',...
        % %             'The two waveform objects have different awgchnls, awgchnl of the first waveform object is used!');
        % %     end
        %     if ~isempty(obj1.awg)
        %         obj.awg = obj1.awg;
        %     elseif ~isempty(obj2.awg)
        %         obj.awg = obj2.awg;
        %     end
        %     if ~isempty(obj1.awgchnl)
        %         obj.awgchnl = obj1.awgchnl;
        %     elseif ~isempty(obj2.awgchnl)
        %         obj.awgchnl = obj2.awgchnl;
        %     end
        end
        function obj = mpower(obj1,n)
            % power of wavefrom object
            if n < 0 || round(n) ~= n
                error('waveform:PowerError','power of a waveform object should be a non negative integer.');
            end
            if n == 0
                obj = qes.waveform.arbFcn(obj1.length, @(t)1, @(f) 1*(f==0)); % note: a delta(Amp*Delta(x-x0)) function can not be property reprented
                obj.t0 = obj1.t0;
            elseif n == 1
                obj = copy(obj1);
            else
                obj = copy(obj1);
                for ii = 2:n
                    obj = obj*obj1;
                end
            end
        end

        function obj = horzcat(varargin)
            % use concatenation to buid a waveform sequency, which is also a
            % waveform object:
            % 
            % WvSeriesObj = [wvobj1, wvobj2, Wv_Spacer(5), wvobj4, Wv_Spacer(2), wvobj5];
            % the same as vertcat [wvobj1; wvobj2;...;wvobj5] or [wvobj1 wvobj2 ... wvobj5]
            %
            % WvSeriesObj = [[wvobj1, wvobj2, Wv_Spacer(5)]; wvobj4; [Wv_Spacer(2), wvobj5]]; is OK
            % 
            % WvArray = {wvobj2, Wv_Spacer(5), wvobj4, Wv_Spacer(2)};
            % WvSeriesObj = [wvobj1, WvArray, wvobj5]; is also ok, cells will be unpacked.
            %
            % this is useful when selecting randon waveforms from a waveform pool to
            % build a sequence, for example: WvPool is an cell array of 50 waveforms, 
            % to randonly select 300 waveforms from this pool to build a sequency is just:
            %
            % S = Wv_Spacer(0);
            % r = ceil(50*rand(1,300));
            % Seq = [S, WvPool(r)];
            %
            % the empty Spacer S is just to invoke the horcat method call and will
            % not be included in resulting waveform.
            
        %     if isa(varargin{1},'Wv_Sq')
        %         N = numel(varargin);
        %         WvList = Wv_Sq.GetWvList(varargin{1});
        %         for ii = 2:N
        %             if isa(varargin{ii},'Wv_Sq')
        %                 WvList = [WvList, Wv_Sq.GetWvList(varargin{ii})];
        %             else
        %                 WvList = [WvList, varargin{ii}];
        %             end
        %         end
        %         obj.wvlist = WvList;
        %     end

            if numel(varargin) == 1
%                 % in case of contatinating a single waveform object, a copy
%                 % of this waveform object is returned instead of creating a new waveform object.
                obj = copy(varargin{1});
%                 obj = varargin{1};
                return;
            end
%             if isa(varargin{1},'qes.waveform.sequence')
%                 % this makes progressively concatinating waveforms fast
%                 varargin{1}.wvlist = [varargin{1}.wvlist,varargin(2:end)];
%                 obj = varargin{1};
%                 return;
%             elseif isa(varargin{end},'qes.waveform.sequence')
%                 varargin{end}.wvlist = [varargin(1:end-1),varargin{end}.wvlist];
%                 obj = varargin{end};
%                 return;
%             end
            if isa(varargin{1},'qes.waveform.sequence')
                varargin = [varargin{1}.wvlist, varargin(2:end)];
            end
            if isa(varargin{end},'qes.waveform.sequence')
                varargin = [varargin(1:end-1),varargin{end}.wvlist];
            end
            obj = qes.waveform.sequence(varargin);
            if numel(obj.wvlist) == 1
                obj = obj.wvlist{1}; % happens for SN = [S1,...,Sn]; S1...Sn are spacers 
            end
        end
        function obj = vertcat(varargin)
        % use concatenation to buid a waveform sequence

        %    if isa(varargin{1},'Wv_Sq')
        %         N = numel(varargin);
        %         WvList = Wv_Sq.GetWvList(varargin{1});
        %         for ii = 2:N
        %             if isa(varargin{ii},'Wv_Sq')
        %                 WvList = [WvList, Wv_Sq.GetWvList(varargin{ii})];
        %             else
        %                 WvList = [WvList, varargin{ii}];
        %             end
        %         end
        %         obj.wvlist = WvList;
        %     end
        %     return;

            if numel(varargin) == 1
%                 % in case of contatinating a single waveform object, a copy
%                 % of this waveform object is returned instead of creating a new waveform object.
%                 obj = copy(varargin{1}); 
                % efficiency preceeds elegancy, no copying
                obj = varargin{1};
                return;
            end
%             if isa(varargin{1},'qes.waveform.sequence')
%                 % this makes progressively concatinating waveforms fast
%                 varargin{1}.wvlist = [varargin{1}.wvlist,varargin(2:end)];
%                 obj = varargin{1};
%                 return;
%             elseif isa(varargin{end},'qes.waveform.sequence')
%                 varargin{end}.wvlist = [varargin(1:end-1),varargin{end}.wvlist];
%                 obj = varargin{end};
%                 return;
%             end
            obj = qes.waveform.sequence(varargin);
            if numel(obj.wvlist) == 1
                obj = obj.wvlist{1}; % happens for SN = [S1,...,Sn]; S1...Sn are spacers 
            end
        end
        
        function varargout = subsref(obj,S)
            % a () call to a waveform object will evaluate its time domain function
            % if the frequency function indicator is not set or not true and
            % will evaluate the frequency domain funciton if set to true:
            % v = wvobj(t);         % evaluate time domain function
            % v = wvobj(f,true);	% evaluate frequency domain function
            % a {} call to a waveform object will generate a waveform object
            % of the same class:
            % new_wvobj = wvobj(new_ln);  % new_ln is length, optional
            % new_wvobj = wvobj(wv_struct);   % buid a waveform object from
            % a struct
            varargout = cell(1,nargout);
            switch S(1).type
                case '.'
                    if numel(S) == 1
                        if nargout
                            varargout{:} = obj.(S(1).subs);
                        else
                            obj.(S(1).subs);
                        end
                    else
                        switch S(2).type
                            case '.'
                                if numel(S) > 2 && strcmp(S(3).type, '()')
                                    if nargout
                                        varargout{:} = feval(S(2).subs,obj.(S(1).subs),S(3).subs{:});
                                    else
                                        feval(S(2).subs,obj.(S(1).subs),S(3).subs{:});
                                    end
                                else
                                    if nargout
                                        varargout{:} = subsref(obj.(S(1).subs),S(2:end));
                                    else
                                        subsref(obj.(S(1).subs),S(2:end));
                                    end
                                end
                            case '()'
                                if nargout
                                    if numel(S) == 2
                                        varargout{:} = obj.(S(1).subs)(S(2).subs{:});
                                    else
                                        varargout{:} = subsref(obj.(S(1).subs)(S(2).subs{:}),S(3:end));
                                    end
                                else
                                    if numel(S) == 2
                                        obj.(S(1).subs)(S(2).subs{:});
                                    else
                                        subsref(obj.(S(1).subs)(S(2).subs{:}),S(3:end));
                                    end
                                end
                            case '{}' 
                                if numel(S) == 2
                                    varargout{:} = obj.(S(1).subs){S(2).subs{:}};
                                else
                                    varargout{:} = subsref(obj.(S(1).subs){S(2).subs{:}},S(3:end));
                                end
                        end
                    end
                case '()'
                    if numel(S(1).subs) == 1 || ~S(1).subs{2}
                        if isempty(obj.df) % no frequency mixing
                            varargout{1} = obj.TimeFcn(obj,S(1).subs{1});
                        else
                            varargout{1} = exp(2j*pi*obj.df*S(1).subs{1}-1j*obj.phase).*obj.TimeFcn(obj,S(1).subs{1});
                        end
                    else
                        if isempty(obj.df) % no frequency mixing
                            varargout{1} = obj.FreqFcn(obj,S(1).subs{1});
                        else
                            varargout{1} = exp(-1j*obj.phase)*obj.FreqFcn(obj,S(1).subs{1}-obj.df);
                        end
                    end
                case '{}'
                    if isstruct(S(1).subs{1})
                        varargout{1} = qes.qHandle.ToObject(S(1).subs{1});
                    elseif isa(S(1).subs{1},'qes.waveform.waveform')
                        varargout{1} = S(1).subs{1}; % the waveform itself is returned
                    else
                        varargout{1} = feval(str2func(['@', class(obj)]),S(1).subs{1});
                    end
            end
        end
    end
end