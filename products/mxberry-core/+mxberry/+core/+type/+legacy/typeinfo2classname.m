% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
function classNameList=typeinfo2classname(STypeInfo)
%
STypeInfo=mxberry.core.type.NestedArrayType.fromStruct(STypeInfo);
classNameList=STypeInfo.toClassName();