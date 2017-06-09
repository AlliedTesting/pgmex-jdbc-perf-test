% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef IOnDiskBranchedStorage<mxberry.core.cont.IGenericBranchedStorage
    methods
        branchKey=getStorageBranchKey(self)
        storageLocation=getStorageLocation(self)
        storageLocationRoot=getStorageLocationRoot(self)
        fullFileName=getFileNameByKey(self,keyStr,varargin)
    end
end