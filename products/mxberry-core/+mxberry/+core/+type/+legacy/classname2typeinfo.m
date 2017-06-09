function STypeInfo=classname2typeinfo(classNameList)
% CLASSNAME2TYPEINFO translates built-in class names into STypeInfo
% definitions
%
% Input:
%   classNameList: char/cell[1,nNestedLevels]
%
% Output:
%   STypeInfo: struct[1,1] - type information
%
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
%
STypeInfo=struct(mxberry.core.type.NestedArrayType.fromClassName(classNameList));




