% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef ConfRepoMgrVersionedAdaptiveTC < mxberry.conf.test.AConfRepoAdaptiveTC
    properties (Access=private)
        cm1
        tcm1
        cm2
    end
    methods
        function self = ConfRepoMgrVersionedAdaptiveTC(varargin)
            self = self@mxberry.conf.test.AConfRepoAdaptiveTC(varargin{:});
        end
    end
    properties (MethodSetupParameter)
        factoryParam=struct('versioned',...
            mxberry.conf.test.ConfRepoManagerFactory('versioned'));
    end
    methods (TestMethodSetup)
        function self = setUp(self,factoryParam)
            self=setUp@mxberry.conf.test.AConfRepoAdaptiveTC(self,factoryParam);
            SConfC=struct('alpha',0,'beta',0);
            self.cm1=self.factory.getInstance('repoSubFolderName','confRepoVersioned');
            self.cm1.removeAll();
            self.tcm1=self.cm1.getTemplateRepo();
            self.tcm1.putConf('testConfC',struct());
            self.tcm1.removeAll();
            %
            self.tcm1.putConf('testConfC',SConfC,0);
            self.tcm1.putConf('testConfCK',SConfC,0);
            self.cm1.putConf('testConfK',SConfC,0);
            self.cm1.putConf('testConfCK',SConfC,0);
            %
            self.cm2=self.factory.getInstance('repoSubFolderName','confRepoFixedExamples');
        end
    end
    methods
        function self=aux_test_updateConf(self,confName)
            [SConf,confVersion]=self.cm1.getConf(confName);
            self.verifyEqual(103,confVersion);
            self.verifyEqual(2,SConf.beta);
        end
    end
    methods (Test)
        function self=test_updateConfFromTemplate(self)
            self.aux_test_updateConf('testConfC');
        end
        function self=test_updateConfLocally(self)
            self.cm1.updateConf('testConfK');
            self.aux_test_updateConf('testConfK');
        end
        function self=test_updateConfOnSelect(self)
            self.cm1.selectConf('testConfK');
            self.aux_test_updateConf('testConfK');
            self.cm1.selectConf('testConfC');
            self.aux_test_updateConf('testConfC');
        end
        function self=test_updateAll(self)
            self.cm1.updateAll();
            self.aux_test_updateConf('testConfK');
            self.aux_test_updateConf('testConfC');
            self.aux_test_updateConf('testConfCK');
        end
        function self=test_updateAll_wrongKey(self)
            try
                self.cm2.updateAll();
                self.verifyEqual(false,true);
            catch meObj
                self.verifyEqual(false,...
                    isempty(strfind(meObj.identifier,':badConfRepo')));
            end
        end
    end
end