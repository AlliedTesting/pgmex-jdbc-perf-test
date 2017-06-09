function outArr = roundn(inpArr,indexExp)
% ROUNDN rounds to multiple of 10^indexExp
%
% Input:
%   regular:
%       inpArr: numeric[n1,...,nk] - input real array
%       indexExp: numeric[1,1] - index exponent
% Output:
%   outArr: numeric[n1,...,nk] - array with rounded values
%
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
import mxberry.core.throwerror;
if ~(isscalar(indexExp)&&(fix(indexExp)==indexExp))
    throwerror('wrongInput',...
        'indexExp is expected to be an integer scalar');
end
%
if indexExp < 0
    multVal = 10 ^ -indexExp;
    outArr = round(multVal * inpArr) / multVal;
elseif indexExp > 0
    multVal = 10 ^ indexExp;
    outArr = multVal * round(inpArr / multVal);
else
    outArr = round(inpArr);
end
