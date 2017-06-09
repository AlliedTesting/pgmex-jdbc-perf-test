classdef TestCompareWithJDBC < ...
        com.allied.pgmex.perftest.ATestCompareWithJDBC
    methods (TestMethodSetup)
        function method_set_up(self)
            testModeName=self.confRepoMgr.getParam(...
                'performanceTestingParams.testModeName');
            self.setUpTestMode(testModeName);
        end
    end
    methods
        function self = TestCompareWithJDBC(varargin)
            self = self@com.allied.pgmex.perftest.ATestCompareWithJDBC(...
                varargin{:});
        end
    end
end