% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
function isPositive=isequalcellelemsize(value1,value2)
isPositive=false;
nDimVec1=cellfun('ndims',value1);
nDimVec2=cellfun('ndims',value2);
if ~isequal(nDimVec1,nDimVec2)
    return;
end
for iDim=1:max(nDimVec1)
    if ~isequal(cellfun('size',value1,iDim),...
            cellfun('size',value2,iDim))
        return;
    end
end
isPositive=true;