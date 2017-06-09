% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef MCodeQualityUtilTC < matlab.unittest.TestCase
    methods
        function self = MCodeQualityUtilTC(varargin)
            self = self@matlab.unittest.TestCase(varargin{:});
        end
        %
    end
    methods (Test)
        function testTouch(self)
            import com.mathworks.mlservices.MatlabDesktopServices;
            [~,fileNameList,reportList]=...
                mxberry.selfmnt.MCodeQualityUtils.mlintScanAll();
            %
            diagnosticMsg=...
                mxberry.core.string.catwithsep(fileNameList,sprintf('\n'));
            self.verifyTrue(isempty(fileNameList),diagnosticMsg);
            self.verifyTrue(isempty(reportList),diagnosticMsg);
        end
    end
end