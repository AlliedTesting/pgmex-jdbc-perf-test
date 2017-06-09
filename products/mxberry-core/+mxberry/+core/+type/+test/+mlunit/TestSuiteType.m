% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef TestSuiteType < matlab.unittest.TestCase
    properties
    end
    
    methods
        function self = TestSuiteType(varargin)
            self = self@matlab.unittest.TestCase(varargin{:});
        end
    end
    methods (Test)
        function self=test_isIncludedInto(self)
            %1
            anyCellObj=mxberry.core.type.NestedArrayType.fromClassName({'cell',''});
            %2
            cellOfCharObj=mxberry.core.type.NestedArrayType.fromClassName({'cell','cell','char'});
            %3
            charObj=mxberry.core.type.NestedArrayType.fromClassName({'char'});
            %4
            anyObj=mxberry.core.type.NestedArrayAnyType();
            %5
            noObj=mxberry.core.type.NestedArrayNoType();
            %6
            anyCellOfCellsObj=mxberry.core.type.NestedArrayType.fromClassName({'cell','cell',''});
            %
            objList={anyCellObj,cellOfCharObj,charObj,anyObj,noObj,anyCellOfCellsObj};
            nObj=numel(objList);
            combAndIsIncludedExpCMat={[1     1],true;
                [1     2],false;
                [1     3],false;
                [1     4],true;
                [1     5],false;
                [1     6],false;
                [2     1],true;
                [2     2],true;
                [2     3],false;
                [2     4],true;
                [2     5],false;
                [2     6],true;
                [3     1],false;
                [3     2],false;
                [3     3],true;
                [3     4],true;
                [3     5],false;
                [3     6],false;
                [4     1],false;
                [4     2],false;
                [4     3],false;
                [4     4],true;
                [4     5],false;
                [4     6],false;
                [5     1],true;
                [5     2],true;
                [5     3],true;
                [5     4],true;
                [5     5],true
                [5     6],true};
            objPairList=cellfun(@(x)objList(x),...
                combAndIsIncludedExpCMat(:,1),'UniformOutput',false);
            %
            nPairs=size(objPairList,1);
            isIncludedVec=true(nPairs,1);
            for iPair=1:nPairs
                isIncludedVec(iPair)=objPairList{iPair}{1}.isIncludedInto(...
                    objPairList{iPair}{2});
            end
            self.verifyEqual(vertcat(combAndIsIncludedExpCMat{:,2}),...
                isIncludedVec);
            %
            isIncludedExpVec=[true;true;false;false;true;true];
            %
            isIncludedVec=isIncludedExpVec;
            for iObj=1:nObj
                isIncludedVec(iObj)=objList{iObj}.isContainedInCellType();
            end
            %
            self.verifyEqual(true,isequal(isIncludedVec,isIncludedExpVec));
        end
        function self=test_toStruct(self)
            obj1=mxberry.core.type.NestedArrayType.fromClassName(...
                {'cell','char'});
            obj2=mxberry.core.type.NestedArrayType.fromClassName(...
                {'char'});
            [~]=struct(obj1);
            [~]=struct(obj2);
        end
        function self=test_nestedArrayFactory_fromClassName(self)
            %
            classSpecNamePairMat={...
                {{'char'},'no'},'mxberry.core.type.NestedArrayType';
                {{'char'},'any'},'mxberry.core.type.NestedArrayType';
                {{'cell'},'no'},'mxberry.core.type.NestedArrayType';
                {{'cell','cell'},'any'},'mxberry.core.type.NestedArrayType';
                {{'cell','cell'},'no'},'mxberry.core.type.NestedArrayType';
                {{'cell'},'any'},'mxberry.core.type.NestedArrayType';
                {{''},'no'},'mxberry.core.type.NestedArrayNoType';
                {{},'any'},'mxberry.core.type.NestedArrayAnyType';
                {{''},'any'},'mxberry.core.type.NestedArrayAnyType';
                {{},'no'},'mxberry.core.type.NestedArrayNoType'...
                };
            nPairs=size(classSpecNamePairMat,1);
            for iPair=1:nPairs
                type=mxberry.core.type.NestedArrayTypeFactory.fromClassName(...
                    classSpecNamePairMat{iPair,1}{:});
                self.verifyEqual(true,...
                    isa(type,classSpecNamePairMat{iPair,2}),...
                    sprintf('failed for pair %d',iPair));
            end
        end
    end
end