function editconf(confName)
confRepoMgr=mxberry.test.conf.AdaptiveConfRepoManager();
confRepoMgr.deployConfTemplate(confName,'forceUpdate',true);
confRepoMgr.editConf(confName);