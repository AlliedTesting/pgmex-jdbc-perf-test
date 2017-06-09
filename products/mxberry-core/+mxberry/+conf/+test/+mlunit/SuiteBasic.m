% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef SuiteBasic < matlab.unittest.TestCase
    properties (Access=private)
        resTmpDir
    end
    
    methods
        function self = SuiteBasic(varargin)
            self = self@matlab.unittest.TestCase(varargin{:});
        end
    end
    methods (TestMethodSetup)
        function self = set_up(self)
            self.resTmpDir=mxberry.test.TmpDataManager.getDirByCallerKey();
        end
    end
    methods (TestMethodTeardown)
        function self = tear_down(self)
            mxberry.io.rmdir(self.resTmpDir,'s');
        end
    end
    methods (Test)
        function testInMemoryMgr_copyFile(self)
            resTmpDir = self.resTmpDir; %#ok<*PROP>
            crm=mxberry.conf.ConfRepoMgrInMemory();
            crm.putConf('test',struct('a',1,'b',2));
            [fid,messageStr]=fopen([resTmpDir,filesep,'test.txt'],'a');
            if fid<0
                mxberry.core.throwerror('failedFileCreation',messageStr);
            end
            fclose(fid);
            crm.copyConfFile(resTmpDir);
            crm.copyConfFile(resTmpDir);
            isOk=mxberry.io.isfile(...
                [resTmpDir,filesep,'test.xml']);
            self.verifyEqual(isOk,true);
            resFileName=[resTmpDir,filesep,'res.xml'];
            crm.copyConfFile(resFileName,'destIsFile',true);
            isOk=mxberry.io.isfile(resFileName);
            self.verifyEqual(isOk,true);
        end
        function testPatchRepoAsProp(~)
            import mxberry.conf.test.*;
            cpr=StructChangeTrackerTest();
            [~]=ConfRepoMgrAdv('confPatchRepo',cpr);
            [~]=ConfRepoMgrAdv('confPatchRepo',cpr,...
                'putStorageHook',@(x,y)x,...
                'getStorageHook',@(x,y)x);
        end
        function test_putConfToStorage(self)
            import mxberry.conf.test.*;
            factory=mxberry.conf.test.ConfRepoManagerFactory(...
                'plain');
            crm=factory.getInstance();
            crm.removeAll();
            SConfA=genteststruct(1);
            metaA=struct('a','1','b','2');
            %
            crm.putConf('testConfA',SConfA,100,metaA);
            crm.setParam('test123',1);
            crm.setParam('test123',2,'writeDepth','cache');
            crm=factory.getInstance();
            crm.selectConf('testConfA');
            resVal=crm.getParam('test123');
            self.verifyEqual(1,resVal);
            crm.setParam('test123',2,'writeDepth','cache');
            crm.storeCachedConf('testConfA');
            crm=factory.getInstance();
            crm.selectConf('testConfA');
            resVal=crm.getParam('test123');
            self.verifyEqual(2,resVal);
            crm.removeAll();
            %
        end
        function test_emptyVersion(self)
            crm=mxberry.conf.test.AdaptiveConfRepoMgrNanVer();
            %
            crm.setConfPatchRepo(...
                mxberry.conf.test.StructChangeTrackerNoPatches());
            crm.deployConfTemplate('default','overwrite',true);
            %
            crm.selectConf('default');
            %
            crm.setConfPatchRepo(...
                mxberry.conf.test.StructChangeTrackerTest());
            crm.deployConfTemplate('default','forceUpdate',true);
            [~,lastVersion]=crm.getConf('default');
            self.verifyEqual(true,~isnan(lastVersion));
        end
        function test_emptyVersion_ConfRepoMgr(self)
            crm=mxberry.conf.test.ConfRepoMgrNanVer();
            %
            crm.setConfPatchRepo(...
                mxberry.conf.test.StructChangeTrackerNoPatches());
            SData.alpha=0;
            crm.putConf('def',SData,'selectConf',false);
            %
            crm.updateConf('def');
            crm.flushCache();
            self.verifyEqual(false,crm.isConfSelected('def'));
            crm.selectConf('def');
            self.verifyEqual(true,crm.isConfSelected('def'));
            %
            crm.setConfPatchRepo(...
                mxberry.conf.test.StructChangeTrackerTest());
            crm.updateConf('def');
            [SDataUpd,lastVersion]=crm.getConf('def');
            crm.removeConf('def');
            self.verifyEqual(true,~isnan(lastVersion));
            self.verifyEqual(true,isequal(SDataUpd.alpha,1));
            self.verifyEqual(true,isequal(SDataUpd.beta,2));
        end
        %
        function testCopyConfFile(self)
            import mxberry.conf.test.*;
            resDir=self.resTmpDir;
            crm=ConfRepoMgrAdv();
            crm.putConf('def',struct());
            crm.copyConfFile(resDir,'def');
            resFile=[resDir,filesep,'def.xml'];
            check(resFile);
            delete(resFile);
            %
            altResFile=[resDir,filesep,'myfile.xml'];
            crm.copyConfFile(altResFile,'destIsFile',true);
            check(altResFile);
            delete(altResFile);
            %
            crm.copyConfFile(altResFile,'def','destIsFile',true);
            check(altResFile);
            delete(altResFile);
            %
            crm.selectConf('def');
            crm.copyConfFile(resDir);
            check(resFile);
            function check(resFile)
                isOk=mxberry.io.isfile(resFile);
                self.verifyEqual(true,isOk);
            end
        end
        %
        function testSelectConf(self)
            import mxberry.conf.test.*;
            crm=ConfRepoMgrUpd();
            acrm=AdpConfRepoMgrUpd();
            crm.putConf('def',struct(),0);
            acrm.putConf('def',struct(),0);
            [~,confVer]=crm.getConf('def');
            self.verifyEqual(true,confVer==0);
            [~,confVer]=acrm.getConf('def');
            self.verifyEqual(true,confVer==0);
            crm.selectConf('def');
            acrm.selectConf('def');
            [~,confVer]=crm.getConf('def');
            self.verifyEqual(true,confVer==103);
            [~,confVer]=acrm.getConf('def');
            self.verifyEqual(true,confVer==103);
        end
        %
        function testSaveLoadHook(self)
            import mxberry.conf.test.*;
            SEP_STR='+';
            CONF_NAME='def';
            SPOIL_SUF='spoil';
            NOT_UPDATE_GET_PATH={{1,1},'alpha2',{1,1},'a'};
            crm=ConfRepoMgrAdv('putStorageHook',@putStorageHook,...
                'getStorageHook',@getStorageHook);
            check();
            confPatchRepo=StructChangeTrackerAdv();
            crm=AdpConfRepoMgr('putStorageHook',@putStorageHook,...
                'getStorageHook',@getStorageHook,...
                'confPatchRepo',confPatchRepo);
            check();
            function check()
                import mxberry.conf.test.*;
                crm.setConfPatchRepo(StructChangeTrackerAdv());
                SInp.alpha.beta={'aaa','bbb';'aa','bbbb'};
                SInp.alpha1={'aaa23','bbb23';'aa23','bbbb23'};
                SInp.alpha2(2,3).a={'aaa23','bbb23';'aa23','bbbb23'};
                SInp.alpha2(1,1).a={'aaa11','bbb11';'aa11','bbbb11'};
                SInp.alpha3=0;
                SInp.alpha4={'a';'b';'c'};
                SInp.alpha5=[1;2;3];
                %
                crm.putConf(CONF_NAME,SInp,0);
                crm.flushCache();
                [SRes,confVer]=getConf();
                self.verifyEqual(0,SRes.alpha3);
                self.verifyEqual(0,confVer);
                self.verifyEqual(true,isequal(SRes,SInp));
                %
                crm.flushCache();
                crm.updateConf(CONF_NAME);
                crm.flushCache();
                [SRes,confVer]=getConf();
                %
                SExp=SInp;
                SExp.alpha3=103;
                SExp.alpha1=strcat(SExp.alpha1,'12103');
                SExp.alpha5=SExp.alpha5*1000;
                self.verifyEqual(103,confVer);
                self.verifyEqual(103,SRes.alpha3);
                self.verifyEqual(true,isequal(SRes,SExp));
            end
            %
            function  [SRes,confVer]=getConf()
                [SRes,confVer]=crm.getConf(CONF_NAME);
                val=getfield(SRes,NOT_UPDATE_GET_PATH{:});
                val=cellfun(@(x)strrep(x,SPOIL_SUF,''),val,...
                    'UniformOutput',false);
                SRes=setfield(SRes,NOT_UPDATE_GET_PATH{:},val);
            end
            function val=putStorageHook(val,~)
                if iscellstr(val)
                    val=mxberry.core.string.catcellstrwithsep(val,SEP_STR);
                elseif isnumeric(val)
                    val=val+1;
                end
                %
            end
            function val=getStorageHook(val,pathSpec)
                if iscellstr(val)
                    val=mxberry.core.string.sepcellstrbysep(val,SEP_STR);
                    if isequal(pathSpec,NOT_UPDATE_GET_PATH)
                        val=cellfun(@(x)[x,SPOIL_SUF],val,...
                            'UniformOutput',false);
                    end
                elseif isnumeric(val)
                    val=val-1;
                end
            end
        end
        function testReloadIfSelected(self)
            import mxberry.conf.test.*;
            cpr=StructChangeTrackerTest();
            crm=ConfRepoMgrAdv('confPatchRepo',cpr);
            crm.putConf('conf1',struct('a',1));
            crm.putConf('conf2',struct('a',2));
            crm.getConf('conf2');
            crm.selectConf('conf1');
            crm.getConf('conf1');
            crm.selectConf('conf2','reloadIfSelected',false);
            SRes=crm.getCurConf;
            self.verifyEqual(2,SRes.a);
        end
    end
end
