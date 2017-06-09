% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef AdpConfRepoMgrNegative<mxberry.conf.AdaptiveConfRepoManager
    methods
        function self=AdpConfRepoMgrNegative(varargin)
            confPatchRepo=...
                mxberry.conf.test.StructChangeTrackerNegative();
            self.setConfPatchRepo(confPatchRepo);
        end
    end
end
