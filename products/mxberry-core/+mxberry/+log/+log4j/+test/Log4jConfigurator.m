classdef Log4jConfigurator<mxberry.log.log4j.Log4jConfigurator
    % LOG4JCONFIGURATOR implements the Log4jConfigurator abstract class
    % $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
	% $Copyright: 2015-2016 Peter Gagarinov, PhD
	%             2012-2015 Moscow State University,
	%            Faculty of Applied Mathematics and Computer Science,
	%            System Analysis Department$
	%
    properties (Constant)
        %
        MASTER_LOG_FILE_NAME='master';
        CHILD_LOG_FILE_NAME_PREFIX='child';
        LOG_FILE_EXT='log';
        MAIN_LOG_FILE_PREFIX='main.';
    end
    properties(Constant)
        SP_MAIN_LOG_FILE_NAME='test.log4j.logfile.main.name'
        SP_CUR_PROCESS_NAME='test.log4j.curProcessName'
        SP_LOG_DIR_WITH_SEP='test.log4j.logfile.dirwithsep'
        SP_LOG_FILE_EXP='test.log4j.logfile.ext'
        CONF_REPO_MGR_CLASS='';
    end
    methods (Access=private)
        function self=Log4jConfigurator()
        end
    end
    methods (Static)
        function configure(logPropStr,varargin)
            % CONFIGURE performs log4j configuration
            %
            self=mxberry.log.log4j.test.Log4jConfigurator();
            self.configureInternal(logPropStr,varargin{:});
        end
        function logFileName=getMainLogFileName()
            self=mxberry.log.log4j.test.Log4jConfigurator();
            logFileName=self.getMainLogFileNameInternal();
        end
    end
end
