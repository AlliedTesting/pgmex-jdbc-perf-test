% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef mlunit_test_emaillogger < mxberry.unittest.TestCase
    properties (Access=private)
        eMail
        smtpServer
    end
    methods
        function self = mlunit_test_emaillogger(varargin)
            self = self@mxberry.unittest.TestCase(varargin{:});
            % Save current Internet preferences
            if ispref('Internet','SMTP_Server')
                self.smtpServer = getpref('Internet','SMTP_Server');
            else
                self.smtpServer = '';
            end
            if ispref('Internet','E_mail')
                self.eMail = getpref('Internet','E_mail');
            else
                self.eMail = '';
            end
        end
    end
    methods (Test)
        %
        function self = test_emaillogger_fail(self)
            obj=mxberry.log.EmailLogger(...
                'emailDistributionList',{'billy@microsoft.com'},...
                'emailAttachmentNameList',{},...
                'smtpServer','invalid.server',...
                'subjectSuffix','for mydatabase on mypc',...
                'loggerName','MyApplication',...
                'isThrowExceptions',true); %#ok<NASGU>
            commandStr=['obj.sendMessage(''calculation started'',',...
                '''calculation started'')']; %#ok<NASGU>
            self.runAndCheckError('evalc(commandStr)','sendEmailFailed');
        end
        %
        function self = test_emaillogger_preferences(self)
            % E-mail settings that will be used to configure test EmailLogger
            testSmtpServer = 'some.server';
            [userName,hostName]=mxberry.system.getuserhost();
            if isempty(userName)
                userName = 'unknown';
            end
            if isempty(hostName)
                hostName = 'unknown';
            end
            %
            testEmail = [userName, '@', hostName];
            % EmailLogger sets preferences Internet.SMTP_Server and
            % Internet.E_mail
            logger=mxberry.log.EmailLogger(...
                'emailDistributionList',{'billy@microsoft.com'},...
                'smtpServer',testSmtpServer,...
                'subjectSuffix','for mydatabase on mypc',...
                'loggerName','MyApplication');
            self.verifyEqual(testSmtpServer,...
                logger.getSMTPServer());
            self.verifyEqual(testEmail,...
                logger.getFromEmailAddress());
            % EmailLogger should warn about changed preferences and reset
            % them to their original values
            setpref('Internet','SMTP_Server','some.other.server');
            setpref('Internet','E_mail','some.other@email');
            outputText = evalc(...
                ['logger.sendMessage(''calculation started'',',...
                '''calculation started'')']);
            nWarnings = length(strfind('Warning:',outputText));
            self.verifyEqual(0,nWarnings)
            self.verifyEqual(testSmtpServer,...
                logger.getSMTPServer());
            self.verifyEqual(testEmail,...
                logger.getFromEmailAddress());
            % If 'dryRun' property is set, EmailLogger should also change
            % e-mail preferences
            FROM_EMAIL_ADDRESS='test@mydomain.com';
            logger=mxberry.log.EmailLogger(...
                'emailDistributionList',{'billy@microsoft.com'},...
                'smtpServer','some.other.server',...
                'subjectSuffix','for mydatabase on mypc',...
                'loggerName','MyApplication',...
                'dryRun',true,'fromEmailAddress',FROM_EMAIL_ADDRESS);
            self.verifyEqual('some.other.server',...
                logger.getSMTPServer());
            self.verifyEqual(FROM_EMAIL_ADDRESS,...
                logger.getFromEmailAddress());
        end
        %
        function self = tear_down(self)
            if ~isempty(self.smtpServer)
                setpref('Internet','SMTP_Server',self.smtpServer);
            elseif ispref('Internet','SMTP_Server')
                rmpref('Internet','SMTP_Server');
            end
            if ~isempty(self.eMail)
                setpref('Internet','E_mail',self.eMail);
            elseif ispref('Internet','E_mail')
                rmpref('Internet','E_mail');
            end
        end
    end
end