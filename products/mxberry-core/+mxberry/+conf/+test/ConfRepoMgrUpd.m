% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef ConfRepoMgrUpd<mxberry.conf.ConfRepoManagerUpd&...
        mxberry.conf.test.StructChangeTrackerTest
    methods
        function self=ConfRepoMgrUpd(varargin)
            self=self@mxberry.conf.ConfRepoManagerUpd(varargin{:});
            self.setConfPatchRepo(mxberry.conf.test.StructChangeTrackerTest());
        end
    end
end
