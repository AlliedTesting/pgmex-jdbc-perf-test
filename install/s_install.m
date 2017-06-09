installDir=fileparts(which(mfilename));
if installDir(end)==filesep
    installDir=installDir(1:end-1);
end
%
indSep=find(installDir==filesep,1,'last');
tmpRepoPath=installDir(1:indSep-1);
%add mxberry package to Matlab path
addpath([tmpRepoPath,filesep,'products',filesep,'mxberry-core']);
deployMgr=mxberry.selfmnt.deploy.DeploymentMgr();
deployMgr.deploy(installDir);
%
warning('off','MATLAB:lang:cannotClearExecutingFunction');
clear classes; %#ok<CLCLS>