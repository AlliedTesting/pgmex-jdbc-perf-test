function editconf(confName)
confRepoMgr=com.allied.pgmex.perftest.configuration.AdaptiveConfRepoManager();
confRepoMgr.deployConfTemplate(confName,'forceUpdate',true);
confRepoMgr.editConf(confName);