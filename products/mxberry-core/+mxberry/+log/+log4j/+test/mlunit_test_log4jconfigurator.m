% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef mlunit_test_log4jconfigurator < matlab.unittest.TestCase
    properties
        configurationProp
    end
    methods
        function self = mlunit_test_log4jconfigurator(varargin)
            [reg,prop] = mxberry.core.parseparams(varargin,...
                {'parallelConfiguration'});
            nReg = length(reg);
            self = self@matlab.unittest.TestCase(reg{1:min(nReg,2)});
            if ~isempty(prop)
                self.configurationProp = {'configuration', prop{2}};
            else
                self.configurationProp = {};
            end
        end
    end
    methods (Test)
        %
        function test_configuration_persistence(self)
            % This test changes Log4j configuration. We'll run it in a
            % separate process, so that the changes do not affect the
            % current process.
            if ~isempty(which('mxberry.pcalc.auxdfeval'))
                mxberry.pcalc.auxdfeval(...
                    @(x)self.aux_test_configuration_persistence,...
                    cell(1,1), 'alwaysFork', true,...
                    self.configurationProp{:});
            end
        end
        %
        function self=test_getLogger(self)
            logger=mxberry.log.log4j.test.Log4jConfigurator.getLogger();
            loggerName=char(logger.getName());
            logger2=mxberry.log.log4j.test.Log4jConfigurator.getLogger(loggerName);
            loggerName2=char(logger2.getName());
            self.verifyEqual(loggerName,loggerName2);
        end
        function self=test_getLoggerBySuffix(self)
            logger=mxberry.log.log4j.test.Log4jConfigurator.getLogger();
            loggerName=char(logger.getName());
            logger2=mxberry.log.log4j.test.Log4jConfigurator.getLogger(loggerName,false);
            loggerName2=char(logger2.getName());
            self.verifyEqual(loggerName,loggerName2);
            logger2=mxberry.log.log4j.test.Log4jConfigurator.getLogger('suffix',true);
            loggerName2=char(logger2.getName());
            self.verifyEqual([loggerName '.suffix'],loggerName2);
        end
    end
    methods (Access=private)
        %
        function aux_test_configuration_persistence(self)
            % Log4jConfigurator keeps track of configuration changes. It
            % also allows the configuration to be locked, in which case
            % further attempts to change the configuration result only in a
            % warning.
            import mxberry.log.log4j.test.Log4jConfigurator;
            import org.apache.log4j.Level;
            lastPropStr=mxberry.log.log4j.Log4jConfigurator.getLastLogPropStr;
            isLocked=mxberry.log.log4j.Log4jConfigurator.isLocked();
            onCln=onCleanup(@()restoreConf(lastPropStr,isLocked));
            %
            NL = sprintf('\n');
            appenderConfStr = ['log4j.appender.stdout=org.apache.log4j.ConsoleAppender',NL,...
                'log4j.appender.stdout.layout=org.apache.log4j.PatternLayout',NL,...
                'log4j.appender.stdout.layout.ConversionPattern=%5p %c - %m\\n'];
            % Unlock and reconfigure
            Log4jConfigurator.unlockConfiguration();
            self.verifyEqual(false,Log4jConfigurator.isLocked());
            confStr = ['log4j.rootLogger=WARN,stdout', NL, appenderConfStr];
            evalc('Log4jConfigurator.configure(confStr)');
            self.verifyEqual(true,Log4jConfigurator.isConfigured());
            self.verifyEqual(confStr,Log4jConfigurator.getLastLogPropStr());
            % Lock configuration and try to configure log4j again, using a
            % different level than it currently has. Log4jConfigurator
            % should do nothing, besides issuing a warning, and the level
            % should remain unchanged.
            Log4jConfigurator.lockConfiguration();
            self.verifyEqual(true,Log4jConfigurator.isLocked());
            confStr = ['log4j.rootLogger=INFO,stdout', NL, appenderConfStr]; %#ok<NASGU>
            outputText = evalc('Log4jConfigurator.configure(confStr)');
            if isempty( strfind(outputText,'WARN') )
                self.assertFail('Log4jConfigurator.configure should have issued at least 1 warning');
            end
            if isempty( regexp(outputText, 'in .* at line \d+', 'once') )
                self.assertFail('Log4jConfigurator.configure did not print a stack trace');
            end
            % Create a logger instance and check log level
            logger=Log4jConfigurator.getLogger();
            if logger.isInfoEnabled()
                self.assertFail('Locked Log4jConfigurator should not allow a configuration change');
            end
            % Now try to configure using configureSimply
            outputText = evalc('Log4jConfigurator.configureSimply(''INFO'')');
            if logger.isInfoEnabled()
                self.assertFail('Locked Log4jConfigurator should not allow a configuration change');
            end
            if isempty( strfind(outputText,'WARN') )
                self.assertFail('Log4jConfigurator.configureSimply should have issued at least 1 warning');
            end
            if isempty( regexp(outputText, 'in .* at line \d+', 'once') )
                self.assertFail('Log4jConfigurator.configureSimply did not print a stack trace');
            end
            % Unlock the configuration and try to change it
            Log4jConfigurator.unlockConfiguration();
            evalc('Log4jConfigurator.configure(''log4j.rootLogger=INFO'',''isLockAfterConfigure'',true)');
            if ~logger.isInfoEnabled()
                self.assertFail('Log4jConfigurator failed to change configuration');
            end
            self.verifyEqual(true,Log4jConfigurator.isLocked(),...
                'Failed to lock configuration using isLockAfterConfigure property');
            % Do the same using configureSimply
            Log4jConfigurator.unlockConfiguration();
            evalc('Log4jConfigurator.configureSimply(''WARN'',''isLockAfterConfigure'',true)');
            if logger.isInfoEnabled()
                self.assertFail('Log4jConfigurator failed to change configuration');
            end
            self.verifyEqual(true,Log4jConfigurator.isLocked(),...
                'Failed to lock configuration using isLockAfterConfigure property');
            function restoreConf(confStr,isLocked)
                s=warning('off',...
                    'MXBERRY:LOGGING:LOG4J:LOG4JCONFIGURATOR:CONFIGUREINTERNAL:emptyConfStr');
                mxberry.log.log4j.test.Log4jConfigurator.unlockConfiguration();
                mxberry.log.log4j.test.Log4jConfigurator.configure(...
                    confStr,'islockafterconfigure',isLocked);
                warning(s);
            end
        end
    end
end
