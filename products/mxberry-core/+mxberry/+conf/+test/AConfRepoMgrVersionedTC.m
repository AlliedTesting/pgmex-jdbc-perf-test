% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef AConfRepoMgrVersionedTC < matlab.unittest.TestCase
    properties (Access=protected)
        cm
        SDefaultEthalon=struct('firstProp','alpha','secondProp','beta');
        factory
    end
    methods (Access=private)
        function self=initData(self)
            import mxberry.conf.test.*;
            
            self.cm=self.factory.getInstance();
            self.cm.removeAll();
            SConfA=struct('confName','testConfA','alpha',0,'beta',0);
            SConfB=struct('confName','testConfB','alpha',11,'beta',11);
            %
            self.cm.putConf('testConfA',SConfA,0);
            self.cm.putConf('testConfB',SConfB,0);
        end
    end
    methods
        function self = AConfRepoMgrVersionedTC(varargin)
            self = self@matlab.unittest.TestCase(varargin{:});
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
    methods
        function aux_checkUpdate(self,cm)
            [SConfB,confVersionB]=cm.getConf('testConfB');
            [SConfA,confVersionA]=cm.getConf('testConfA');
            self.verifyEqual(2,SConfA.beta);
            self.verifyEqual(103,confVersionA);
            self.verifyEqual('testConfA',SConfA.confName);
            self.verifyEqual(11,SConfB.beta);
            self.verifyEqual(0,confVersionB);
            self.verifyEqual('testConfB',SConfB.confName);
        end
        function aux_checkUpdateAll(self,cm,isOkExp)
            if nargin<3
                isOkExp=true;
            end
            [SConfA,confVersionA]=cm.getConf('testConfA');
            [SConfB,confVersionB]=cm.getConf('testConfB');
            self.verifyEqual(isOkExp,isequal(2,SConfA.beta));
            self.verifyEqual(isOkExp,isequal(103,confVersionA));
            self.verifyEqual(true,...
                isequal('testConfA',SConfA.confName));
            self.verifyEqual(isOkExp,...
                isequal(2,SConfB.beta));
            self.verifyEqual(isOkExp,...
                isequal(103,confVersionB));
            self.verifyEqual(true,...
                isequal('testConfB',SConfB.confName));
        end
    end
    methods (Test)
        function self=test_update(self)
            self.cm.updateConf('testConfA');
            self.aux_checkUpdate(self.cm);
        end
        function self=test_updateAll(self)
            self.cm.updateAll();
            self.aux_checkUpdateAll(self.cm);
        end
    end
end
