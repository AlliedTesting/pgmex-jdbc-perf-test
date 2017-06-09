% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
function subFunctionMethod3(self)
subFunction(self);
end

function subFunction(self)
subFunction2();

    function subFunction2()
        [methodName,className]=mxberry.core.getcallernameext(1);
        self.setCallerInfo(methodName,className);
    end
end