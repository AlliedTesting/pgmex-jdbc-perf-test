classdef AdaptiveConfRepoManager<mxberry.conf.AdaptiveConfRepoManagerUpd
    % ADAPTIVECONFREPOMANAGER is a simplistic extension of
    % AdaptiveConfRepoManager that injects a configuration change
    % repository class equivolent.test.conf.ConfPatchRepo
    % automatically
    %
    %
    % $Author: Peter Gagarinov <pgagarinov@gmail.com> $	$Date: 2011-05-18 $
    % $Copyright: Moscow State University
    %            Faculty of Computational Mathematics and Computer Science
    %            System Analysis Department 2011 $
    %
    %
    methods
        function self=AdaptiveConfRepoManager(varargin)
            self=self@mxberry.conf.AdaptiveConfRepoManagerUpd(varargin{:});
            confPatchRepo=mxberry.test.conf.ConfPatchRepo();
            self.deployConfTemplate('*','forceUpdate',true);
            self.setConfPatchRepo(confPatchRepo);
        end
    end
end