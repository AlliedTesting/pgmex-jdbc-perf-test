% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef ArrayTestPropForSuite<mxberry.unittest.TestCase
    properties
        simpleTypeNoCharList={{'int8'},{'int16'},{'int32'},{'int64'},{'double'},...
            {'logical'},{'single'},...
            {'uint8'},{'uint16'},{'uint32'},{'uint64'},{'struct'},...
            {'mxberry.core.type.test.TestValueType'},...
            {'mxberry.core.type.test.TestHandleType'}};
        complexTypeList={...
            {'cell','int8'},{'cell','int16'},{'cell','int32'},...
            {'cell','int64'},{'cell','double'},...
            {'cell','logical'},{'cell','single'},...
            {'cell','uint8'},{'cell','uint16'},{'cell','uint32'},...
            {'cell','uint64'},{'cell','char'},...
            {'cell','cell','int64'},{'cell','cell','double'},...
            {'cell','cell','logical'},{'cell','cell','single'},...
            {'cell','cell','uint8'},{'cell','cell','uint16'},...
            {'cell','cell','uint32'},...
            {'cell','cell','uint64'},{'cell','cell','char'},...
            {'cell','struct'},{'cell','cell','struct'},...
            {'cell','mxberry.core.type.test.TestValueType'},...
            {'cell','cell','mxberry.core.type.test.TestValueType'},...
            {'cell','mxberry.core.type.test.TestHandleType'},...
            {'cell','cell','mxberry.core.type.test.TestHandleType'}};
        typeListNoChar
        typeList
        simpleTypeList
        sizeCVec={[10,1],[0 1],[10,2,3],[0,2,3]};
    end
    methods
        function self = ArrayTestPropForSuite(varargin)
            self = self@mxberry.unittest.TestCase(varargin{:});
        end
    end
    methods (TestMethodSetup)
        function self = setUp(self)
            self.typeListNoChar=[self.simpleTypeNoCharList,self.complexTypeList];
            self.simpleTypeList=[self.simpleTypeNoCharList,{{'char'}}];
            self.typeList=[self.typeListNoChar,{{'char'}}];
        end
    end
end