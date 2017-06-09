% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef ANestedArrayUnknownType<mxberry.core.type.ANestedArrayType
    
    methods
        function classNameList=toClassName(STypeInfo) %#ok<MANU>
            classNameList={};
        end
    end
    methods (Access=protected)
        function STypeInfo=getValueTypeStruct(self) %#ok<MANU>
            STypeInfo=struct('type','double','depth',0);
        end
    end
end
