% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef SuiteNegative < mxberry.unittest.TestCase
    properties (Access=private)
        crm
    end
    methods
        function self = SuiteNegative(varargin)
            self = self@mxberry.unittest.TestCase(varargin{:});
        end
    end
    methods (TestMethodSetup)
        function self = set_up_param(self)
            self.crm=mxberry.conf.test.AdpConfRepoMgrNegative();
        end
    end
    methods (Test)
        function test_negativeSelectConf(self)
            inpArgList={'default'};
            crm=self.crm; %#ok<*NASGU,*PROP>
            self.runAndCheckError('crm.selectConf(inpArgList{:})',...
                ':artificialPatchApplicationError','causeCheckDepth',inf);
            self.runAndCheckError('crm.selectConf(inpArgList{:})',...
                ':wrongInput','causeCheckDepth',0);
        end
    end
end