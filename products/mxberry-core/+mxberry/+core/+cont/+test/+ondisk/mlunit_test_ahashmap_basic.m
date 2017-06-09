% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef mlunit_test_ahashmap_basic < matlab.unittest.TestCase
    properties (Access=private)
        map
        rel1
        rel2
        testParamList
        mapFactory
    end
    
    methods
        function self = mlunit_test_ahashmap_basic(varargin)
            self = self@matlab.unittest.TestCase(varargin{:});
        end
    end
    properties (MethodSetupParameter)
        mapFactoryParam={mxberry.core.cont.test.ondisk.HashMapXMLMetaDataFactory()};
    end
    methods (TestMethodSetup)
        function self = setUp(self,mapFactoryParam)
            self.mapFactory=mapFactoryParam;
        end
    end
    methods (Test)
        function self = test_defaultProps(self)
            map=self.mapFactory.getInstance(); %#ok<*PROP>
            isHashedKeys=map.getIsHashedKeys();
            isHashedPath=map.getIsHashedPath();
            self.verifyEqual(true,isHashedPath);
            self.verifyEqual(false,isHashedKeys);
        end
    end
end
