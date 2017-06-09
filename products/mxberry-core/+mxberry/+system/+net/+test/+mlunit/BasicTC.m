% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef BasicTC<mxberry.unittest.TestCase
    methods (Test)
        function testGetNetworkInterface(~)
            import mxberry.core.combvec;
            isPropValTrueMat=combvec([true,false],[true,false],...
                [true,false],[true,false]).';
            %
            nCombs=size(isPropValTrueMat,1);
            for iComb=1:nCombs
                isPropTrueVec=isPropValTrueMat(iComb,:);
                [~]=mxberry.system.net.getnetinterface(...
                    'IPv4Only',isPropTrueVec(1),...
                    'noLoopback',isPropTrueVec(2),...
                    'mustHaveAddress',isPropTrueVec(3),...
                    'mustHaveHwAddress',isPropTrueVec(4));
            end
        end
    end
end

