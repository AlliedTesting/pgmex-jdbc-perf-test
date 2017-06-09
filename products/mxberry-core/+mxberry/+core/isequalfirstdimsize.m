function isPositive=isequalfirstdimsize(firstArr,secArr,nDims)
% ISEQUALFIRSTDIMSIZE checks if the specified arrays have the same size
%   along the first N dimensions where N is specified
%
% Input:
%   regular:
%       firstArr: any[] - first array of any type
%       secArr: any[] - second array of any type
%       nDims: double[1,1] - number of dimensions
%
% Output:
% 	isPositive: logical[1,1] - true if the check is successfull
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
import mxberry.core.getfirstdimsize;
import mxberry.core.throwerror;
if ~isnumeric(nDims)||numel(nDims)~=1||fix(nDims)~=nDims||nDims<=0
    throwerror('wrongInput',...
        'nDims is expected to be a scalar positive integer value');
end
%
isPositive=isequal(getfirstdimsize(firstArr,nDims),...
    getfirstdimsize(secArr,nDims));