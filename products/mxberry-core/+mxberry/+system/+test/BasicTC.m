% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef BasicTC < matlab.unittest.TestCase
    methods
        function self = BasicTC(varargin)
            self = self@matlab.unittest.TestCase(varargin{:});
        end
    end
    methods (Test)
        function testHostName(self)
            nArgoutVec=[1,2];
            for nArgout=nArgoutVec
                outList=cell(1,nArgout);
                lastwarn('');
                [outList{:}]=mxberry.system.getuserhost(); %#ok<NASGU>
                lastWarn=lastwarn();
                self.verifyTrue(isempty(lastWarn),lastWarn);
            end
        end
        function testPidHost(self)
            nArgoutVec=[1,2,3];
            for nArgout=nArgoutVec
                outList=cell(1,nArgout);
                lastwarn('');
                [outList{:}]=mxberry.system.getpidhost(); %#ok<NASGU>
                lastWarn=lastwarn();
                self.verifyTrue(isempty(lastWarn),lastWarn);
            end
        end
        function testCompareHostName(self)
            [~,hostNameExp]=mxberry.system.getuserhost();
            [~,~,hostName]=mxberry.system.getpidhost();
            self.verifyEqual(hostNameExp,hostName);
        end
    end
end