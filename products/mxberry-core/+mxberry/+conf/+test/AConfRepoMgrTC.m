% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef AConfRepoMgrTC < matlab.unittest.TestCase
    properties (Access=protected)
        cm
        SDefaultEthalon=struct('firstProp','alpha','secondProp','beta');
        factory
    end
    methods (Access=protected)
        function self=initData(self)
            import mxberry.conf.test.*;
            self.cm=self.factory.getInstance();
            self.cm.removeAll();
            SConfA=genteststruct(1);
            SConfB=genteststruct(2);
            metaA=struct('a','1','b','2');
            metaB=struct('a','11','b','22');
            %
            self.cm.putConf('testConfA',SConfA,100,metaA);
            self.cm.putConf('testConfB',SConfB,200,metaB);
        end
    end
    methods
        function self = AConfRepoMgrTC(varargin)
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
    methods (Test)
        function self = test_setGetConf(self)
            import mxberry.conf.test.*;
            SConf=genteststruct(3);
            metaData=struct('a','111','b','222');
            self.cm.putConf('testConfA',SConf,3,metaData);
            [SRes,confVersion,metaDataRes]=self.cm.getConf('testConfA');
            self.verifyEqual(isequaln(SConf,SRes),true);
            metaData.version='3';
            self.verifyEqual(isequaln(metaData,metaDataRes),true);
            self.verifyEqual(isequaln(3,confVersion),true);
        end
        function self = test_copyConfAndgetConfList(self)
            import mxberry.conf.test.*;
            SConf=genteststruct(3);
            self.cm.putConf('testConfA',SConf);
            self.cm.copyConf('testConfA','testConfAA');
            SRes=self.cm.getConf('testConfAA');
            self.verifyEqual(isequaln(SConf,SRes),true);
            self.cm.removeConf('testConfB');
            confNameList=self.cm.getConfNameList();
            isEqual=isequal(sort({'testConfA','testConfAA'}),...
                sort(confNameList));
            self.verifyEqual(isEqual,true);
        end
        function self = test_isParam(self)
            import mxberry.conf.test.*;
            SConf=genteststruct(3);
            self.cm.putConf('testConfA',SConf);
            self.cm.selectConf('testConfA');
            isPos=self.cm.isParam('dConf.gen.cdefs.gen.instTypeCode');
            self.verifyEqual(isPos,true);
            isPos=self.cm.isParam('dConf.gen.cdefs.gen.instTypeCode__');
            self.verifyEqual(isPos,false);
            isPos=self.cm.isParam('.dConf.gen.cdefs.gen.instTypeCode');
            self.verifyEqual(isPos,true);
            
        end
        function self = test_setGetParamWithDot(self)
            import mxberry.conf.test.*;
            %
            paramNameList={'.dConf.backtest.calc.pairForecast.meanDec.nLags',...
                'dConf.backtest.calc.pairForecast.meanDec.nLags'};
            for iParam=1:length(paramNameList)
                self=self.initData();
                paramName=paramNameList{iParam};
                self.cm.selectConf('testConfA');
                paramVal=self.cm.getParam(paramName);
                paramVal=paramVal+3;
                self.cm.setParam(paramName,paramVal);
                paramVal2=self.cm.getParam(paramName);
                self.verifyEqual(isequaln(paramVal,paramVal2),true);
                self.cm.selectConf('testConfB');
                self.cm.setParam(paramName,Inf);
                paramVal3=self.cm.getParam(paramName);
                self.verifyEqual(isequaln(Inf,paramVal3),true);
                self.cm.selectConf('testConfA');
                paramVal5=self.cm.getParam(paramName);
                self.verifyEqual(isequaln(paramVal,paramVal5),true);
            end
        end
        function self = test_setGetParamNegative(self)
            import mxberry.conf.test.*;
            %
            self=self.initData();
            paramName='.dConf.backtest.calc.pairForecast.meanDec.nLags123';
            self.cm.selectConf('testConfA');
            try
                self.cm.getParam(paramName);
                self.verifyEqual(true,false);
            catch meObj
                isOk=~isempty(strfind(meObj.identifier,...
                    'CONFREPOMANAGERANYSTORAGE:GETPARAM:invalidParam'));
                self.verifyEqual(isOk,true);
            end
        end
        function self = test_setParamInCache(self)
            import mxberry.conf.test.*;
            %
            paramNameList={'.dConf.backtest.calc.pairForecast.meanDec.nLags',...
                'dConf.backtest.calc.pairForecast.meanDec.nLags'};
            for iParam=1:length(paramNameList)
                self=self.initData();
                paramName=paramNameList{iParam};
                self.cm.selectConf('testConfA');
                origParamValue=self.cm.getParam(paramName);
                paramValue=rand(1);
                self.cm.setParam(paramName,paramValue,'writeDepth','cache');
                self.verifyEqual(true,self.cm.isParam(paramName));
                self.verifyEqual(paramValue,self.cm.getParam(paramName));
                self.cm.flushCache();
                self.cm.selectConf('testConfA');
                self.verifyEqual(true,self.cm.isParam(paramName));
                self.verifyEqual(origParamValue,self.cm.getParam(paramName));
                paramName=[paramName,'_2']; %#ok<AGROW>
                paramValue=rand(1);
                self.cm.setParam(paramName,paramValue,'writeDepth','cache');
                self.verifyEqual(true,self.cm.isParam(paramName));
                self.verifyEqual(paramValue,self.cm.getParam(paramName));
                self.cm.flushCache();
                self.cm.selectConf('testConfA');
                self.verifyEqual(false,self.cm.isParam(paramName));
            end
        end
    end
end