function outCVec = catcellstrwithsep(inpCMat,sepStr)
% CATCELLSTRWITHSEP contatenates columns of input cell matrix of strings
% using a specified separator and returns result as a column cell vector of
% strings
%
% Input:
%   regular:
%       inpCMat: cell[nRows,nCols] of char[1,] - cell matrix of strings
%       sepStr: char[1,] - separator
%
% Output:
%   outCVec: cell[nRows,1] of char[1,] - cell vector of strings
%
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
%
import mxberry.core.string.catwithsep;
nRows=size(inpCMat,1);
nCols=size(inpCMat,2);
outCVec=cellfun(@(x)catwithsep(x,sepStr),...
    mat2cell(inpCMat,ones(nRows,1),nCols),'UniformOutput',false);
