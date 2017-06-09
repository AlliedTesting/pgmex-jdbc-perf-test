% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef MUnitRemoteTestRunner<handle
    properties
        emailLogger
        fTempDirGetter
        isConsoleOutputCollected
    end
    methods
        %
        function self=MUnitRemoteTestRunner(emailLogger,fTempDirGetter,...
                varargin)
            import mxberry.core.parseparext;
            self.emailLogger=emailLogger;
            self.fTempDirGetter=fTempDirGetter;
            [~,~,self.isConsoleOutputCollected]=parseparext(varargin,...
                {'isConsoleOutputCollected';...
                true;...
                'islogical(x)&&isscalar(x)'},0);
        end
        %
        function resultVec=runTestPack(self,topPackageName,varargin)
            import mxberry.core.throwerror;
            import mxberry.log.log4j.Log4jConfigurator;
            %
            [testPackArgList,~,isJUnitXMLReportEnabled,jUnitXMLReportDir,...
                isJUnitReportEnabledSpec,isJUnitXMLReportDirSpec]=...
                mxberry.core.parseparext(varargin,...
                {'isJUnitXMLReportEnabled','jUnitXMLReportDir';...
                false,'';...
                'islogical(x)','isstring(x)'});
            if isJUnitReportEnabledSpec&&~isJUnitXMLReportDirSpec
                throwerror('wrongInput',['jUnitXMLReportDir property',...
                    'is obligatory when isJUnitXMLReportEnabled=true']);
            end
            %
            self.emailLogger.sendMessage('STARTED','');
            tmpDirName=self.fTempDirGetter(topPackageName);
            resultVec=[];
            logger=Log4jConfigurator.getLogger();
            isConsoleOutputCollected=self.isConsoleOutputCollected; %#ok<*PROPLC>
            try
                suite=testsuite(topPackageName,'IncludeSubpackages',true);
                runner=matlab.unittest.TestRunner.withNoPlugins;
                %
                if isJUnitXMLReportEnabled
                    if ~mxberry.io.isdir(jUnitXMLReportDir)
                        mxberry.io.mkdir(jUnitXMLReportDir);
                    end
                    %
                    xmlFile = [jUnitXMLReportDir,filesep,'test_results.xml'];
                    p=matlab.unittest.plugins.XMLPlugin.producingJUnitFormat(xmlFile);
                    runner.addPlugin(p);
                end
                %
                fRun=@()runner.run(suite);
                %
                if isConsoleOutputCollected
                    consoleOutStr=evalc(...
                        'resultVec=feval(fRun,testPackArgList{:});');
                else
                    resultVec=feval(fRun,testPackArgList{:});
                end
                %
                errorFailStr=getErrorFailMessage(resultVec);
                errorHyperStr=errorFailStr;
                isFailed=~getIsPassed(resultVec);
                %
                subjectStr=getMinimalReport(resultVec);
                %
                if isConsoleOutputCollected
                    consoleOutFileName=writeMessageToFile('console_output',...
                        consoleOutStr);
                    consoleOutZipFileName=[tmpDirName,filesep,'cosoleOutput.zip'];
                    zip(consoleOutZipFileName,consoleOutFileName);
                    attachFileNameList={consoleOutZipFileName};
                else
                    attachFileNameList={};
                end
                %
            catch meObj
                subjectStr='ERROR';
                errorFailStr=...
                    mxberry.core.MExceptionUtils.me2PlainString(meObj);
                errorHyperStr=...
                    mxberry.core.MExceptionUtils.me2HyperString(meObj);
                attachFileNameList={};
                isFailed=true;
            end
            if isFailed
                errorFailFileName=writeMessageToFile('error_fail_list',...
                    errorFailStr);
                attachFileNameList=[attachFileNameList,{errorFailFileName}];
                logger.error(errorHyperStr);
            end
            %
            self.emailLogger.sendMessage(subjectStr,...
                'emailAttachmentNameList',attachFileNameList);
            %
            function fullFileName=getFullFileName(shortFileName,extName)
                if nargin<2
                    extName='.txt';
                end
                fullFileName=[tmpDirName,filesep,shortFileName,extName];
            end
            function fullFileName=writeMessageToFile(shortFileName,msgStr)
                fullFileName=getFullFileName(shortFileName);
                [fid,errMsg] = fopen(fullFileName, 'w');
                if fid<0
                    throwerror('cantOpenFile',errMsg);
                end
                try
                    fprintf(fid,'%s',msgStr);
                catch meObj
                    fclose(fid);
                    rethrow(meObj);
                end
                fclose(fid);
            end
        end
    end
    %
    methods (Static)
        function resultVec=runTestsWithConf(inpArgList,confRepoMgr,...
                log4jConfiguratorName,emailSubjSuffixName,runnerName,...
                fTempDirGetter,topPackageName,varargin)
            import mxberry.core.throwerror;
            import mxberry.core.struct.strucdisp;
            import mxberry.unittest.MUnitRemoteTestRunner;
            import(log4jConfiguratorName);
            %
            try
                %% Configure Log4j
                confName=confRepoMgr.getCurConfName(); %#ok<NASGU>
                Log4jConfigurator.unlockConfiguration();
                Log4jConfigurator.configure(confRepoMgr);
                Log4jConfigurator.lockConfiguration();
                %% Log configuration
                logger=Log4jConfigurator.getLogger();
                logger.info(sprintf('Test configuration:\n%s',...
                    evalc('strucdisp(confRepoMgr.getConf(confName))')));
                %
                emailLogger=...
                    mxberry.log.EmailLoggerBuilder.fromConfRepoMgr(...
                    confRepoMgr,runnerName,emailSubjSuffixName,....
                    Log4jConfigurator.getMainLogFileName(),fTempDirGetter);
                %
                try
                    testRunner=MUnitRemoteTestRunner(emailLogger,...
                        fTempDirGetter,varargin{:});
                    %
                    isJUnitXMLReportEnabled=confRepoMgr.getParam(...
                        'reporting.JUnitXMLReport.isEnabled');
                    dirNameByTheFollowingFile=confRepoMgr.getParam(...
                        'reporting.JUnitXMLReport.dirNameByTheFollowingFile');
                    dirNameSuffix=confRepoMgr.getParam(...
                        'reporting.JUnitXMLReport.dirNameSuffix');
                    jUnitXMLReportRootDir=fileparts(which(dirNameByTheFollowingFile));
                    %
                    if isempty(jUnitXMLReportRootDir)
                        throwerror('notExistentRefFile',['file %s by which the ',...
                            'directory for JUnit XML reports is build doesn''t exist'],...
                            dirNameByTheFollowingFile);
                    end
                    %
                    jUnitXMLReportDir=[fileparts(which(...
                        dirNameByTheFollowingFile)),filesep,...
                        dirNameSuffix];
                    %
                    inpArgList=[inpArgList,{'isJUnitXMLReportEnabled',...
                        isJUnitXMLReportEnabled,...
                        'jUnitXMLReportDir',jUnitXMLReportDir}];
                    %
                    resultVec=testRunner.runTestPack(topPackageName,...
                        inpArgList{:});
                catch meObj
                    emailLogger.sendMessage('ERROR',...
                        mxberry.core.MExceptionUtils.me2PlainString(meObj));
                    rethrow(meObj);
                end
            catch meObj
                disp(mxberry.core.MExceptionUtils.me2PlainString(meObj));
                rethrow(meObj);
            end
        end
    end
end
function reportStr=getErrorFailMessage(testResVec)
isEmptyVec=arrayfun(@(x)~isfield(x.Details,'DiagnosticRecord')||...
    isfield(x.Details,'DiagnosticRecord')&&...
    isempty(x.Details.DiagnosticRecord),testResVec);
reportStrList=arrayfun(@(x)x.Details.DiagnosticRecord.Report,...
    testResVec(~isEmptyVec),'UniformOutput',false);
reportStr=sprintf('%s\n',reportStrList{:});
end
function isPassed=getIsPassed(testResVec)
isPassed=(sum([testResVec.Failed])+sum([testResVec.Incomplete]))==0;
end
function reportStr=getMinimalReport(testResVec)
nTests=numel(testResVec);
runTime=sum([testResVec.Duration]);
nFails=sum([testResVec.Failed]);
nIncomplete=sum([testResVec.Incomplete]);
%
msgFormatStr='<< %s >> || TESTS: %d';
suffixStr=',  RUN TIME(sec.): %.5g';
%
if (nFails==0)&&(nIncomplete)==0
    prefixStr='PASSED';
    addArgList={};
else
    prefixStr='FAILED';
    msgFormatStr=[msgFormatStr,...
        ',  FAILURES: %d,  INCOMPLETE: %d'];
    addArgList={nFails,nIncomplete};
end
msgFormatStr=[msgFormatStr,suffixStr];
reportStr=sprintf(msgFormatStr,prefixStr,...
    nTests,addArgList{:},runTime);
end