% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
function obj=simpleMethod(obj)
[methodName,className]=mxberry.core.getcallernameext(1);
obj=setCallerInfo(obj,methodName,className);