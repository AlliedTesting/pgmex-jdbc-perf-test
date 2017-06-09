% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef StructChangeTrackerTC < matlab.unittest.TestCase
    properties
        tracker
    end
    methods (TestMethodSetup)
        function self = setUp(self)
            self.tracker=mxberry.core.struct.test.StructChangeTrackerTest();
        end
    end
    methods
        function self = StructChangeTrackerTC(varargin)
            self = self@matlab.unittest.TestCase(varargin{:});
        end
    end
    methods (Test)
        function self = test_simple_patch(self)
            SRes=self.tracker.applyPatches(struct(),0,1);
            self.verifyEqual(SRes.alpha,1);
            %
            SRes=self.tracker.applyPatches(struct(),0,2);
            self.verifyEqual(SRes.beta,3);
            self.verifyEqual(SRes.alpha,1);
            %
            SRes=self.tracker.applyPatches(struct(),0,103);
            self.verifyEqual(SRes.beta,2);
            SResInf=self.tracker.applyPatches(struct(),-inf,inf);
            self.verifyEqual(true,isequal(SRes,SResInf));
        end
    end
end
