% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef StructChangeTrackerAdv<mxberry.core.struct.StructChangeTracker
    properties
    end
    
    methods (Static)
        function SInput=patch_001_alpha(SInput)
            SInput.alpha1=strcat(SInput.alpha1,'1');
            SInput.alpha5=SInput.alpha5*10;
            SInput.alpha3=1;
        end
        function SInput=patch_103_test(SInput)
            SInput.alpha1=strcat(SInput.alpha1,'103');
            SInput.alpha5=SInput.alpha5*10;
            SInput.alpha3=103;
        end
    end
    methods
        function SInput=patch_002_test(~,SInput)
            SInput.alpha1=strcat(SInput.alpha1,'2');
            SInput.alpha5=SInput.alpha5*10;
            SInput.alpha3=2;
        end
    end
    
end
