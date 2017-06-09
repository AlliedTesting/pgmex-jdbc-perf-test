classdef ProfileInfoDetailed<mxberry.dev.prof.ProfileInfo
    % PROFILEINFODETAILED contains detailed profiling info obtaining during
    % exectution of some code
    
    properties (Access=private,Hidden)
        % detailed profile info
        StProfileInfo
    end
    
    methods
        function self=ProfileInfoDetailed()
            % PROFILEINFODETAILED is constructor of ProfileInfoDetailed
            % class
            %
            % Usage: self=ProfileInfoDetailed()
            %
            %            % $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
            % $Copyright: 2015-2016 Peter Gagarinov, PhD
            %             2015 Moscow State University
            %            Faculty of Computational Mathematics and Computer Science
            %            System Analysis Department$
            %
            %
            
            self=self@mxberry.dev.prof.ProfileInfo();
            self.StProfileInfo=[];
        end
        
        function tic(self)
            % TIC starts a stopwatch timer and begins profiling
            %
            % Usage: tic(self)
            %
            % input:
            %   regular:
            %     self: ProfileInfoDetailed [1,1] - class object
            %
            %
            
            self.StProfileInfo=[];
            tic@mxberry.dev.prof.ProfileInfo(self);
            profile on;
        end
        
        function resTime=toc(self)
            % TOC ends profiling and stops the timer, returning the time
            % elapsed in seconds
            %
            % Usage: resTime=toc(self)
            %
            % input:
            %   regular:
            %     self: ProfileInfoDetailed [1,1] - class object
            % output:
            %   regular:
            %     resTime: double [1,1] - time between tic and toc
            %
            %
            
            resTime=toc@mxberry.dev.prof.ProfileInfo(self);
            if isempty(self.StProfileInfo)
                profile off;
                self.StProfileInfo=profile('info');
            end
        end
        
        function StProfileInfo=getProfileInfo(self)
            % GETPROFILEINFO returns structure containing info on profiling
            %
            % Usage: StProfileInfo=getProfileInfo(self)
            %
            % input:
            %   regular:
            %     self: ProfileInfoDetailed [1,1] - class object
            % output:
            %   regular:
            %     StProfileInfo: struct [1,1] - structure containing the
            %         current profiler statistics (see help for PROFILE
            %         section PROFILE('INFO') for details)
            %
            %
            import mxberry.core.throwerror;
            if isempty(self.StProfileInfo)
                throwerror('wrongInput',...
                    'You must call TOC before calling getProfileInfo');
            end
            StProfileInfo=self.StProfileInfo;
        end
        function resTime=process(self,varargin)
            % PROCESS takes info obtaining during profiling
            % calculates a total run time and generates a report
            %
            % Input:
            %   regular:
            %       self:
            %   optional:
            %       profCaseName: char[1,] - name of profiling case
            %       	Default: "default"
            %
            %   properties:
            %       profileMode: char [1,] - profiling mode, the following
            %          modes are supported:
            %            'none'/'off' - no profiling
            %            'viewer' - profiling reports are just displayed
            %            'file' - profiling reports are displayed and
            %               saved to the file
            %           Default: 'file'
            %
            %       callerName: char [1,] - name of caller whose name may
            %           be used for generation of total name of profiling
            %           case; if it is not given, the name of immediate
            %           caller of this function is used
            %
            %       profileDir: char [1,] - name of directory in which
            %           profiling reports are to be saved
            %			Default: curent folder
            %
            % Output:
            %   resTime: double [1,1] - total run time in seconds
            %
            %            % $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
            % $Copyright: 2015-2016 Peter Gagarinov, PhD
            %             2015 Moscow State University
            %            Faculty of Computational Mathematics and Computer Science
            %            System Analysis Department$
            %
            %
            import mxberry.core.throwerror;
            %
            mxberry.core.checkvar(self,'isscalar(x)');
            %
            %% initial actions
            [reg,callerName,profileDir,profileMode,isCallerNameSpec,...
                isProfileDirSpec]=...
                mxberry.core.parseparext(varargin,...
                {'callerName','profileDir','profileMode';...
                [],[],'file';
                'isstring(x)','isstring(x)||ischar(x)&&isempty(x)',...
                'isstring(x)'},[1 2],...
                'regCheckList',...
                {'isstring(x)',...
                'isstring(x)'},...
                'regDefList',{[],'default'});
            %
            if ~isCallerNameSpec
                callerName=mxberry.core.getcallername();
            end
            if ~isProfileDirSpec
                profileDir=fileparts(which(callerName));
            end
            %
            if ~isempty(reg)
                profCaseName=reg{1};
            else
                profCaseName='default';
            end
            %% process profiling results
            resTime=self.toc();
            %
            SProfileInfo=self.getProfileInfo();
            switch lower(profileMode)
                case 'viewer'
                    profCaseName=[callerName,'.',profCaseName];
                    mxberry.dev.prof.ProfileManager.profView(0,...
                        SProfileInfo,'titlePrefix',profCaseName);
                    %
                case 'file'
                    %
                    profName=[callerName,...
                        filesep,profCaseName,...
                        filesep,datestr(now(),'dd-mmm-yyyy_HH_MM_SS_FFF')];
                    profDir=[profileDir,filesep,'profiling',filesep,profName];
                    mxberry.dev.prof.ProfileManager.profSave(...
                        SProfileInfo,profDir);
                otherwise
                    throwerror('wrongInput',...
                        'profMode %s is not supported',profileMode);
            end
        end
    end
end