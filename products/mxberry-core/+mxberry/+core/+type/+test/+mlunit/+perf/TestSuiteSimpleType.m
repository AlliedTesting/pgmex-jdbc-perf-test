% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef TestSuiteSimpleType < mxberry.unittest.TestCase
    methods
        function self = TestSuiteSimpleType(varargin)
            self = self@mxberry.unittest.TestCase(varargin{:});
        end
    end
    methods
        function aux_legacy(~,inpArray)
            isOk=isnumeric(inpArray)||ischar(inpArray)||...
                mxberry.core.isrow(inpArray)||isdouble(inpArray)||...
                iscellstr(inpArray)||isa(inpArray,'int32'); %#ok<NASGU>
        end
        function aux_simpleexp(~,inpArray)
            mxberry.core.check.checkgen(inpArray,...
                ['isnumeric(x)||ischar(x)||isrow(x)||',...
                'isdouble(x)||iscellofstring(x)||isa(x,''int32'')']);
        end
    end
    methods (Test)
        function self=test_check(self)
            N_RUNS=100;
            inpArray={'alpha','beta','gamma'};
            self.runAndMeasureTime(@run1,'legacy','nRuns',N_RUNS);
            self.runAndMeasureTime(@run2,'simpleexp','nRuns',N_RUNS);
            %
            function run1()
                aux_legacy(self,inpArray);
            end
            function run2()
                aux_simpleexp(self,inpArray);
            end
        end
    end
end