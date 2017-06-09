classdef TmpDataManager<mxberry.core.obj.StaticPropStorage
    %TMPDATAMANAGER implements a basic functionality for managing temporary
    %data folders
    
    methods (Static)
        function setRootDir(dirName)
            % SETROOTDIR sets up a root of temporary folders directory tree
            %
            % Note: By default, is setRootDir is not called a directory
            %   returned by built-in function 'tempdir' is used
            %
            mxberry.io.TmpDataManager.setPropInternal('rootDir',dirName);
        end
        function resDir=getDirByCallerKey(keyName,nStepsUp)
            % GETDIRBYCALLERKEY returns a unique temporary directory name
            % based on caller name and optionally based on a specified key
            % and makes sure that this directory is empty
            %
            % Input:
            %   optional:
            %       keyName: char[1,] key name
            %       nStepsUp: numeric[1,1] - number of steps
            %           up in the call stacks,  =1 by default
            %
            % Output:
            %   resDir: char[1,] - resulting directory name
            %
            %
            % $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
            % $Copyright: 2015-2016 Peter Gagarinov, PhD
            %             2015 Moscow State University
            %            Faculty of Computational Mathematics and Computer Science
            %            System Analysis Department$
            %
            %
            import mxberry.core.check.checkgen;
            if nargin<2
                nStepsUp=2;
                if nargin<1
                    keyName='';
                else
                    checkgen(keyName,'isstring(x)');
                end
            else
                checkgen(nStepsUp,'isnumeric(x)&&isscalar(x)');
            end
            callerName=mxberry.core.getcallername(nStepsUp,'full');
            resDir=mxberry.io.TmpDataManager.getDirByKey(...
                [callerName,'.',keyName]);
        end
        function resDir=getDirByKey(keyName)
            % GETDIRBYKEY returns a unique temporary directory name based on
            % specified key and makes sure that this directory is empty
            %
            % Input:
            %   regular:
            %       keyName: char[1,] key name
            %
            % Output:
            %   resDir: char[1,] - resulting directory name
            %
            %
            import mxberry.core.throwerror;
            mxberry.core.check.checkgen(keyName,'isstring(x)');
            [rootDir,isThere]=...
                mxberry.io.TmpDataManager.getPropInternal('rootDir',true);
            if ~isThere
                rootDir=mxberry.io.TmpDataManager.setDefaultRootDir();
            end
            curTaskName=mxberry.system.getpidhost();
            keyDirName=mxberry.core.hash({curTaskName,keyName});
            resDir=[rootDir,filesep,keyDirName];
            %
            if mxberry.io.isdir(resDir)
                try
                    mxberry.io.rmdir(resDir,'s');
                catch meObj
                    newMeObj=mxberry.core.throwerror('failedToRemoveDir',...
                        'could not remove directory %s',resDir);
                    newMeObj=addCause(newMeObj,meObj);
                    throw(newMeObj);
                end
            end
            try
                mxberry.io.mkdir(resDir);
            catch meObj
                newMeObj=mxberry.core.throwerror('failedToCreatedDir',...
                    'could not create directory %s',resDir);
                newMeObj=addCause(newMeObj,meObj);
                throw(newMeObj);
            end
        end
    end
    %
    methods (Access=protected,Static)
        function [propVal,isThere]=getPropInternal(propName,isPresenceChecked)
            % GETPROPINTERNAL gets corresponding property from storage
            %
            % Usage: [propVal,isThere]=...
            %            getPropInternal(propName,isPresenceChecked)
            %
            % input:
            %   regular:
            %     propName: char - property name
            %     isPresenceChecked: logical [1,1] - if true, then presence
            %         of given property is checked before its value is
            %         retrieved from the storage, otherwise value is
            %         retrieved without any check (that may lead to error
            %         if property is not yet logged into the storage)
            % output:
            %   regular:
            %     propVal: empty or matrix of some type - value of given
            %         property in the storage (if it is absent, empty is
            %         returned)
            %   optional:
            %     isThere: logical [1,1] - if true, then property is in the
            %         storage, otherwise false
            %
            %
            branchName=mfilename('class');
            [propVal,isThere]=mxberry.core.obj.StaticPropStorage.getPropInternal(...
                branchName,propName,isPresenceChecked);
        end
        %
        function setPropInternal(propName,propVal)
            % SETPROPINTERNAL sets value for corresponding property within
            % storage
            %
            % Usage: setPropInternal(propName,propVal)
            %
            % input:
            %   regular:
            %     propName: char - property name
            %     propVal: matrix of some type - value of given property to
            %         be set in the storage
            %
            %
            branchName=mfilename('class');
            mxberry.core.obj.StaticPropStorage.setPropInternal(...
                branchName,propName,propVal);
        end
        function tmpDirName=setDefaultRootDir()
            tmpDirName=tempdir;
            if strcmpi(tmpDirName(end),filesep)
                tmpDirName(end)=[];
            end
            mxberry.io.TmpDataManager.setRootDir(tmpDirName);
        end
    end
end