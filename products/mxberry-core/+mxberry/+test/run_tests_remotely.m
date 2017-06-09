function resultVec=run_tests_remotely(markerStr,confName)
import mxberry.test.log.Log4jConfigurator;
%
if nargin<1
    markerStr='';
else
    markerStr=[',',markerStr];
end
if nargin<2
    confName='default';
end
RUNNER_NAME='MatrixBerryTestRunner';
TOP_PACKAGE_NAME='mxberry';
%
runnerName=[RUNNER_NAME,markerStr];
log4jConfiguratorName='mxberry.test.log.Log4jConfigurator';
fTempDirGetter=@mxberry.test.TmpDataManager.getDirByCallerKey;
emailSubjSuffName='';
try
    %% Read test configuration
    confRepoMgr=mxberry.test.conf.AdaptiveConfRepoManager();
    confRepoMgr.selectConf(confName);
    inpArgList={};
    resultVec=mxberry.unittest.MUnitRemoteTestRunner.runTestsWithConf(...
        inpArgList,confRepoMgr,...
        log4jConfiguratorName,emailSubjSuffName,runnerName,...
        fTempDirGetter,TOP_PACKAGE_NAME,'isConsoleOutputCollected',false);
catch meObj
    disp(mxberry.core.MExceptionUtils.me2PlainString(meObj));
    rethrow(meObj);
end
