% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef AConfRepoAdaptiveTC < mxberry.conf.test.AConfRepoMgrTC
    properties (Access=protected)
        tcm
        initialConfNameList
    end
    methods (Access=protected)
        function self=initData(self)
            import mxberry.conf.test.*;
            
            self.cm=self.factory.getInstance();
            self.cm.removeAll();
            self.tcm=self.cm.getTemplateRepo();
            self.tcm.putConf('testConfC',struct());
            self.tcm.removeAll();
            SConfA=genteststruct(1);
            SConfB=genteststruct(2);
            %
            self.tcm.putConf('testConfA',SConfA);
            self.tcm.putConf('testConfB',SConfB);
            self.cm.putConf('testConfA',SConfB);
            self.initialConfNameList=self.tcm.getConfNameList();
        end
    end
    methods
        function self = AConfRepoAdaptiveTC(varargin)
            self = self@mxberry.conf.test.AConfRepoMgrTC(varargin{:});
        end
    end
    properties (MethodSetupParameter, Abstract)
        factoryParam
    end
    methods (TestMethodSetup)
        function self = setUp(self,factoryParam)
            self.factory=factoryParam;
            self=self.initData();
        end
    end
    methods (Test)
        function self = test_setGetConf(self)
            import mxberry.conf.test.*;
            SConf=genteststruct(3);
            self.tcm.putConf('testConfB',SConf);
            SRes=self.cm.getConf('testConfB');
            self.verifyEqual(isequaln(SConf,SRes),true);
        end
        function self = test_setGetConfWithVer(self)
            import mxberry.conf.test.*;
            SConf=genteststruct(3);
            [~,lastRev]=self.tcm.getConf('testConfA');
            testVer=min(333,lastRev);
            self.tcm.putConf('testConfB',SConf,testVer);
            [SRes,resVer]=self.cm.getConf('testConfB');
            self.verifyEqual(isequaln(SConf,SRes),true);
            self.verifyEqual(testVer,resVer);
        end
        function self=test_deployConfTemplate(self)
            confNameList=[self.tcm.getConfNameList,{'testConfD'}];
            self.tcm.copyConf('testConfA','testConfD');
            self.cm.deployConfTemplate('*');
            isEqual=isequal(confNameList,...
                sort(self.cm.getConfNameList()));
            self.verifyEqual(isEqual,true);
        end
    end
end
