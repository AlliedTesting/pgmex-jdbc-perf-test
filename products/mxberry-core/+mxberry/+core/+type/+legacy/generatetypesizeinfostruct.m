function STypeSizeInfo=generatetypesizeinfostruct(value)
% GENERATETYPESIZEINFOSTRUCT constructs a meta structure containing a
% complete (recursive for cells)
% information about type and size of input array
%
% Input: value - array of any type
%
% Output: STypeSizeInfo structure each node of which has the following
%   fields:
%
%   type: char[1,]
%   sizeVec: double[1,]
%   itemTypeInfo: STypeSizeInfo[1,]
%   isCell: logical[1,1]
%
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
%
STypeSizeInfo=mxberry.core.type.generatetypesizeinfostruct(value);