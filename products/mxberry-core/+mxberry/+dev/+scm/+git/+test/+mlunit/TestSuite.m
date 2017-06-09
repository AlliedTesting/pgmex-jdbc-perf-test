% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef TestSuite < matlab.unittest.TestCase
    properties (Access=private)
        locDir
    end
    methods
        function self = TestSuite(varargin)
            self = self@matlab.unittest.TestCase(varargin{:});
            self.locDir=fileparts(which(mfilename('class')));
        end
    end
    methods (Test)
        function testMain(self)
            if mxberry.dev.scm.git.isgit(self.locDir)
                hashStr=mxberry.dev.scm.git.gitgethash(self.locDir);
                self.verifyEqual(40,numel(hashStr));
                self.check(hashStr);
                urlStr=mxberry.dev.scm.git.gitgeturl(self.locDir);
                self.check(urlStr);
                branchStr=mxberry.dev.scm.git.gitgetbranch(self.locDir);
                self.check(branchStr);
            end
        end
    end
    methods
        function check(self,strToCheck)
            self.verifyTrue(isequal(strToCheck,strtrim(strToCheck)));
        end
    end
end
