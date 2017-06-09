% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef SortableEntityRedirected<...
        mxberry.core.test.aux.CompareRedirectAppliance&...
        mxberry.core.test.aux.SortableEntity
    methods
        function self=SortableEntityRedirected(varargin)
            self=self@mxberry.core.test.aux.SortableEntity(varargin{:});
        end
    end
end