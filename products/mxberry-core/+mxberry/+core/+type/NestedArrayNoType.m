% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef NestedArrayNoType<mxberry.core.type.ANestedArrayUnknownType
    methods
        function isPositive=isIncludedInto(~,~)
            isPositive=true;
        end
    end
    methods
        function isPositive=isEmptyTypeSet(self) %#ok<*MANU>
            isPositive=true;
        end
        function isPositive=isContainedInCellType(self)
            isPositive=true;
        end
        function isPositive=isCellTypeContained(self)
            isPositive=false;
        end
        function typeSeqString=toTypeSequenceString(self)
            typeSeqString='no';
        end
    end
end
