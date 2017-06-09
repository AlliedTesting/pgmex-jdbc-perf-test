% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef TestSuiteStaticProp < matlab.unittest.TestCase
    methods
        function self = TestSuiteStaticProp(varargin)
            self = self@matlab.unittest.TestCase(varargin{:});
        end
    end
    methods (TestMethodSetup)
        function self = setUp(self)
            mxberry.core.obj.test.StaticPropStorage.flush();
            mxberry.core.obj.test.StaticPropStorage2.flush();
        end
    end
    methods (Test)
        function self=test_separation(self)
            mxberry.core.obj.test.StaticPropStorage.setProp('alpha',1);
            mxberry.core.obj.test.StaticPropStorage.setProp('beta',11);
            mxberry.core.obj.test.StaticPropStorage2.setProp('alpha',2);
            mxberry.core.obj.test.StaticPropStorage2.setProp('beta',22);
            self.verifyEqual(1,...
                mxberry.core.obj.test.StaticPropStorage.getProp('alpha'));
            %
            self.verifyEqual(2,...
                mxberry.core.obj.test.StaticPropStorage2.getProp('alpha'));
            self.verifyEqual(11,...
                mxberry.core.obj.test.StaticPropStorage.getProp('beta'));
            %
            self.verifyEqual(22,...
                mxberry.core.obj.test.StaticPropStorage2.getProp('beta'));
        end
        function self=test_checkPresence(self)
            mxberry.core.obj.test.StaticPropStorage.setProp('alpha',1);
            mxberry.core.obj.test.StaticPropStorage2.setProp('beta',11);
            %
            [resVal,isThere]=mxberry.core.obj.test.StaticPropStorage2.getProp('beta',true);
            self.verifyEqual(true,isThere);
            self.verifyEqual(11,resVal);
            %
            [resVal,isThere]=mxberry.core.obj.test.StaticPropStorage2.getProp('beta2',true);
            self.verifyEqual(true,isempty(resVal));
            self.verifyEqual(false,isThere);
            %
            [resVal,isThere]=mxberry.core.obj.test.StaticPropStorage.getProp('alpha',true);
            self.verifyEqual(true,isThere);
            self.verifyEqual(1,resVal);
            %
            [resVal,isThere]=mxberry.core.obj.test.StaticPropStorage.getProp('alpha2',true);
            self.verifyEqual(false,isThere);
            self.verifyEqual(true,isempty(resVal));
            %
            try
                [~,~]=mxberry.core.obj.test.StaticPropStorage.getProp('alpha2');
            catch meObj
                self.aux_checkNoPropException(meObj);
            end
            try
                [~,~]=mxberry.core.obj.test.StaticPropStorage.getProp('alpha2',false);
            catch meObj
                self.aux_checkNoPropException(meObj);
            end
            
        end
    end
    methods
        function aux_checkNoPropException(self,meObj)
            self.verifyEqual(true,~isempty(strfind(...
                meObj.identifier,':noProp')));
        end
        
    end
end