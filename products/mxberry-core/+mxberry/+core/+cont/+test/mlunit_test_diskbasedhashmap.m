% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef mlunit_test_diskbasedhashmap<...
        mxberry.core.cont.test.ADiskBasedHashMapTC
    %
    methods
        function self = mlunit_test_diskbasedhashmap(varargin)
            self = self@mxberry.core.cont.test.ADiskBasedHashMapTC(...
                varargin{:});
        end
    end
    properties (MethodSetupParameter)
        argList=mxberry.core.cont.test.createparamlist(...
            mxberry.core.cont.test.DiskBasedHashMapFactory(),...
            {'mat','xml'},[true,false]);
    end
end