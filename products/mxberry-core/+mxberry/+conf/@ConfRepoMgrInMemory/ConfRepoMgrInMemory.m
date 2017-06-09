classdef ConfRepoMgrInMemory<mxberry.conf.ConfRepoManagerAnyStorage
    methods
        function self=ConfRepoMgrInMemory(varargin)
            % CONFREPOMGRINMEMORY is the class constructor with the following
            % parameters
            %
            % Input:
            %
            % Output:
            %   self: the constructed object
            %
            %            % $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
            % $Copyright: 2015-2016 Peter Gagarinov, PhD
            %             2015 Moscow State University
            %            Faculty of Computational Mathematics and Computer Science
            %            System Analysis Department$
            %
            %
            import mxberry.core.cont.ondisk.HashMapXMLMetaData;
            %
            storage=HashMapXMLMetaData(...
                'storageFormat','none');
            self=self@mxberry.conf.ConfRepoManagerAnyStorage(...
                storage);
            %
        end
        function destFileName=copyConfFile(self,destFolderName,varargin)
            % COPYCONFFILE copies a configuration file to a specified file
            %
            % Input:
            %   regular:
            %       destFolderName/destFileName: char[1,] - destination
            %           folder/file name
            %   optional:
            %       confName: char[1,] - configuration name
            %   properties:
            %       destIsFile: logical[1,1] - if true, destFolderName is
            %           interpreted as a file name and as a folder name
            %           otherwise, false by default
            % Output:
            %   regular:
            %       destFileName: char[1,] - destination file name
            %
            %
            [reg,~,isDestFile]=mxberry.core.parseparext(varargin,...
                {'destIsFile';false;'isscalar(x)&&islogical(x)'},...
                'regCheckList',{'isstring(x)'},...
                'regDefList',{self.getCurConfName()});
            confName=reg{1};
            if isDestFile
                [destPathStr,destConfName,destExt]=fileparts(destFolderName);
                mxberry.core.check.checkgen(destExt,'strcmp(x,''.xml'')');
            else
                destPathStr=destFolderName;
                destConfName=confName;
            end
            storage=mxberry.core.cont.ondisk.HashMapXMLMetaData(...
                'storageFormat','verxml',...
                'storageLocationRoot',destPathStr,...
                'skipStorageBranchKey',true,...
                'checkStorageContent',false);
            storage.put(destConfName,self.getConfInternal(confName));
            if nargout>0
                destFileName=[destPathStr filesep destConfName '.xml'];
            end
        end
        function selectConf(self,confName,varargin)
            % SELECTCONF selects the configuration specified by name
            % Only one configuration can be selected at any time. A selected
            % configuration is used for parameters reading/storing.
            %
            % Input:
            %   regular:
            %       self: the object itself
            %       confName: char[1,] - configuration name
            %
            %   properties:
            %       reloadIfSelected: logical[1,1] - if false
            %           configuration is loaded from disk only if it wasn't
            %           selected previously, true by default
            %
            %
            [reg,~]=mxberry.core.parseparams(varargin,{'reloadIfSelected'});
            selectConf@mxberry.conf.ConfRepoManagerAnyStorage(...
                self,confName,...
                'reloadifSelected',false,reg{:});
        end
        function resVal=getParam(self,paramName,varargin)
            % GETPARAM extracts a value for a parameter specified by name
            %
            % Input:
            %   regular:
            %       self: the object itself
            %       paramName: char[1,] - parameter name
            %
            %   properties:
            %       skipCache: logical[1,1] - if true, the parameter is
            %          extracted from the disk directly without checking
            %          the cache
            %
            %
            [reg,~]=mxberry.core.parseparams(varargin,{'skipCache'});
            resVal=getParam@mxberry.conf.ConfRepoManagerAnyStorage(...
                self,paramName,reg{:},'skipCache',false);
        end
        function flushCache(self) %#ok<MANU>
        end
    end
    methods(Access=protected)
        function confNameList=getConfNameListInternal(self)
            % GETCONFNAMELISTINTERNAL is an internal implementation of
            % getConfNameList
            %
            confNameList=self.getCachedConfNames();
        end
    end
end