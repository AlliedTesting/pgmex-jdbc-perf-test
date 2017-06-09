function resStr = cellstr2expression(inpCMat,isMatrixStyle,isQuotingSkipped)
% CELLSTR2EXPRESSION creates Matlab expression based on cell matrix of
%   expressions corresponding to the individual elements of the matrix
%
% Input:
%   regular:
%       inpCMat: cell[nRows,nCols] of char[1,] - input matrix of
%           expression
%       isMatrixStyle: logical[1,1] - if false (default) the
%           curcly (cell style braces are used) and each cell is surrounded
%           by quotes (unless isQuotingSkipped=true). If true square braces
%           (matrix style) are used and no quotes are used.
%
%   optional:
%       isQuotingSkipped: logical[1,1] - if true, no quotes are used even
%       for isMatrixStyle=false
%   
% Output:
%   resStr: char[1,] - resulting expression for the matrix
%
%
% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
%
if nargin<3
    isQuotingSkipped=false;
end
%
if ~ismatrix(inpCMat)
    origSizeVec=size(inpCMat);
    isReshaped=true;
    inpCMat=reshape(inpCMat,origSizeVec(1),[]);
else
    isReshaped=false;
end
%
if nargin<2
    isMatrixStyle=false;
end
%
if ~(isMatrixStyle||isQuotingSkipped)
    inpCMat=cellfun(@(x)sprintf('''%s''',strrep(x,'''','''''')),...
        inpCMat,'UniformOutput',false);
end
lineList=strcat(mxberry.core.string.catcellstrwithsep(inpCMat,','),';');
resStr=[lineList{:}];
if isMatrixStyle
    resStr=['[',resStr(1:end-1),']'];
else
    resStr=['{',resStr(1:end-1),'}'];
end
if isReshaped
    resStr=['reshape(',resStr,',',mat2str(origSizeVec),')'];
end