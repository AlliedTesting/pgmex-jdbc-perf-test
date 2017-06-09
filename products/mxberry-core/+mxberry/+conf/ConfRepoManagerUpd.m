classdef ConfRepoManagerUpd<mxberry.conf.ConfRepoManager
    % CONFREPOMANAGERUPD is a simplistic extension of
    % ConfRepoManager that updates configuration upon selection
    %
    %    % $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
    % $Copyright: 2015-2016 Peter Gagarinov, PhD
    %             2015 Moscow State University
    %            Faculty of Computational Mathematics and Computer Science
    %            System Analysis Department$
    %
    %
    methods
        function self=ConfRepoManagerUpd(varargin)
            self=self@mxberry.conf.ConfRepoManager(varargin{:});
        end
        function selectConf(self,confName,varargin)
            % SELECTCONF - selects the specified plain configuration. If
            % the one does not exist it is created from the template
            % configuration. If the latter does not exist an exception is
            % thrown
            %
            %
            self.updateConf(confName);
            selectConf@mxberry.conf.ConfRepoManager(self,...
                confName,varargin{:});
        end
    end
end