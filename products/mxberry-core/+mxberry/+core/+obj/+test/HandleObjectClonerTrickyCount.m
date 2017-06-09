% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef HandleObjectClonerTrickyCount<mxberry.core.obj.test.HandleObjectCloner
    properties
        beta
    end
    %
    methods
        function self=HandleObjectClonerTrickyCount(varargin)
            self=self@mxberry.core.obj.test.HandleObjectCloner(varargin{:});
        end
    end
    methods  (Access=protected)
        function [isOk,reportStr,signOfDiff]=isEqualScalarInternal(self,...
                otherObj,varargin)
            %
            reportStr='';
            if nargout>2
                signOfDiff=nan;
            end
            isOk=isequal(self.alpha,otherObj.alpha);
            if ~isOk
                reportStr='alpha is different';
            end
            mxberry.core.test.aux.EqualCallCounter.incEqCounter(0.001);
        end
    end
end