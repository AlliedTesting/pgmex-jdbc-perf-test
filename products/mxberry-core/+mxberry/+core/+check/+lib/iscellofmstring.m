% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
function isPositive=iscellofmstring(inpArray)
isPositive=iscellstr(inpArray)&&...
    all(reshape(cellfun(@(x)(isequal(x,'')||...
    mxberry.core.isrow(x)),inpArray),[],1));