% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef ConfRepoManagerFactory<handle
    properties
        classType
    end
    methods
        function obj=getInstance(self,varargin)
            import mxberry.conf.test.*;
            switch self.classType
                case 'plainver'
                    confPatchRepo=mxberry.conf.test.StructChangeTrackerTest();
                    obj=ConfigurationRMTest(varargin{:});
                    obj.setConfPatchRepo(confPatchRepo);
                case 'adaptivever'
                    confPatchRepo=mxberry.conf.test.StructChangeTrackerTest();
                    obj=AdaptiveConfRepoManagerTest(varargin{:});
                    obj.setConfPatchRepo(confPatchRepo);
                case 'plain'
                    obj=ConfigurationRMTest(varargin{:});
                case 'adaptive'
                    obj=AdaptiveConfRepoManagerTest(varargin{:});
                case 'versioned'
                    obj=VersionedConfRepoManagerTest(varargin{:});
                case 'inmem'
                    obj=mxberry.conf.ConfRepoMgrInMemory();
                otherwise
                    mxberry.core.throwerror('unknownType',...
                        'unknown class type');
            end
        end
        function self=ConfRepoManagerFactory(classType)
            self.classType=classType;
        end
    end
end