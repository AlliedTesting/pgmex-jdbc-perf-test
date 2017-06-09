classdef TmpDataManager<mxberry.io.TmpDataManager
    % TMPDATAMANAGER provides a basic functionality for managing temporary
    % data folders, root folder name is determined automatically
    %
    methods (Static)
        function setRootDir()
            ANCHOR_FILE_NAME=mfilename('class');
            curFilePath=which(ANCHOR_FILE_NAME);
            if isempty(curFilePath)
                mxberry.core.throwerror('anchorNotFound',...
                    sprintf('location of anchor file %s not found',...
                    curFilePath));
            end
            %
            dirName=[mxberry.io.PathUtils.rmLastPathParts(...
                curFilePath,3),...
                filesep,'TTD'];
            %
            mxberry.io.TmpDataManager.setRootDir(dirName);
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
            % $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
            % $Copyright: 2015-2016 Peter Gagarinov, PhD
            %             2015 Moscow State University
            %            Faculty of Computational Mathematics and Computer Science
            %            System Analysis Department$
            %
            %
            mxberry.test.TmpDataManager.setRootDir();
            %
            resDir=mxberry.io.TmpDataManager.getDirByKey(keyName);
        end
        function resDir=getDirByCallerKey(keyName)
            % GETDIRBYCALLERKEY returns a unique temporary directory name
            % based on caller name and optionally based on a specified key
            % and makes sure that this directory is empty
            %
            % Input:
            %   optional:
            %       keyName: char[1,] key name
            %
            % Output:
            %   resDir: char[1,] - resulting directory name
            %
            %
            if nargin<1
                keyName='';
            end
            mxberry.test.TmpDataManager.setRootDir();
            resDir=mxberry.io.TmpDataManager.getDirByCallerKey(...
                keyName,3);
        end
    end
end