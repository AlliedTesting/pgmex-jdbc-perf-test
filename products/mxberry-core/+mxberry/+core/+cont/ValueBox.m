% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef ValueBox<handle
    properties
        val
    end
    %
    methods
        function setValue(self,val)
            self.val=val;
        end
        function val=getValue(self)
            val=self.val;
        end
    end
end
