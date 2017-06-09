% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef Suite < matlab.unittest.TestCase
    properties
    end
    
    methods
        function self = Suite(varargin)
            self = self@matlab.unittest.TestCase(varargin{:});
        end
        %
    end
    methods(Test)
        function test_basicTouch(self)
            %% This is windows-specific test
            if ~ispc()
                return;
            end
            check(true);
            check(true,{'titlePrefix','test1'});
            check(true,{'titlePrefix','test2'});
            check(false);
            check(false,{'keepCache',false});
            check(false,{'keepCache',true});
            %
            function check(isProfInfo,inpArgList)
                profile clear;
                tmpDir=mxberry.test.TmpDataManager.getDirByCallerKey();
                mxberry.io.rmdir(tmpDir,'s');
                profile on;
                checkIfOff(false);
                profile off;
                %
                profile clear;
                profile on;
                for k=1:10,cellfun(@(y)cellfun(@(x)x,{1,2,3}),{1,2},...
                        'UniformOutput',false);
                end
                %
                if nargin<2
                    inpArgList={};
                end
                %
                SProfileInfo=profile('info');
                checkIfOff(true);
                %
                if isProfInfo
                    inpArgList=[{0,SProfileInfo},inpArgList];
                end
                hOut=mxberry.dev.prof.ProfileManager.profView(...
                    inpArgList{:});
                hOut.close();
                checkIfOff(true);
                %
                mxberry.dev.prof.ProfileManager.profSave(...
                    SProfileInfo,tmpDir);
                SFiles=dir([tmpDir,filesep,'*.html']);
                self.verifyEqual(true,numel(SFiles)>2);
                %
                function checkIfOff(isOff)
                    SStatus = profile('status');
                    self.verifyEqual(isOff,isequal('off',SStatus.ProfilerStatus));
                end
            end
        end
        function self=tear_down(self)
            profile off;
        end
        function testRunAndCheckTimeTouch(~)
            profileMgr=mxberry.dev.prof.ProfileManager();
            %
            [~]=profileMgr.runAndProcess(@run);
            [~]=profileMgr.runAndProcess(@run,'myProfilingCase');
            [~]=profileMgr.runAndProcess(@run,'myProfilingCase',...
                'nRuns',3);
            [~]=profileMgr.runAndProcess(@run,'myProfilingCase',...
                'nRuns',3,'useMedianTime',true);
            function run()
                1+1; %#ok<VUNUS>
            end
        end
    end
end