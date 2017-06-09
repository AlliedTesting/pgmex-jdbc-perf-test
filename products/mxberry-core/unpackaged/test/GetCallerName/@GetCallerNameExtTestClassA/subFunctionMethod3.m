% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
function obj=subFunctionMethod3(obj)
obj=subFunction(obj);
end

function obj=subFunction(obj)
subFunction2();

    function subFunction2()
        [methodName,className]=mxberry.core.getcallernameext(1);
        obj=setCallerInfo(obj,methodName,className);
    end
end