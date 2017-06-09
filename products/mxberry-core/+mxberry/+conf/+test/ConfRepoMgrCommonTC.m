% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef ConfRepoMgrCommonTC < matlab.unittest.TestCase
    properties (Access=protected)
        cm
        SDefaultEthalon=struct('firstProp','alpha','secondProp','beta');
        factory
    end
    %
    methods (Access=private)
        function self=initData(self)
            import mxberry.conf.test.*;
            %
            self.cm=self.factory.getInstance();
            SConfA=struct('confName','testConfA','alpha',0,'beta',0);
            SConfB=struct('confName','testConfB','alpha',11,'beta',11);
            %
            self.cm.putConf('testConfA',SConfA,0);
            self.cm.putConf('testConfB',SConfB,0);
        end
    end
    %
    methods
        function self = ConfRepoMgrCommonTC(varargin)
            self = self@matlab.unittest.TestCase(varargin{:});
        end
    end
    %
    properties (MethodSetupParameter)
        factoryParam=struct('plain',...
            mxberry.conf.test.ConfRepoManagerFactory('plain'),...
            'plainver',...
            mxberry.conf.test.ConfRepoManagerFactory('plainver'),...
            'adaptivever',...
            mxberry.conf.test.ConfRepoManagerFactory('adaptivever'),...
            'adaptive',...
            mxberry.conf.test.ConfRepoManagerFactory('adaptive'),...
            'versioned',...
            mxberry.conf.test.ConfRepoManagerFactory('versioned'));
    end
    %
    methods (TestMethodSetup)
        function self = setUp(self,factoryParam)
            self.factory=factoryParam;
            self=self.initData();
        end
    end
    %
    methods (Test)
        function self = test_setParamAfterSelect(self)
            import mxberry.conf.test.*;
            cm=self.cm; %#ok<*PROP>
            cm.selectConf('testConfA');
            valOrig=cm.getParam('alpha');
            val=valOrig+1;
            cm.setParam('alpha',val,'writeDepth','cache');
            cm.selectConf('testConfA','reloadIfSelected',false);
            self.verifyEqual(val,cm.getParam('alpha'));
            cm.selectConf('testConfA','reloadIfSelected',true);
            self.verifyEqual(valOrig,cm.getParam('alpha'));
            %
        end
        function testCacheConf(self)
            CONF_NAME_LIST={'tstA','tstB','tstC'};
            cm=self.cm;
            SConfA=struct('confName','tstA','alpha',0,'beta',0);
            SConfB=struct('confName','tstB','alpha',2,'beta',2);
            SMeta.version='3';
            %
            cm.putConfToCache('tstA',SConfA,SMeta);
            checkIfCached([true,false,false]);
            checkIfSelected([false,false,false]);
            cm.putConfToCacheAndSelect('tstB',SConfB,SMeta);
            checkIfCached([true,true,false]);
            checkIfSelected([false,true,false]);
            cm.putConfToStorage('tstC',SConfB,SMeta);
            checkIfCached([true,true,false]);
            checkIfSelected([false,true,false]);
            %
            function checkIfCached(isExpCachedVec)
                isCachedVec=cellfun(@(x)cm.isCachedConf(x),CONF_NAME_LIST);
                self.verifyEqual(isExpCachedVec,isCachedVec);
            end
            function checkIfSelected(isExpSelectedVec)
                isSelectedVec=cellfun(@(x)cm.isConfSelected(x),CONF_NAME_LIST);
                self.verifyEqual(isExpSelectedVec,isSelectedVec);
            end
        end
    end
end