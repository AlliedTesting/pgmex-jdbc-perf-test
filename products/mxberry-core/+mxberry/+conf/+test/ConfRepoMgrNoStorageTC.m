% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef ConfRepoMgrNoStorageTC < mxberry.conf.test.AConfRepoMgrTC
    methods
        function self = ConfRepoMgrNoStorageTC(varargin)
            self=self@mxberry.conf.test.AConfRepoMgrTC(...
                varargin{:});
        end
    end
    properties (MethodSetupParameter)
        factoryParam=struct('inmem',...
            mxberry.conf.test.ConfRepoManagerFactory('inmem'));
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
                paramValue=rand(1);
                self.cm.setParam(paramName,paramValue,'writeDepth','cache');
                self.verifyEqual(true,self.cm.isParam(paramName));
                self.verifyEqual(paramValue,self.cm.getParam(paramName));
                paramValue=rand(1);
                self.cm.setParam(paramName,paramValue,'writeDepth','cache');
                self.verifyEqual(true,self.cm.isParam(paramName));
                self.verifyEqual(paramValue,self.cm.getParam(paramName));
            end
        end
    end
end