function varargout=unique(inpVec)
% UNIQUE for arrays of any type
%
% Usage: [outUnqVec,indRightToLeftVec,indLeftToRightVec]=...
%   mxberry.core.unique(inpVec);
%
% Input:
%   regular:
%     inpVec: cell[nObjects,1]/[1,nObjects] of objects
%
% Output:
%   outUnqVec: cell[nUniqObjects,1]/[1,nUniqObjects]
%   indRightToLeftVec: double[nUniqObjects,1] : all
%       fCompare(inpVec(indRightToLeftVec)==outUnqVec)==true
%   indLeftToRightVec: double[nObjects,1] : all
%       all(fCompare(outUnqVec(indLeftToRightVec)==inpVec))
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
import mxberry.core.uniquejoint;
import mxberry.core.uniquebyfunc;
if nargout==0
    uniquejoint({inpVec});
else
    varargout=cell(1,nargout);
    [varargout{:}]=uniquejoint({inpVec});
    varargout{1}=varargout{1}{1};
end