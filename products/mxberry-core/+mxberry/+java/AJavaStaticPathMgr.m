% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef AJavaStaticPathMgr<mxberry.core.obj.StaticPropStorage
    properties (Constant)
        JAVA_CLASS_PATH_TXT='javaclasspath.txt'
    end
    properties (Access=protected)
        classPathFileName
    end
    methods (Abstract)
        %returns a list of jar files to be put on a static java path
        fileNameList=getJarFileNameList(self)
    end
    methods (Abstract,Access=protected)
        pathClassCMat=getRelativePathListToJars(~)
    end
    methods
        function self=AJavaStaticPathMgr(classPathFileName)
            self.classPathFileName=classPathFileName;
        end
        function setUp(self,isUserDirStartUpDir)
            import mxberry.core.throwwarn;
            import mxberry.core.throwerror;
            if nargin<2
                isUserDirStartUpDir=true;
            end
            pathClassCMat=self.getRelativePathListToJars();
            %
            if ~isempty(pathClassCMat)
                nPaths=size(pathClassCMat,1);
                for iPath=1:nPaths
                    defClassName=pathClassCMat{iPath,2};
                    classLocDir=fileparts(which(defClassName));
                    if isempty(classLocDir)
                        throwerror('wrongInput',...
                            'cannot find class %s on Matlab path',...
                            classLocDir);
                    end
                    indLoc=regexp(classLocDir,'((\\|\/)(\@|\+))','once');
                    classLocDir=classLocDir(1:indLoc);
                    indSepVec=find(classLocDir==filesep);
                    indSep=indSepVec(end-pathClassCMat{iPath,3});
                    classLocDir=classLocDir(1:indSep-1);
                    relPath=pathClassCMat{iPath,1};
                    %
                    relPath=strrep(relPath,'/',filesep);
                    relPath=strrep(relPath,'\',filesep);
                    %
                    pathList=[classLocDir,filesep,relPath];
                    addpath(pathList);
                end
            end
            %
            jarFileNameList=self.getJarFileNameList();
            toAddPathList=cellfun(@which,jarFileNameList,...
                'UniformOutput',false);
            %
            isEmptyVec=cellfun('isempty',toAddPathList);
            if any(isEmptyVec)
                if isUserDirStartUpDir
                    fThrow=@throwerror;
                else
                    fThrow=@throwwarn;
                end
                fThrow('noJarFilesOnMatlabPath',...
                    'Files %s cannot be found on Matlab path',...
                    list2str(jarFileNameList(isEmptyVec)));
            end
            toAddPathList=toAddPathList(~isEmptyVec);
            %
            if verLessThan('matlab', '8.2')
                throwwarn('wrongMatlabVer',...
                    'Matlab version 8.2/2013b or higher is expected');
                javaaddpath(toAddPathList);
            else
                if ~self.isUserDirClassPathSet()
                    missingPathList=toAddPathList;
                    isnThereVec=true(size(toAddPathList));
                    delPathList={};
                else
                    existingUserPathList=self.readUserDirClassPath();
                    isnThereVec=~ismember(toAddPathList,existingUserPathList);
                    missingPathList=toAddPathList(isnThereVec);
                    delPathList=setdiff(existingUserPathList,toAddPathList);
                end
                %
                fullStaticPathList=javaclasspath('-static');
                isnFullThereVec=~ismember(toAddPathList,fullStaticPathList);
                if ~any(isnFullThereVec)
                    self.dispMsg(...
                        sprintf(['files %s are already on ',...
                        'static java classpath'],...
                        list2str(toAddPathList)));
                end
                %
                if isUserDirStartUpDir&&...
                        ~all(isnThereVec==isnFullThereVec)
                    isInFullStaticVec=~isnFullThereVec&isnThereVec;
                    isInUserStaticVec=isnFullThereVec&~isnThereVec;
                    globalClassPathFile=self.getPrefDirClassPathFileName();
                    throwerror('wrongStaticPath',...
                        ['files %s are in current static path but not\n',...
                        'in %s while files %s are in %s but not in\n',...
                        'current static path.\n',...
                        'It can be that %s file contains the same ',...
                        'entries as %s.\n',...
                        'If that is the case please remove those ',...
                        'entries and restart Matlab!'],...
                        list2str(toAddPathList(isInFullStaticVec)),...
                        self.classPathFileName,...
                        list2str(toAddPathList(isInUserStaticVec)),...
                        self.classPathFileName,globalClassPathFile,...
                        self.classPathFileName);
                end
                %
                self.setUserDirClassPath(toAddPathList);
                %
                if any(isnFullThereVec)
                    throwwarn('restartMatlab',...
                        ['files %s have been added ',...
                        'to Java static class path,\n ',...
                        'files %s have been deleted from Java ',...
                        'static class path, \n',...
                        '<<-------------------->> \n',...
                        'adding these files to Dynamic Java Path \n',...
                        'as a temporary measure \n',...
                        '<<-------------------->> \n',...
                        '               \n',...
                        '<<<<------ PLEASE RESTART MATLAB ------->>>>'],...
                        list2str(missingPathList),list2str(delPathList));
                    %
                    javaaddpath(toAddPathList(isnFullThereVec));
                end
            end
        end
    end
    methods (Static)
        function pathList=getUserPathList(~)
            staticPathList=javaclasspath('-static');
            isUserPath=cellfun('isempty',regexp(javaclasspath('-static'),...
                ['^',regexptranslate('escape',matlabroot)]));
            pathList=staticPathList(isUserPath);
        end
    end
    methods (Access=protected)
        function pathList=readClassPathFile(~,fileName)
            [fid,errMsg]=fopen(fileName,'r');
            if fid<0
                throwerror('cannotOpenFile',errMsg);
            end
            %
            try
                resCell=textscan(fid,'%s','Delimiter','\n');
                pathList=resCell{1};
            catch meObj
                fclose(fid);
                rethrow(meObj);
            end
            fclose(fid);
        end
        function pathList=parseClassPathStr(~,classPathStr)
            resCell=textscan(classPathStr,'%s','Delimiter','\n');
            pathList=resCell{1};
        end
        function globalClassPathFile=getPrefDirClassPathFileName(self)
            globalClassPathFile=[prefdir,filesep,self.JAVA_CLASS_PATH_TXT];
        end
    end
    methods (Access=private)
        function isPos=isUserDirClassPathSet(self)
            isPos=mxberry.io.isfile(...
                self.classPathFileName,false);
        end
        %
        function pathList=readUserDirClassPath(self)
            pathList=self.readClassPathFile(self.classPathFileName);
        end
        %
        function setUserDirClassPath(self,pathList)
            import mxberry.core.throwerror;
            [fid,errMsg]=fopen(self.classPathFileName,'w');
            if fid<0
                throwerror('cannotOpenFile',errMsg);
            end
            try
                if ~isempty(pathList)
                    msgStr=sprintf('adding %s to %s',...
                        list2str(pathList),self.classPathFileName);
                    fwrite(fid,mxberry.core.string.catwithsep(pathList,...
                        sprintf('\n')));
                    self.dispMsg([msgStr,' :done'])
                else
                    self.dispMsg(sprintf('Nothing to add to %s',...
                        self.classPathFileName));
                end
            catch meObj
                fclose(fid);
                rethrow(meObj);
            end
            fclose(fid);
        end
        function dispMsg(self,msgStr)
            SEP_SYMB='-';
            SEP_LENGTH=70;
            prefixStr=class(self);
            remSep=repmat(SEP_SYMB,1,max(SEP_LENGTH-numel(prefixStr),0));
            %
            nMid=fix(numel(remSep)*0.5);
            fprintf([remSep(1:nMid),prefixStr,remSep((nMid+1):end),'\n']);
            disp(msgStr);
            fprintf(['\n',repmat(SEP_SYMB,1,SEP_LENGTH),'\n']);
            %
        end
    end
end
%
function outStr=list2str(inpList)
outStr=sprintf('\n[%s]\n',mxberry.core.string.catwithsep(inpList,sprintf(',\n')));
end