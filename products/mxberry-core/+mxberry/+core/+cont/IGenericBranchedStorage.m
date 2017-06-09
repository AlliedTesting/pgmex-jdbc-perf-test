% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef IGenericBranchedStorage<handle
    methods
        keyList=getKeyList(self)
        [valueList,varargout]=get(self,keyList,varargin)
        [isKeyVec,fullFileNameCVec]=isKey(self,keyList)
        put(self,keyList,valueObjList,varargin)
        remove(self,keyList)
        removeAll(self)
    end
end