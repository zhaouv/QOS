classdef iq_ustc_ad < qes.measurement.iq
    %

% Copyright 2016 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties
        n % number of averages
        % raw voltage is truncated to only keep data in range of
        % startidx:endidx, if not specified, no truncation
        % use ShowVoltSignal to show the voltage signal and choose the
        % correct truncation index.
        startidx = 1
        endidx
        freq % demod frequency, Hz
%         singlechnl@logical  = true % use single channel or use both I chnl and Q chnl
        
        eps_a = 0 % mixer amplitude correction
        eps_p = 0 % mixer phase correction
        upSampleNum = 1 % upsample to match DA sampling rate
    end
    properties (SetAccess = private, GetAccess = private)
        % Cached variables
        Mc = [1, 0; 0, 1]          % mixer correction matrix
        IQ          % IQ = NaN*zeros(numFreq,obj.n); % numFreq = numel(obj.freq);

        selectidx   % selectidx = obj.startidx:obj.eidx;
        kernel      % kernel = exp(-2j*pi*obj.freq(ii).*t);
    end
	methods
        function obj = iq_ustc_ad(InstrumentObject)
            if isempty(strfind(class(InstrumentObject),'ustc_ad_')) ||...
                    ~isvalid(InstrumentObject)
                throw(MException('iq_ustc_ad:InvalidInput',...
                    'InstrumentObject is not a valid ustc_ad class object!'));
            end
            if isempty(InstrumentObject.recordLength)
                throw(MException('iq_ustc_ad:InvalidInput','recordLength of InstrumentObject not set.'));
            end
            obj = obj@qes.measurement.iq(InstrumentObject);
        end
        function set.n(obj,val)
            if isempty(val) || ceil(val) ~=val || val <=0
                throw(MException('iq_ustc_ad:InvalidInput','n should be a positive integer!'));
            end
            obj.n = val;
            if ~isempty(obj.freq)
                obj.IQ = NaN*zeros(numel(obj.freq),obj.n);
            end
        end
        function set.freq(obj,val)
            obj.freq = val;
            if ~isempty(obj.n)
                obj.IQ = NaN*zeros(numel(obj.freq),obj.n);
            end
            calcCachedVar(obj);
        end
        function set.upSampleNum(obj,val)
            if isempty(val)
                throw(MException('QOS_iq_ustc_ad:emptyUnpSampleNum','upSampleNum can not be empty.'));
            end
            if round(val) ~= val || val < 1
                throw(MException('QOS_iq_ustc_ad:nonIntegerUnpSampleNum',...
                    sprintf('upSampleNum must be a positive integer, %0.2f given.',val)));
            end
            obj.upSampleNum = val;
            calcCachedVar(obj);
        end
        function set.startidx(obj,val)
            val = ceil(val);
            if val < 1 || val > obj.instrumentObject.recordLength || (~isempty(obj.endidx) && val >= obj.endidx)
                throw(MException('iq_ustc_ad:InvalidInput',...
                    'startidx should be an interger greater than 0 and smaller than AD recordLength and endidx!'));
            end
            obj.startidx = val;
            calcCachedVar(obj);
        end
        function set.endidx(obj,val)
            val = ceil(val);
            if val <= obj.startidx || val > obj.instrumentObject.recordLength
                throw(MException('iq_ustc_ad:InvalidInput',...
                    'endidx should be an interger greater than startidx and not exceeding AD recordLength!'));
            end
            obj.endidx = val;
            calcCachedVar(obj);
        end
        function set.eps_a(obj,val)
            obj.eps_a = val;
            obj.Mc = [1-obj.eps_a/2, -obj.eps_p; -obj.eps_p, 1+obj.eps_a/2]; 
        end
        function set.eps_p(obj,val)
            obj.eps_p = val;
            obj.Mc = [1-obj.eps_a/2, -obj.eps_p; -obj.eps_p, 1+obj.eps_a/2];
        end
        function ShowVoltSignal(obj,ax)
            % plot the I Q raw voltage signals, you may need this to
            % choose startidx and endidx
            [VI,VQ] = obj.instrumentObject.Run(1);
            t_ = 1e9*(0:length(VI)-1)/obj.instrumentObject.samplingRate;
%             plotyy(t,VI,t,VQ);
            if nargin < 2
                hf = qes.ui.qosFigure('AD Voltage Signal',true);
                ax = axes('Parent',hf);
                hold(ax,'on');
            end
            plot(ax,t_,VI,t_,VQ);
            drawnow;
            xlabel('Time (1/sampling rate)');
            ylabel('Digitizer Voltage Signal');
            title('Voltage signal of one segament, not trucated, by this plot you should choose the right truncation idexes for the IQ extraction process.');
            legend({'I voltage','Q voltage'});
        end
        function Run(obj)
            % Run the measurement
            if isempty(obj.n)
                throw(MException('iq_ustc_ad:RunError','some properties are not set yet!'));
            end
            Run@qes.measurement.measurement(obj); % check object and its handle properties are isvalid or not
%             disp('===========');
%             tic
            [Vi,Vq] = obj.instrumentObject.Run(obj.n);
%             toc
            Vi = double(Vi) -127;
            Vq = double(Vq) -127;
%             tic
%             IQ = obj.Run_BothChnl(Vi,Vq);
% %             toc 
%             obj.data = mean(IQ);
%             obj.extradata = IQ;
            
            obj.Run_BothChnl(Vi,Vq);
%             toc 
            obj.data = mean(obj.IQ);
            obj.extradata = obj.IQ;
            
            obj.dataready = true;
        end
    end
    methods (Access = private,Hidden = true)
        function calcCachedVar(obj)
            if ~isempty(obj.startidx) && ~isempty(obj.freq)
                NperSeg = obj.instrumentObject.recordLength;
                if isempty(obj.endidx)
                    eidx = obj.upSampleNum*NperSeg;
                else
                    eidx = obj.endidx;
                end
                % typically, one needs to remove a few data points at the
                % beginning or at the end of each segament due to trigger
                % and signal may not be exactly syncronized.
                obj.selectidx = obj.startidx:obj.upSampleNum:eidx;
                t = (obj.selectidx-obj.startidx)/...
                    (obj.instrumentObject.samplingRate*obj.upSampleNum);
                obj.kernel = zeros(numel(obj.freq),numel(t));
                for ii = 1:numel(obj.freq)
                    obj.kernel(ii,:) = exp(-2j*pi*obj.freq(ii).*t);
                end
            end
        end
%         function IQ = Run_BothChnl(obj,Vi, Vq)
          function Run_BothChnl(obj, Vi, Vq)
%             NperSeg = obj.instrumentObject.recordLength;
%             if isempty(obj.endidx)
%                 eidx = NperSeg;
%             else
%                 eidx = obj.endidx;
%             end
            disp('====')
            obj.selectidx(1)
            obj.selectidx(end)
            
            if obj.upSampleNum ~= 1
                dLn = size(Vi,2);
                xi = 1:obj.upSampleNum:obj.upSampleNum*dLn;
                x = 1:obj.upSampleNum*dLn;
                Vi = interp1(xi,Vi,x,'linear');
                Vq = interp1(xi,Qi,x,'linear');
            end
            Vi = Vi(:,obj.selectidx);
            Vq = Vq(:,obj.selectidx);
            
            for ii = 1:numel(obj.freq)
                for jj = 1:obj.n
                    IQ_ = obj.kernel(ii,:).*(Vi(jj,:)+1j*Vq(jj,:));
                    IQ_ = mean(obj.Mc*[real(IQ_);imag(IQ_)],2); % correct mixer imballance
                    obj.IQ(ii,jj) = IQ_(1)+1j*IQ_(2);
                end
            end
        end
        function Amp = Amp(obj, Vi, Vq)
            Amp = sum(abs(Vi(:)))+ sum(abs(Vq(:)));
        end
    end
    
end