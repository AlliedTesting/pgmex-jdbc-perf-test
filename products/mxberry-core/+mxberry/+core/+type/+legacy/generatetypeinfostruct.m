function [isUniform,STypeInfo]=generatetypeinfostruct(value)
% GENERATETYPEINFOSTRUCT constructs a meta structure containing a
% complete (recursive for cells)
% information about type of input array
%
% Input: value - array of any type
%
% Output:
%   isUniform: logical[1,1]
%
%   STypeInfo struct[1,1] containing type information for input
%      array, contains the following fields
%
%      type: char[1,]
%      itemTypeInfo: STypeInfo[1,]
%      isCell: logical[1,1]

%
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
%
% [isUniform,STypeInfo]=mxberry.core.type.NestedArrayType.fromValue(value);
% STypeInfo=STypeInfo.toStruct();
[isUniform,STypeInfo]=mxberry.core.type.NestedArrayType.generatetypeinfostruct(value);