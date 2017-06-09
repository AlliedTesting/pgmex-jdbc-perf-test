% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
function outArray=cat(dimNum,varargin)
if nargin>=2
    className=class(varargin{1});
    isEmptyVec=cellfun(@(x)max(size(x)),varargin)==0;
    if all(isEmptyVec)
        outArray=mxberry.core.type.createarray(className,[0 0]);
    else
        outArray=cat(dimNum,varargin{~isEmptyVec});
    end
else
    outArray=cat(dimNum);
end