% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef GetCallerNameExtTestClassC<getcallernameexttest.GetCallerNameExtTestClassB
    methods
        function self=GetCallerNameExtTestClassC(isParent,varargin)
            if nargin==0
                isParent=true;
            end
            self=self@getcallernameexttest.GetCallerNameExtTestClassB(varargin{:});
            if ~isParent
                [methodName,className]=mxberry.core.getcallernameext(1);
                self.setCallerInfo(methodName,className);
            end
        end
        
        function simpleMethod(self)
            [methodName,className]=mxberry.core.getcallernameext(1);
            self.setCallerInfo(methodName,className);
        end
        
        function subFunctionMethod(self)
            subFunction();
            
            function subFunction()
                [methodName,className]=mxberry.core.getcallernameext(1);
                self.setCallerInfo(methodName,className);
            end
        end
        
        function subFunctionMethod3(self)
            subFunction();
            
            function subFunction()
                subFunction2();
                
                function subFunction2()
                    [methodName,className]=mxberry.core.getcallernameext(1);
                    self.setCallerInfo(methodName,className);
                end
            end
        end
    end
end