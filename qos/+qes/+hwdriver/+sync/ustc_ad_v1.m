classdef ustc_ad_v1 < qes.hwdriver.hardware
    % wrap ustcadda as ad
    
% Copyright 2016 Yulin Wu, Institute of Physics, Chinese  Academy of Sciences
% mail4ywu@gmail.com/mail4ywu@icloud.com
    properties
        recordLength
		range
    end
    properties (SetAccess = private)
        numChnls
		samplingRate
    end
    properties (Dependent = true)
        delayStep % unit: DA sampling points
    end
    properties (SetAccess = private, GetAccess = private)
        chnlMap
        ustcaddaObj
    end
    methods (Access = private)
        function obj = ustc_ad_v1(name,chnlMap_)
            if iscell(chnlMap_) % for chnlMap_ data loaded from registry saved as json array
                chnlMap_ = cell2mat(chnlMap_);
            end
            obj = obj@qes.hwdriver.hardware(name);
            obj.ustcaddaObj = qes.hwdriver.sync.ustcadda_v1.GetInstance();
            obj.ustcaddaObj.Open(); % in case not openned already
            
            if numel(unique(chnlMap_)) ~= numel(chnlMap_)
                throw(MException('QOS_ustc_ad:duplicateChnls','bad chnlMap settings: duplicate channels found.'));
            end
            if ~all(chnlMap_<=obj.ustcaddaObj.numADChnls)
                throw(MException('QOS_ustc_da:nonExistChnls','chnlMap contains non-exist channels on AD.'));
            end
            assert(all(round(chnlMap_) == chnlMap_) & all(chnlMap_>0),'invalidInput');
       
			obj.ustcaddaObj.TakeADChnls(chnlMap_);
            obj.chnlMap = chnlMap_;
			obj.numChnls = numel(chnlMap_);
			
			obj.samplingRate = unique(obj.ustcaddaObj.GetADChnlSamplingRate(obj.chnlMap));
			if numel(obj.samplingRate) > 1
				obj.ustcaddaObj.ReleaseADChnls(chnlMap_);
				throw(MException('QOS_ustc_ad:samplingRateMismatch','building a ad object on channels with different sampling rate is not allowed '));
			end
        end
    end
    methods
		function val = get.recordLength(obj)
            val = obj.ustcaddaObj.adRecordLength;
        end
        function set.recordLength(obj,val)
            obj.ustcaddaObj.adRecordLength = val;
        end
		function val = get.range(obj)
            val = obj.ustcaddaObj.adRange;
        end
        function set.range(obj,val)
            obj.ustcaddaObj.adRange = val;
        end
		function val = get.delayStep(obj)
            val = obj.ustcaddaObj.adDelayStep;
        end
        function [I,Q] = Run(obj,N)
            obj.ustcaddaObj.runReps = N; % this only takes ~70us, the next line takes ~300ms
            [I,Q] = obj.ustcaddaObj.Run(true);
        end
		
		function delete(obj)
			obj.ustcaddaObj.ReleaseADChnls(obj.chnlMap);
            if isempty(obj.ustcaddaObj.adTakenChnls) &&...
                    isempty(obj.ustcaddaObj.daTakenChnls)
                obj.ustcaddaObj.delete();
            end
		end
    end
    
    methods (Static = true)
        function obj = GetInstance(name,chnlMap_) 
            persistent objlst;
            if isempty(objlst) || ~isvalid(objlst)
                obj = qes.hwdriver.sync.ustc_ad_v1(name,chnlMap_);
                objlst = obj;
            else
                obj = objlst;
            end
        end
    end
    
end