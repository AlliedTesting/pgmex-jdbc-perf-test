% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef ConfRepoAdaptiveTC < mxberry.conf.test.AConfRepoAdaptiveTC
    properties (MethodSetupParameter)
        factoryParam=struct('adaptive',...
            mxberry.conf.test.ConfRepoManagerFactory('adaptive'));
    end
end
