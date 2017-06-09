function isValid=checksize(varargin)
% CHECKSIZE checks sizes of arrays;
%
% Usage isValid=checksize(arr1,arr2,arr3,siz);
%
% Input:
%   regular:
%       firstArr: any[]
%       ......
%       lastArr: any[]
%       sizeVec: double[1,nDims] - mask for check of size;
%
% Output:
%   isValid: logical[1,1] - true if all arrays is proper with
%       mask
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
isValidVec=mxberry.core.isvalidsize(varargin{:});
isValid=all(isValidVec);