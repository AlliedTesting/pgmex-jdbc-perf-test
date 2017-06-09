% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef NestedArrayAnyType<mxberry.core.type.ANestedArrayUnknownType
    methods
        function isPositive=isIncludedInto(~,obj)
            if isa(obj,'mxberry.core.type.NestedArrayAnyType')
                isPositive=true;
            else
                isPositive=false;
            end
        end
    end
    methods
        function isPositive=isCompleteTypeSet(self) %#ok<*MANU>
            isPositive=true;
        end
        function isPositive=isContainedInCellType(self)
            isPositive=false;
        end
        function isPositive=isCellTypeContained(self)
            isPositive=true;
        end
        function typeSeqString=toTypeSequenceString(self)
            typeSeqString='any';
        end
    end
end
