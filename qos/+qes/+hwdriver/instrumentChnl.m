classdef (Sealed = true) instrumentChnl < qes.qHandle
    % instrument channel

% Copyright 2017 Yulin Wu, USTC, China
% mail4ywu@gmail.com/mail4ywu@icloud.com

    properties (SetAccess = private)
        % a non exclusive instrumentChnl occupies the instrument channel and
        % prohibits other applications from getting this channel untill released.
        % a exclusive instrumentChnl has access to the instrument channel but
        % dose not block other applications from accessing this channnel.
        exclusive
    end
	properties (SetAccess = private,GetAccess = private)
		instrumentObj
		chnl
	end
    methods
        function obj = instrumentChnl(iObj,ch,exclusive_)
            if nargin < 3
                exclusive_ = false;
            end
            if ~isa(iObj,'qes.hwdriver.multiChnl')
				throw(MException('QOS_instrumentChnl:invalidInput',...
					'an instrumentChnl object can only be built on a multiChnl hardware object.'));
            end
			obj.instrumentObj = iObj;
            iObj.TakeChnl(ch,exclusive_);
            obj.chnl = ch;
            obj.exclusive = exclusive_;
        end
        function delete(obj)
            if ~isempty(obj.chnl)
                obj.instrumentObj.ReleaseChnl(obj.chnl);
            end
        end
    end
	methods (Hidden = true)
		function bol = eq(obj1,obj2)
			% eq method has to be redefined
			bol = (obj1.instrumentObj == obj2.instrumentObj) &...
				(obj1.chnl == obj2.chnl);
		end
        function bol = isprop(obj,propName)
            % overloads MATLAB isprop fucntion
            bol = ismember(propName,obj.instrumentObj.chnlProps);
        end
		function varargout = subsref(obj,S)
            % redirects everything except delete to the underlying instrumentObj
            varargout = cell(1,nargout);
			iObj = obj.instrumentObj;
            switch S(1).type
                case '.'
                    if numel(S) == 1
                        if strcmp(S(1).subs,'delete')
                            obj.delete();
                            return;
                        end
                        fname = S(1).subs;
                        [ret,idx] = ismember(fname,iObj.chnlProps);
                        if ret
                            if nargout
                                varargout{:} = iObj.chnlPropGetMothds{idx}(iObj,obj.chnl);
                            else
                                iObj.chnlPropGetMothds{idx}(iObj,obj.chnl);
                            end
                        else
                            if nargout
                                varargout{:} = iObj.(fname);
                            else
                                iObj.(fname);
                            end
                        end
                    elseif strcmp(S(2).type, '()') && strcmp(S(1).subs,'delete')
                        obj.delete();
                        return;
                    else
                        switch S(2).type
                            case '.'
                                if nargout
                                    varargout{:} = subsref(iObj.(S(1).subs),S(2:end));
                                else
                                    subsref(iObj.(S(1).subs),S(2:end));
                                end
                            case '()'
                                if nargout
                                    if numel(S) == 2
                                        varargout{:} = iObj.(S(1).subs)(S(2).subs{:});
                                    else
                                        varargout{:} = subsref(iObj.(S(1).subs)(S(2).subs{:}),S(3:end));
                                    end
                                else
                                    if numel(S) == 2
                                        iObj.(S(1).subs)(S(2).subs{:});
                                    else
                                        subsref(iObj.(S(1).subs)(S(2).subs{:}),S(3:end));
                                    end
                                end
                            case '{}' 
                                if numel(S) == 2
                                    varargout{:} = iObj.(S(1).subs){S(2).subs{:}};
                                else
                                    varargout{:} = subsref(iObj.(S(1).subs){S(2).subs{:}},S(3:end));
                                end
                        end
                    end
                otherwise % as a rule, a multiChnl object should not be callable
                    throw(MException('QOS_instrumentChnl:invalidUsage',...
						'invalid usage.'));
            end
        end
		function obj = subsasgn(obj,S,val)
            % redirects everything to the underlying instrumentObj
			iObj = obj.instrumentObj;
			switch S(1).type
                case '.'
                    fname = S(1).subs;
                    [~,idx] = ismember(fname,iObj.chnlProps);
                    if ~ismember(fname,iObj.chnlProps)
                        if numel(S) == 1
                            iObj.(S(1).subs) = val;
                        else
                            obj = subsasgn(iObj.(S(1).subs),S(2:end),val);
                        end
                    else
                        iObj.chnlPropSetMothds{idx}(iObj,val,obj.chnl);
                    end
				otherwise
					throw(MException('QOS_instrumentChnl:invalidUsage',...
						'invalid usage.'));
			end
		end
	end
end