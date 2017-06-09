classdef ConfStorage<mxberry.core.obj.StaticPropStorage
    % Conftorage is class that stores configuration for testing

    properties (GetAccess=private,Constant,Hidden)
        DEFAULT_CONF_NAME='default';
        DEFAULT_CONF_REPO_MGR_CLASS_NAME=[...
            'com.allied.pgmex.perftest.configuration.'...
            'AdaptiveConfRepoManager'];
    end
    
    %% Public methods
    
    methods (Static)
        function setConfName(confName)
            % SETCONFNAME sets name of configuration for testing
            %
            % Usage: setConfName(confName)
            %
            % input:
            %   regular:
            %     confName: char [1,] - string with name of
            %       configuration for testing
            %
            % Created by Ilya Roublev, Allied Testing LLC, 2017/04/21
            %
           
            if nargin<1
                mxberry.core.throwerror('wrongInput',...
                    'confName must be given as input');
            end
            if ~(ischar(confName)&&...
                    numel(confName)==size(confName,2)&&...
                    ~isempty(confName))
                mxberry.core.throwerror('wrongInput',...
                    'confName must be nonempty string');
            end
            feval([mfilename('class') '.setPropInternal'],...
                'confName',confName);
        end
        function setConfRepoMgr(confRepoMgr)
            % SETCONFREPOMGR sets object allowing to set configuration
            % for testing
            %
            % Usage: setConfRepoMgr(confRepoMgr)
            %
            % input:
            %   regular:
            %     confRepoMgr: ConfRepoManager [1,1] - object allowing
            %       to set configuration for testing
            %
            % Created by Ilya Roublev, Allied Testing LLC, 2017/04/21
            %
           
            if nargin<1
                mxberry.core.throwerror('wrongInput',...
                    'confRepoMgr must be given as input');
            end
            confRepoMgrClassName=eval([mfilename('class')...
                '.DEFAULT_CONF_REPO_MGR_CLASS_NAME']);
            if ~(isa(confRepoMgr,confRepoMgrClassName)&&...
                    numel(confRepoMgr)==1)
                mxberry.core.throwerror('wrongInput',...
                    'confRepoMgr must be scalar object inherited from %s',...
                    confRepoMgrClassName);
            end
            feval([mfilename('class') '.setPropInternal'],...
                'confRepoMgr',confRepoMgr);
        end
        function confRepoMgr=getConfRepoMgr()
            % GETCONFREPOMGR gets configuration set for testing
            %
            % Usage: confRepoMgr=getConfRepoMgr()
            %
            % output:
            %   regular:
            %     confRepoMgr: ConfRepoManager [1,1] - object with
            %       configuration set for testing
            %
            % Created by Ilya Roublev, Allied Testing LLC, 2017/04/21
            %
            
            %% get necessary parameters from storage
            [confRepoMgr,isConfRepoMgr]=...
                feval([mfilename('class') '.getPropInternal'],...
                'confRepoMgr',true);
            if ~isConfRepoMgr
                confRepoMgr=feval(eval([mfilename('class')...
                    '.DEFAULT_CONF_REPO_MGR_CLASS_NAME']));
            end
            [confName,isConfName]=...
                feval([mfilename('class') '.getPropInternal'],...
                'confName',true);
            if ~isConfName
                confName=eval(...
                    [mfilename('class') '.DEFAULT_CONF_NAME']);
            end
            confRepoMgr.selectConf(confName);
        end
        %
        function flush()
            % FLUSH clears info set by setConfName
            %
            % Usage: flush()
            %
            % Created by Ilya Roublev, Allied Testing LLC, 2017/04/21
            %
            
            branchName=mfilename('classname');
            mxberry.core.obj.StaticPropStorage.flushInternal(branchName);
        end         
    end
    
    %% Protected auxiliary methods 
    
    methods (Access=protected,Static)
        function [propVal,isThere]=getPropInternal(...
                propName,isPresenceChecked)
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
            % Created by Ilya Roublev, Allied Testing LLC, 2017/04/21
            %
            
            branchName=mfilename('classname');
            [propVal,isThere]=...
                mxberry.core.obj.StaticPropStorage.getPropInternal(...
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
            % Created by Ilya Roublev, Allied Testing LLC, 2017/04/21
            %
            
            branchName=mfilename('classname');
            mxberry.core.obj.StaticPropStorage.setPropInternal(...
                branchName,propName,propVal);
        end
        %
    end
end