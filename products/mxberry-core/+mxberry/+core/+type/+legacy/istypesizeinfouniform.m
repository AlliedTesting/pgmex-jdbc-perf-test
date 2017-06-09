function [isOk,STypeInfo]=istypesizeinfouniform(STypeSizeInfo)
% ISTYPESIZEINFOUNIFORM check the input STypeSizeInfo structure for
%   uniformity
%
% Input:
%   STypeSizeInfo: struct[1,1]
%
% Output:
%   isOk: logical[1,1] true is the input structure is uniform
%   STypeInfo: struct[1,1] - unified type info structure compiled from
%      the input STypeSizeInfo structure by removing size information and
%      unified the type information across all the elements
%
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%

[isOk,STypeInfo]=mxberry.core.type.istypesizeinfouniform(STypeSizeInfo);



