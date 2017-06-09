% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef StructChangeTrackerTest<mxberry.core.struct.StructChangeTracker
    properties
    end
    
    methods (Static)
        function SInput=patch_001_alpha2323(SInput)
            SInput.alpha=1;
        end
        function SInput=patch_103_test_tessss23_s(SInput)
            SInput.beta=2;
        end
    end
    methods
        function SInput=patch_002_22test_002_patch_22test(~,SInput)
            SInput.beta=3;
        end
    end
    
end
