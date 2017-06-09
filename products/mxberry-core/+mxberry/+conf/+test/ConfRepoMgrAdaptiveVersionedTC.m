% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef ConfRepoMgrAdaptiveVersionedTC < ...
        mxberry.conf.test.AConfRepoMgrVersionedTC
    properties (Access=protected)
        tcm
    end
    methods (Access=private)
        function self=initData(self)
            import mxberry.conf.test.*;
            self.cm=self.factory.getInstance();
            self.cm.removeAll();
            clearStorageContent(self.cm);
            %
            self.tcm=self.cm.getTemplateRepo();
            self.tcm.removeAll();
            clearStorageContent(self.tcm);
            %
            self.cm=self.factory.getInstance();
            self.tcm=self.cm.getTemplateRepo();
            %
            SConfA=struct('confName','testConfA','alpha',0,'beta',0);
            SConfB=struct('confName','testConfB','alpha',11,'beta',11);
            %
            self.tcm.putConf('testConfA',SConfA,0);
            self.tcm.putConf('testConfB',SConfB,0);
            function clearStorageContent(cm)
                import mxberry.core.throwerror;
                storageRoot=cm.getStorageLocationRoot();
                if mxberry.io.isdir(storageRoot)
                    [indOk,msgStr]=mxberry.io.rmdir(...
                        cm.getStorageLocationRoot(),'s');
                    if indOk~=1
                        throwerror('wrongStatus',...
                            'deletion of directory %s has failed :%s',...
                            storageRoot,msgStr);
                    end
                    mxberry.io.mkdir(storageRoot);
                end
            end
        end
    end
    methods
        function self = ConfRepoMgrAdaptiveVersionedTC(varargin)
            self = self@mxberry.conf.test.AConfRepoMgrVersionedTC(varargin{:});
        end
    end
    properties (MethodSetupParameter)
        factoryParam=struct('adaptivever',...
            mxberry.conf.test.ConfRepoManagerFactory('adaptivever'));
    end
    methods (TestMethodSetup)
        function self = setUp(self,factoryParam)
            self.factory=factoryParam;
            self=self.initData();
        end
    end
    methods (Test)
        function self=test_updateAll(self)
            self.cm.updateAll();
            self.aux_checkUpdateAll(self.cm);
            self.aux_checkUpdateAll(self.tcm);
            %
        end
        function testUpdateAllBranches(self)
            curBranchKey=self.cm.getStorageBranchKey();
            isOk=isequal({curBranchKey},self.cm.getBranchKeyList());
            self.verifyTrue(isOk);
            otherBranchKey=[curBranchKey,'_2'];
            templateBranchKey=self.cm.getTemplateBranchKey();
            storageRootDir=self.cm.getStorageLocationRoot();
            [isSuccess,msgStr]=copyfile([storageRootDir,filesep,...
                templateBranchKey],...
                [storageRootDir,filesep,otherBranchKey]);
            [isSuccess,msgStr]=copyfile([storageRootDir,filesep,...
                templateBranchKey],...
                [storageRootDir,filesep,curBranchKey]);
            %
            check({curBranchKey,otherBranchKey});
            check({curBranchKey,otherBranchKey},false);
            %
            check({templateBranchKey,curBranchKey,otherBranchKey},true);
            %
            branchKeyList={templateBranchKey,curBranchKey,otherBranchKey};
            nBranches=numel(branchKeyList);
            %
            self.cm.updateAll();
            checkMaster([true,true,false]);
            self.cm.updateAll(true);
            checkMaster([true,true,true]);
            %
            function checkMaster(isOkExpVec)
                for iBranch=1:nBranches
                    curBranchKey=branchKeyList{iBranch};
                    cm=self.factory.getInstance('currentBranchKey',...
                        curBranchKey);
                    self.aux_checkUpdateAll(cm,isOkExpVec(iBranch));
                    %
                end
            end
            %
            function check(branchList,varargin)
                self.verifyEqual(isSuccess,true,msgStr);
                isOk=isequal(sort(branchList),...
                    sort(self.cm.getBranchKeyList(varargin{:})));
                self.verifyTrue(isOk);
            end
        end
        function self=test_update(self)
            self.cm.deployConfTemplate('testConfA');
            self.cm.updateConfTemplate('testConfA');
            [SConf,confVersion,metaData]=self.tcm.getConf('testConfB');
            self.cm.putConf('testConfB',SConf,confVersion,metaData);
            %
            self.aux_checkUpdate(self.cm);
            self.aux_checkUpdate(self.tcm);
        end
    end
end