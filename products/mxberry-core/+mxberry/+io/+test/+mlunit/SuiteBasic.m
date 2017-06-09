% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef SuiteBasic < mxberry.unittest.TestCase
    methods
        function self = SuiteBasic(varargin)
            self = self@mxberry.unittest.TestCase(varargin{:});
        end
    end
    methods (Test)
        %
        function testDirsRecursive(self)
            import mxberry.io.PathUtils.rmLastPathParts;
            dirName=rmLastPathParts(...
                fileparts(which(mfilename('class'))),2);
            %
            check('glob:**','*',1,true);
            check('glob:**','*',2,false);
            check('glob:**','*',Inf,false);
            fRun=@()check('glob:*','*.m',-1,false);
            self.runAndCheckError(fRun,'wrongInput');
            %
            function fileNameList=check(...
                    patternStr,expPatternStr,maxDepth,isOk)
                import mxberry.io.listdirsrecursive;
                fileNameList=sort(listdirsrecursive(dirName,patternStr,...
                    maxDepth));
                self.verifyTrue(~isempty(fileNameList));
                fileNameList=setdiff(fileNameList,dirName);
                SFileVec=dir([dirName,filesep,expPatternStr]);
                isDirVec=[SFileVec.isdir];
                SFileVec=SFileVec(isDirVec);
                shortNameList={SFileVec.name}.';
                shortNameList=shortNameList(~ismember(shortNameList,...
                    {'..','.'}));
                fileNameExpList=sort(strcat(dirName,...
                    filesep,shortNameList));
                if isOk
                    self.verifyEqual(fileNameList,fileNameExpList);
                else
                    self.verifyNotEqual(fileNameList,fileNameExpList);
                end
            end
        end
        %
        function testListFilesRecursive(self)
            import mxberry.io.PathUtils.rmLastPathParts;
            dirName=rmLastPathParts(...
                fileparts(which(mfilename('class'))),2);
            %
            check('glob:**.m','*.m',1,true);
            check('glob:**.m','*.m',2,false);
            check('glob:**.m','*.m',Inf,false);
            fRun=@()check('glob:**.m','*.m',0,false);
            self.runAndCheckError(fRun,'wrongInput');
            %
            function fileNameList=check(...
                    patternStr,expPatternStr,maxDepth,isOk)
                import mxberry.io.listfilesrecursive;
                fileNameList=sort(listfilesrecursive(dirName,patternStr,...
                    maxDepth));
                SFileVec=dir([dirName,filesep,expPatternStr]);
                fileNameExpList=sort(strcat(dirName,...
                    filesep,{SFileVec.name}.'));
                if isOk
                    self.verifyEqual(fileNameList,fileNameExpList);
                else
                    self.verifyNotEqual(fileNameList,fileNameExpList);
                end
            end
        end
        function testCopyIsFileDir(self)
            FILE_NAME='1.mat';
            resTmpDir=mxberry.test.TmpDataManager.getDirByCallerKey();
            isOk=mxberry.io.isdir(resTmpDir);
            self.verifyTrue(isOk);
            %
            mxberry.io.rmdir(resTmpDir);
            isOk=mxberry.io.isdir(resTmpDir);
            self.verifyTrue(~isOk);
            %
            resTmpDir=mxberry.test.TmpDataManager.getDirByCallerKey();
            srcFileName=[resTmpDir,filesep,FILE_NAME];
            aVar=1; %#ok<NASGU>
            save(srcFileName,'aVar');
            isOk=mxberry.io.isfile(srcFileName);
            self.verifyTrue(isOk);
            %
            mxberry.io.rmdir(resTmpDir,'s');
            isOk=mxberry.io.isfile(srcFileName);
            self.verifyTrue(~isOk);
            %
            %test copyfile on long path
            resTmpDir=mxberry.test.TmpDataManager.getDirByCallerKey();
            save(srcFileName,'aVar');
            dstDir=[resTmpDir,repmat([filesep,repmat('a',1,50)],1,6)];
            mxberry.io.mkdir(dstDir);
            isOk=mxberry.io.isdir(resTmpDir);
            self.verifyTrue(isOk);
            mxberry.io.copyfile(srcFileName,dstDir);
            dstFileName=[dstDir,filesep,FILE_NAME];
            isOk=mxberry.io.isfile(dstFileName);
            self.verifyTrue(isOk);
            mxberry.io.rmdir(dstDir,'s');
            isOk=mxberry.io.isdir(dstDir);
            self.verifyTrue(~isOk);
            isOk=mxberry.io.isdir(resTmpDir);
            self.verifyTrue(isOk);
            mxberry.io.rmdir(resTmpDir,'s');
            isOk=mxberry.io.isdir(resTmpDir);
            self.verifyTrue(~isOk);
        end
        %
        function testRmMkDir(self)
            checkMaster({},{},'1');
            checkMaster({},{'s'},'1');
            checkMaster({},{'s'},['1',filesep,'2']);
            %
            function checkMaster(mkArgList,rmArgList,subDir)
                resTmpDir=mxberry.test.TmpDataManager.getDirByCallerKey();
                dirToCreate=[resTmpDir,filesep,subDir];
                checkIfExists(dirToCreate,false);
                mxberry.io.mkdir(dirToCreate,mkArgList{:});
                checkIfExists(dirToCreate,true);
                [isSuccess,msgStr,messageId]=mxberry.io.mkdir(dirToCreate,...
                    mkArgList{:});
                checkIfExists(dirToCreate,true);
                checkOk(false);
                mxberry.io.rmdir(dirToCreate,rmArgList{:});
                checkIfExists(dirToCreate,false);
                [isSuccess,msgStr,messageId]=mxberry.io.rmdir(dirToCreate,...
                    rmArgList{:});
                checkOk(false);
                function checkOk(isOk)
                    self.verifyEqual(isSuccess,isOk);
                    self.verifyEqual(isempty(msgStr),isOk);
                    self.verifyEqual(isempty(messageId),isOk);
                end
            end
            function checkIfExists(dirName,isExists)
                self.verifyEqual(isExists,...
                    mxberry.io.isdir(dirName));
            end
        end
        %
    end
end
