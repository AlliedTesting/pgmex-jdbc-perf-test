% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef GetCallerNameExtTestClassB<handle
    properties (Access=private,Hidden)
        methodName
        className
    end
    %
    methods
        function self=GetCallerNameExtTestClassB(varargin)
            [self.methodName,self.className]=...
                mxberry.core.getcallernameext(1);
        end
        %
        function [methodName,className]=getCallerInfo(self)
            methodName=self.methodName;
            className=self.className;
        end
    end
    %
    methods (Access=protected,Hidden)
        function setCallerInfo(self,methodName,className)
            self.className=className;
            self.methodName=methodName;
        end
    end
end