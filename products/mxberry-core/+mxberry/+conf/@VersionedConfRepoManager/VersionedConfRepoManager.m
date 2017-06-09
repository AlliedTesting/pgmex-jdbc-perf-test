classdef VersionedConfRepoManager<mxberry.conf.AdaptiveConfRepoManager&mxberry.core.struct.StructChangeTracker
    % VERSIONEDCONFREPOMANAGER is a simple extension of
    % AdaptiveConfRepoManager that provides an ability to define
    % configuration patches as methods of the class
    % (AdaptiveConfRepoManager requires an injection of
    % mxberry.core.struct.StructChangeTracker class that is not
    % that convinient). This approach can be used only by experts as the
    % patches have a direct access ot the class internals. To be safe, use
    % AdaptiveConfRepoManager class. To be sorry, use this class
    %
    %    % $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
    % $Copyright: 2015-2016 Peter Gagarinov, PhD
    %             2015 Moscow State University
    %            Faculty of Computational Mathematics and Computer Science
    %            System Analysis Department$
    %
    %
    
    methods
        function self=VersionedConfRepoManager(varargin)
            self=self@mxberry.core.struct.StructChangeTracker();
            self=self@mxberry.conf.AdaptiveConfRepoManager(varargin{:});
            self.setConfPatchRepo(self);
        end
    end
end