classdef ProfileManager<handle
    properties (Access=private)
        profMode
        profDir
    end
    methods
        function self=ProfileManager(profMode,profDir)
            % ProfileManager performs a command execution and displaying
            % the profiling results
            % Input:
            %   optional:
            %       profileMode: char [1,] - profiling mode, the following modes
            %          are supported:
            %            'none'/'off' - no profiling
            %            'viewer' - profiling reports are just displayed
            %            'file' - profiling reports are displayed and saved to the
            %              file
            %       profileDir: char [1,] - name of directory in which profiling
            %           reports are to be saved
            %
            % Output:
            %   self: constructed object
            %
            % $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com>
            % $Copyright: 2015-2016 Peter Gagarinov, PhD
            %             2015 Moscow State University
            %            Faculty of Computational Mathematics and Computer Science
            %            System Analysis Department$
            %
            if nargin<2
                profDir='';
                if nargin<1
                    profMode='none';
                end
            end
            self.profMode=profMode;
            self.profDir=profDir;
        end
        function resTime=runAndProcess(self,fRun,varargin)
            % RUNANDPROCESS executes the specified command and generates
            % a profiling report using the specified name as a marker
            %
            % Input:
            %   regular:
            %       self:
            %       fRun: function_handle[1,] - function to execute
            %   optional:
            %       profCaseName: char[1,] - name of profiling case
            %
            %   properties:
            %       nRuns: numeric[1,1] - number of runs (1 by default)
            %       useMedianTime: logical [1,1] - if true, then median
            %           time of calculation is returned for all runs
            %
            % $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com>
            % $Copyright: 2015-2016 Peter Gagarinov, PhD
            %             2015 Moscow State University
            %            Faculty of Computational Mathematics and Computer Science
            %            System Analysis Department$
            %
            mxberry.core.checkvar(fRun,'isfunction(x)');
            %
            [reg,~,nRuns,useMedianTime]=...
                mxberry.core.parseparext(varargin,...
                {'nRuns','useMedianTime';1,false;...
                'isreal(x)&&isscalar(x)','islogical(x)&&isscalar(x)'},...
                [0,1],'propRetMode','separate');
            %
            if isempty(reg)
                profCaseName='default';
            else
                profCaseName=reg{1};
            end
            %
            isnDetailed=any(strcmpi(self.profMode,{'none','off'}));
            if isnDetailed
                if useMedianTime
                    resTimeVec=zeros(1,nRuns);
                    curProfileInfoObj=mxberry.dev.prof.ProfileInfo();
                    for iRun=1:nRuns
                        curProfileInfoObj.tic();
                        feval(fRun);
                        resTimeVec(iRun)=curProfileInfoObj.toc();
                    end
                    resTime=median(resTimeVec);
                else
                    profileInfoObj=mxberry.dev.prof.ProfileInfo();
                    profileInfoObj.tic();
                    for iRun=1:nRuns
                        feval(fRun);
                    end
                    resTime=profileInfoObj.process();
                end
            else
                profileInfoObj=mxberry.dev.prof.ProfileInfoDetailed();
                profileInfoObj.tic();
                try
                    for iRun=1:nRuns
                        feval(fRun);
                    end
                catch meObj
                    profileInfoObj.toc();
                    rethrow(meObj);
                end
                %
                resTime=profileInfoObj.process(...
                    profCaseName,'profileMode',self.profMode,...
                    'callerName',mxberry.core.getcallername(2),...
                    'profileDir',self.profDir);
            end
        end
    end
end