% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
function isOk=iscelllogical(value)
if iscell(value)
    if isempty(value)
        isOk=false;
    else
        isOk=all(reshape(cellfun('islogical',value),[],1));
    end
else
    isOk=false;
end