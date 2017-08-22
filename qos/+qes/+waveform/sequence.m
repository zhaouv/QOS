classdef (Sealed = true) sequence < qes.waveform.waveform
    % waveform sequence
    % Caveat: do not create a sequence object directly:
    % sequence dose not implement careful property validity ckecks for speed,
    % this is not a problem since sequence is not intended
    % for direct user instanciation. A sequence object is automatically
    % created when contatinating a series of waveforms together, for example:
    % WvSeriesObj = [wvobj1, wvobj2, Wv_Spacer(5), wvobj4, Wv_Spacer(2), wvobj5];
    % WvSeriesObj is a sequence instance.
    % WvArray = {wvobj2, Wv_Spacer(5), wvobj4, Wv_Spacer(2)};
    % WvSeriesObj = [wvobj1, WvArray, wvobj5]; is also ok.
    %
    % sequence is an IQ waveform if any of its constituent waveform is an IQ waveform

% Copyright 2016 Yulin Wu, University of Science and Technology of China
% mail4ywu@gmail.com/mail4ywu@icloud.com


    properties
        wvlist
    end
	properties (SetAccess = private, GetAccess = private)
        wvlistProceed
    end
    methods
        function obj = sequence(waveformlist)
            obj = obj@qes.waveform.waveform(0);
            obj.wvlist = waveformlist;
        end
		function set.wvlist(obj,val)
			obj.wvlist = val;
			obj.wvlistProceed = false;
		end
    end
	methods (Access = protected)
		function newobj = copyElement(obj)
			newobj = copyElement@qes.waveform.waveform(obj);
			qes.waveform.sequence.procWvlist(newobj);
			wvlist_ = newobj.wvlist;
			for ii = 1:numel(wvlist_)
				wvlist_{ii} = copy(wvlist_{ii});
			end
			newobj.wvlist = wvlist_;
		end
	end
    methods (Static = true, Hidden = true)
        function v = TimeFcn(obj,t)     
			qes.waveform.sequence.procWvlist(obj);		
            t = t - obj.t0;
            N = numel(obj.wvlist);
            v = zeros(1,numel(t));
            for ii = 1:N
                idx = t>=obj.wvlist{ii}.t0 & t<obj.wvlist{ii}.t0+obj.wvlist{ii}.length;
                if isa(obj.wvlist{ii},'qes.waveform.sequence')
                    v(idx) = subsref(obj.wvlist{ii},struct('type','()','subs',{{t(idx)}}));
                else
                    v(idx) = obj.wvlist{ii}(t(idx));
                end
            end
        end
        function v = FreqFcn(obj,f)
			qes.waveform.sequence.procWvlist(obj);
            N = numel(obj.wvlist);
            v = zeros(1,numel(f));
            for ii = 1:N
                v = v + obj.wvlist{ii}(f,true);
            end
            v = exp(-1j*2*pi*f*obj.t0).*v;
        end
        function procWvlist(obj)
            % this funciton is originally set.wvlist, it is redefined to be
            % a static method and is only called when generating the
            % waveform data, this greatly increase efficiency as in real
            % applications, waveforms are progressively added to the
            % wvlist, and this methnod is called every time. now this
            % method is only called at the final step.
			
			if obj.wvlistProceed
				return;
			end
            
            % all checking is removed for speed, the user is responsible
            % for the validity of wvlist
%             if ~iscell(obj.wvlist)
%                 obj.wvlist = {obj.wvlist};
%             end
%             WvList = {};
%             N = numel(obj.wvlist);
%             for ii = 1:N
%                 if isempty(obj.wvlist{ii})
%                     continue;
%                 end
% %                 if ~isa(obj.wvlist{ii},'Waveform')
% %                     error('Waveform:TypeMismatch', 'In concatination, all arguments should be Waveform classe objects!');
% %                 elseif isempty(obj.wvlist{ii}.length)
% %                     error('Waveform:WaveError', 'at least the length of one waveform object is not set!');
% %                 end
%                 % flatten wave list is not neccessary
%                 if isa(obj.wvlist{ii},'sequence')
%                     WvList = [WvList, sequence.GetWvList(obj.wvlist{ii})];
%                 else
%                     WvList = [WvList, obj.wvlist(ii)];
%                 end
% 
% %                 if isa(obj.wvlist{ii},'sequence')
% %                     WvList = [WvList, obj.wvlist{ii}.wvlist];
% %                 else
% %                     WvList = [WvList, obj.wvlist(ii)];
% %                 end
%             end            
%             WvList = obj.wvlist;
            N = numel(obj.wvlist);
            ii = 1;
            while ii <= N
                if iscell(obj.wvlist{ii}) % unpack cell
                    N = N + numel(obj.wvlist{ii})-1;
                    obj.wvlist = [obj.wvlist(1:ii-1), reshape(obj.wvlist{ii},1,[]), obj.wvlist(ii+1:end)]; 
                    continue;
                else
                    % make a copy is important: in sequence we need to modify the component waveform objects,...
                    % the original waveform object is affected if we don't copy here
                    obj.wvlist{ii} = copy(obj.wvlist{ii});
                end
                ii = ii + 1;
            end

            ii = 2;
            while ii <= N
                if isa(obj.wvlist{ii},'qes.waveform.spacer') && isa(obj.wvlist{ii-1},'qes.waveform.spacer')
                    obj.wvlist{ii-1}.length = obj.wvlist{ii-1}.length + obj.wvlist{ii}.length;
					if obj.wvlist{ii}.iq && ~obj.wvlist{ii-1}.iq
						obj.wvlist{ii-1}.df = 0;
					end
                    obj.wvlist(ii) = [];
                    N = N - 1;
                end
                ii = ii + 1;
            end
            ii = 1;
            % remove empty waveforms, typically zero length spacers
            % 
            while ii <= N 
                if obj.wvlist{ii}.length == 0
                    obj.wvlist(ii) = [];
                    N = N - 1;
                end
                ii = ii + 1;
            end

            for ii = 1:N % make it an IQ waveform if any of its constituent waveform is an IQ waveform
                if obj.wvlist{ii}.iq
                    obj.df = 0;
                    break;
                end
            end
            ln = 0;
            wvlistLn = numel(obj.wvlist);
            fcs = NaN*ones(1,wvlistLn);
            for ii =1:wvlistLn
				% t0 is introduced solely for waveform concatenation, the original value
				% of t0 before this point, whatever it is, is meaningless, thus discarded
                obj.wvlist{ii}.t0 = ln; 
                ln = ln + obj.wvlist{ii}.length;
                if ~isempty(obj.wvlist{ii}.fc)
                    fcs(ii) = obj.wvlist{ii}.fc; % take empty as use what ever
                end
            end
            if obj.iq
                fcs = unique(fcs(~isnan(fcs)));
                if numel(fcs) > 1
                    throw(MException('QOS_waveform:fcMismatch',...
                        'waveforms in the sequence has different fc values.'));
                end
                obj.fc = fcs;
            end
			obj.wvlistProceed = true;
        end
        function WvList = GetWvList(obj)
            WvList = {};
            for ii = 1:numel(obj.wvlist)
                if isa(obj.wvlist{ii},'sequence')
                    WvList = [WvList, sequence.GetWvList(obj.wvlist{ii})];
                else
                    WvList = [WvList, obj.wvlist(ii)];
                end
            end
        end
        function val = GetLength(obj)
            val = 0;
            for ii=1:numel(obj.wvlist)
                val = val + obj.wvlist{ii}.length;
            end
        end
    end
end