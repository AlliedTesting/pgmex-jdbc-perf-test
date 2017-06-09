% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef NestedArrayTypeFactory<mxberry.core.type.NestedArrayType
    methods (Access=private)
        function self=NestedArrayTypeFactory()
        end
    end
    methods (Static,Access=private)
        function resCArray=unknownTypeCellArray(typeKindName,sizeVec)
            if strcmpi(typeKindName,'any')
                resCArray=repmat({mxberry.core.type.NestedArrayAnyType()},sizeVec);
            elseif strcmpi(typeKindName,'no')
                resCArray=repmat({mxberry.core.type.NestedArrayNoType()},...
                    sizeVec);
            else
                mxberry.core.throwerror('wrongInput',...
                    '%s is unsupported unknownTypeKindName',...
                    typeKindName);
            end
        end
        function res=unknownType(typeKindName)
            if strcmpi(typeKindName,'any')
                res=mxberry.core.type.NestedArrayAnyType();
            elseif strcmpi(typeKindName,'no')
                res=mxberry.core.type.NestedArrayNoType();
            else
                mxberry.core.throwerror('wrongInput',...
                    '%s is unsupported unknownTypeKindName',...
                    typeKindName);
            end
        end
    end
    methods (Static)
        function resCArray=fromClassNameArray(classNameListCArray,unknownTypeKindName)
            resCArray=cell(size(classNameListCArray));
            nElem=numel(resCArray);
            for iElem=1:nElem
                resCArray(iElem)={...
                    mxberry.core.type.NestedArrayTypeFactory.fromClassName(...
                    classNameListCArray{iElem},unknownTypeKindName)};
            end
        end
        function resObj=fromValue(value)
            resObj=mxberry.core.type.NestedArrayType.fromValue(value);
        end
        function resObj=fromClassName(classNameList,unknownTypeKindName)
            if ~iscellstr(classNameList)
                mxberry.core.throwerror('wrongInput',...
                    'classNameList is expected to be a cell array of strings');
            end
            %
            if isempty(classNameList)||...
                    numel(classNameList)==1&&...
                    ischar(classNameList{1})&&...
                    isempty(classNameList{1})
                resObj=mxberry.core.type.NestedArrayTypeFactory.unknownType(...
                    unknownTypeKindName);
            else
                resObj=mxberry.core.type.NestedArrayType.fromClassName(classNameList);
            end
        end
    end
end
