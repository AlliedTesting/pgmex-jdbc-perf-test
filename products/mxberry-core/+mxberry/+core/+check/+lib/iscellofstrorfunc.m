% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
function isPositive=iscellofstrorfunc(inpArray)
isPositive=all(cellfun('isclass',inpArray,'function_handle')|...
    (cellfun('ndims',inpArray)==2&cellfun('size',inpArray,1)==1&...
    cellfun('isclass',inpArray,'char')));