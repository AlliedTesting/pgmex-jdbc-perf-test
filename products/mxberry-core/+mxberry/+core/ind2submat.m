function indMat = ind2submat(sizeVec,indVec)
% IND2SUBMAT works similarly to the built-in ind2sub function but returns
% all the indices in a single matrix
%
% Input:
%   regular:
%       sizeVec: numeric[1,nDims]
%       indVec: numeric[nIndices,1]/numeric[1,nIndices]
%
% Output:
%   indMat: double[nIndices,nDims] - matrix of subindices, each column
%       corresponds to a separate output of the built-in ind2sub function
%
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
%
nout = length(sizeVec);
sizeVec = double(sizeVec);
sizeVec = [sizeVec ones(1,nout-length(sizeVec))];
%
n = length(sizeVec);
k = [1 cumprod(sizeVec(1:end-1))];
for i = n:-1:1
    vi = rem(indVec-1, k(i)) + 1;
    vj = (indVec - vi)/k(i) + 1;
    indMat(:,i) = vj;
    indVec = vi;
end