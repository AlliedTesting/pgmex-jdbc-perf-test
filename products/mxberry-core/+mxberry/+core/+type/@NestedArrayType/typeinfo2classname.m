% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
function classNameList=typeinfo2classname(STypeInfo)
%
if STypeInfo.depth>0
    classNameList=[repmat({'cell'},1,STypeInfo.depth),{STypeInfo.type}];
else
    classNameList={STypeInfo.type};
end