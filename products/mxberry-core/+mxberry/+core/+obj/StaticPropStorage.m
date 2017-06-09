% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef StaticPropStorage<handle
    methods (Static,Access=private)
        function [propVal,isThere]=setGetProp(isFlushed,...
                isPresenceChecked,branchName,propName,propVal)
            import mxberry.core.throwerror;
            persistent branchStorage;
            if isempty(branchStorage)
                branchStorage=containers.Map;
            end
            if nargin>2
                if ~branchStorage.isKey(branchName) || isFlushed
                    branchStorage(branchName)=containers.Map();
                end
                if nargin>4
                    propStorage=branchStorage(branchName);
                    propStorage(propName)=propVal; %#ok<NASGU>
                end
            end
            if nargout>0
                try
                    propStorage=branchStorage(branchName);
                    if nargout>1&&isPresenceChecked
                        isThere=propStorage.isKey(propName);
                        if isThere
                            propVal=propStorage(propName);
                        else
                            propVal=[];
                        end
                    else
                        propVal=propStorage(propName);
                        isThere=true;
                    end
                catch meObj
                    if ~isempty(strfind(meObj.identifier,':NoKey'))
                        newMeObj=throwerror('noProp',...
                            'property %s is missing',propName);
                        newMeObj=addCause(newMeObj,meObj);
                        throw(newMeObj);
                    else
                        rethrow(meObj);
                    end
                end
            end
        end
    end
    
    methods (Static,Access=protected)
        function [propVal,isThere]=getPropInternal(branchName,propName,...
                isPresenceChecked)
            if nargin<3
                isPresenceChecked=false;
            end
            [propVal,isThere]=...
                mxberry.core.obj.StaticPropStorage.setGetProp(...
                false,isPresenceChecked,branchName,propName);
        end
        function setPropInternal(branchName,propName,propVal)
            mxberry.core.obj.StaticPropStorage.setGetProp(...
                false,false,branchName,propName,propVal);
        end
        function flushInternal(branchName)
            mxberry.core.obj.StaticPropStorage.setGetProp(true,false,...
                branchName);
        end
    end
    
end
