classdef ConfRepoManager<mxberry.conf.ConfRepoManagerAnyStorage&...
        mxberry.core.obj.ReflectionHelper
    properties (Constant)
        DEFAULT_STORAGE_BRANCH_KEY='_default';
    end
    methods
        function self=ConfRepoManager(varargin)
            % CONFREPOMANAGER is the class constructor with the following
            % parameters
            %
            % Input:
            %   properties:
            %       repoLocation: char[1,] - configuration repository location
            %
            %       storageBranchKey: char[1,] - repository branch
            %          location, ='_default' by default. A single
            %          repository can have multiple branches which increase
            %          the class flexibility greatly
            %
            %       confPatchRepo: mxberry.core.struct.AStructChangeTracker[1,1] -
            %          configuration version tracker
            %
            %       repoSubfolderName: char[1,] - if not specified
            %           'confrepo' name is used, otherwise, when specified
            %           along with repoLocation, it should be the same as the
            %           deepest subfolder in repoLocation. Finally, when
            %           repoSubfolderName is specified and repoLocation is not
            %           the location is chosen automatically with the deepest subfolder
            %           name equal to repoSubfolderName
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
            import mxberry.core.throwerror;
            import mxberry.core.parseparext;
            import mxberry.conf.ConfRepoManager;
            %
            %% parse input params
            [reg,~,...
                storageBranchKey,repoLocation,confPatchRepo,...
                repoSubfolderName,...
                isStorageBranchKeySpec,isRepoLocationSpec,...
                isConfPathRepoSpec,isRepoSubfolderSpecified]=...
                mxberry.core.parseparext(varargin,...
                {'storagebranchkey','repolocation','confpatchrepo',...
                'reposubfoldername';...
                'ConfRepoManager.DEFAULT_STORAGE_BRANCH_KEY',[],...
                [],'confrepo';...
                'isstring(x)','isstring(x)',...
                @(x)isa(x,'mxberry.core.struct.StructChangeTracker'),...
                'isstring(x)'});
            %
            if ~isStorageBranchKeySpec
                storageBranchKey=...
                    mxberry.conf.ConfRepoManager.DEFAULT_STORAGE_BRANCH_KEY;
            end
            %
            addArgList=reg;
            if isConfPathRepoSpec
                addArgList=[{confPatchRepo},reg];
            end
            %
            metaClassBoxedObj=mxberry.core.cont.ValueBox();
            self=self@mxberry.core.obj.ReflectionHelper(metaClassBoxedObj);
            metaClass=metaClassBoxedObj.getValue();
            if ~isRepoLocationSpec
                repoLocation=[fileparts(which(metaClass.Name)),filesep,...
                    repoSubfolderName];
            elseif isRepoSubfolderSpecified
                [~,subFolderName]=fileparts(repoLocation);
                if ~strcmp(subFolderName,repoSubfolderName)
                    throwerror('wrongInput',...
                        ['repoSubfolderName is not the same as the ',...
                        'subfolder specified as part of repoLocation']);
                end
            end
            %
            %%
            storage=mxberry.core.cont.ondisk.HashMapXMLMetaData(...
                'storageLocationRoot',repoLocation,...
                'storageBranchKey',storageBranchKey,...
                'storageFormat','verxml',...
                'useHashedPath',false);
            self=self@mxberry.conf.ConfRepoManagerAnyStorage(storage,...
                addArgList{:});
            %
        end
        function resObj=createInstance(self,varargin)
            % CREATEINSTANCE - returns an object of the same class by
            %                  calling a default constructor (with no
            %                  arameters)
            %
            %
            % Usage: resObj=getInstance(self)
            %
            % input:
            %   regular:
            %     self: any [] - current object
            %   optional
            %     any parameters applicable for relation constructor
            %
            %
            p=metaclass(self);
            resObj=feval(p.Name,varargin{:});
        end
    end
end