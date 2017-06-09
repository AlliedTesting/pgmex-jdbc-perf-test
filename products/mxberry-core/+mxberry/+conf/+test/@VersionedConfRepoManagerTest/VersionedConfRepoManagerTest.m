% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef VersionedConfRepoManagerTest<mxberry.conf.VersionedConfRepoManager&...
        mxberry.conf.test.StructChangeTrackerTest
    methods
        function self=VersionedConfRepoManagerTest(varargin)
            self=self@mxberry.conf.VersionedConfRepoManager(varargin{:});
        end
    end
end
