% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef ANestedArrayType
    methods (Abstract)
        typeSeqString=toTypeSequenceString(self)
        isPositive=isContainedInCellType(self)
        isPositive=isCellTypeContained(self)
        classNameList=toClassName(STypeInfo)
    end
    methods (Abstract,Access=protected)
        STypeInfo=getValueTypeStruct(self)
    end
    methods (Abstract)
        isPositive=isIncludedInto(self,obj)
    end
    methods (Access=protected)
        function isPositive=isEqual(self,obj)
            isPositive=self.isIncludedInto(obj)&&obj.isIncludedInto(self);
        end
        %
        function throwCannotDetermineIfIncludedIntoException(self) %#ok<*MANU>
            mxberry.core.throwerror('noCanDo',...
                ['cannot determine is the specified object',...
                'is included into another object, sorry.']);
        end
    end
    methods
        function valueMat=createDefaultArray(self,sizeInpVec)
            valueMat=mxberry.core.type.ANestedArrayType.createarraybytypeinfo(...
                self.getValueTypeStruct(),sizeInpVec);
        end
        function depth=getDepth(self)
            depth=self.getValueTypeStruct().depth;
        end
        function typeName=getTypeName(self)
            typeName=self.getValueTypeStruct().type;
        end
        function isPositive=isEmptyTypeSet(self)
            isPositive=false;
        end
        function isPositive=isCompleteTypeSet(self)
            isPositive=false;
        end
        %
        function disp(self)
            fprintf('ANestedArrayType, type: %s, type sequence: %s\n',...
                class(self),self.toTypeSequenceString);
        end
        function isPositive=isequal(self,obj)
            isPositive=isEqual(self,obj);
        end
        function isPositive=eq(self,obj)
            isPositive=isEqual(self,obj);
        end
        function isPositive=ne(self,obj)
            isPositive=~isEqual(self,obj);
        end
    end
    methods (Static)
        valueMat=createarraybytypeinfo(STypeInfoInp,sizeInpVec,varargin)
    end
end