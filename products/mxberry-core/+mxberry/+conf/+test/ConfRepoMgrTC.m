% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef ConfRepoMgrTC < mxberry.conf.test.AConfRepoMgrTC
    properties (MethodSetupParameter)
        factoryParam=struct('plain',...
            mxberry.conf.test.ConfRepoManagerFactory('plain'));
    end
end