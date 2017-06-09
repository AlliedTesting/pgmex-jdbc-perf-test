function outArr=cell2mat(inpCArr)
% CELL2MAT does the same as the built-in cell2mat function but
%  a) 20% faster
%  b) works with cell arrays of objects and even values of different types,
%   the only limitation is ability of the built-in `cat` function to
%   concatenate values from inpCArr to process them.
%
%
% Input:
%   regular:
%       inpCArr: cell[] - input cell arrat of arbitrary type
% Output:
%   outArr: any[] - exactly the same array the built-in `cell2mat` function
%       would provide
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
nElems=numel(inpCArr);
if nElems == 0
    outArr=[];
elseif nElems == 1
    outArr=inpCArr{1};
elseif ismatrix(inpCArr)
    nRows=size(inpCArr,1);
    nCols=size(inpCArr,2);
    if (nRows < nCols)
        outArr=cell(nRows,1);
        for iCol=1:nRows
            outArr{iCol}=cat(2,inpCArr{iCol,:});
        end
        outArr=cat(1,outArr{:});
    else
        outArr=cell(1, nCols);
        for iCol=1:nCols
            outArr{iCol}=cat(1,inpCArr{:,iCol});
        end
        outArr=cat(2,outArr{:});
    end
else
    sizeVec=size(inpCArr);
    nDims=numel(sizeVec);
    for iDim=(nDims-1):-1:1
        tmpCArr=cell([sizeVec(1:iDim) 1]);
        tmpSizeVec=size(tmpCArr);
        nTmpDims=numel(tmpSizeVec);
        nTmpElems=prod(tmpSizeVec);
        indColVecList=cell(1,nTmpDims);
        [indColVecList{1:nTmpDims}]=ind2sub(tmpSizeVec,(1:nTmpElems).');
        if nTmpDims==2 && tmpSizeVec(2)==1
            indColVecList=indColVecList(1);
            nTmpDims=1;
        end
        indRowVecList=mat2cell(num2cell([indColVecList{:}]),...
            ones(1,nTmpElems),nTmpDims);
        for iTmpElem=1:nTmpElems
            indCurVecList=indRowVecList{iTmpElem};
            tmpCArr{indCurVecList{:}}=cat(iDim+1,...
                inpCArr{indCurVecList{:},:});
        end
        inpCArr=tmpCArr;
    end
    outArr=cat(1,inpCArr{:});
end