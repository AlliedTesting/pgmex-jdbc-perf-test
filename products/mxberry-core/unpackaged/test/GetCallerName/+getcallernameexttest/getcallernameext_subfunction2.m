% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
function [methodName,callerName]=getcallernameext_subfunction2()
[methodName,callerName]=subfunction();
end

function [methodName,callerName]=subfunction()
[methodName,callerName]=mxberry.core.getcallernameext(1);
end