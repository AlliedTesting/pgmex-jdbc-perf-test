% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef TestCase<matlab.unittest.TestCase
    properties (Access=private)
        PROF_MODE='off';
        PROF_DIR='';
    end
    methods
        function runAndCheckError(self,commandStr,expIdentifierList,varargin)
            % RUNANDCHECKERROR executes the specifies command and checks
            % that it throws an exeption with an identifier containing the
            % specified marker
            %
            % Input:
            %   regular:
            %       self:
            %       commandStr: char[1,]/function_handle[1,1] - command to
            %                   execute
            %       expIdentifierList: double[0,0]/char[1,]/...
            %         cell[1,N] of char[1,] - list of of strings
            %           (a single string), containig expected exeption
            %           identifier markers. double[0,0] means that no
            %           identifier match is performed.
            %
            %
            %   optional:
            %       expMsgCodeList: char[1,]/cell[1,N] of char[1,] - list
            %           of strings (a single string)
            %           containig expected exception message
            %           markers. For each field in expIdentifierList supposed
            %           to be one field in expMsgCodeList. In case of more then
            %           one argument in expIdentifierList, if you don't expect
            %           any exception messages, put '' in corresponding
            %           field. double[0,0] means that no identifier match
            %           is performed
            %
            %   properties:
            %       causeCheckDepth: double[1,1] - depth at which causes of
            %          the given exception are checked for matching the
            %          specified patters, default value is 0 (no cause is
            %          checked)
            %
            %       reportStr: char[1,] - report, published upon test
            %           failure
            %
            % $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
            % $Copyright: 2015-2016 Peter Gagarinov, PhD
            %             2012-2015 Moscow State University
            %            Faculty of Applied Mathematics and Computer Science
            %            System Analysis Department$
            import mxberry.core.checkmultvar;
            import mxberry.core.throwerror;
            import mxberry.core.check.lib.*;
            %
            isNoIdentPatternSpec=false;
            if ischar(expIdentifierList)
                expIdentifierList={expIdentifierList};
            elseif isempty(expIdentifierList)
                isNoIdentPatternSpec=true;
            end
            %
            nExpIdentifiers=length(expIdentifierList);
            %
            [reg,isRegSpec,causeCheckDepth,reportStr,~,isRepStrSpec]=...
                mxberry.core.parseparext(varargin,...
                {'causeCheckDepth','reportStr';...
                0,'successful execution when failure is expected';...
                'isscalar(x)&&isnumeric(x)',@isstring},...
                [0,1],...
                'regDefList',{[]},...
                'regCheckList',{@(x)(iscellstr(x)||isstring(x))});
            %
            if isRegSpec
                expMsgCodeList=reg{1};
                if ischar(expMsgCodeList)
                    expMsgCodeList={expMsgCodeList};
                end
                isNoMsgPatternSpecVec=false(1,numel(expMsgCodeList));
            else
                isNoMsgPatternSpecVec=true(1,nExpIdentifiers);
                expMsgCodeList=repmat({''},1,nExpIdentifiers);
            end
            nMsgCodes=numel(expMsgCodeList);
            if isNoIdentPatternSpec
                expIdentifierList=repmat({''},1,nMsgCodes);
                isNoIdentPatternSpecVec=true(1,nMsgCodes);
            else
                isNoIdentPatternSpecVec=false(1,nMsgCodes);
            end
            %
            checkmultvar(@(x,y) size(y,2) == 0 || ...
                size(y,2) == size(x,2),2,expIdentifierList,expMsgCodeList);
            %
            try
                if ischar(commandStr)
                    evalin('caller',commandStr);
                else
                    feval(commandStr);
                end
            catch meObj
                errMsg='';
                [isIdentMatchVec,identPatternStr] =checkCode(meObj,...
                    'identifier',expIdentifierList);
                [isMsgMatchVec,msgPatternStr] =checkCode(meObj,...
                    'message',expMsgCodeList);
                %
                isOk=any((isIdentMatchVec|isNoIdentPatternSpecVec)&...
                    (isMsgMatchVec|isNoMsgPatternSpecVec));
                patternStr=['identifier(',identPatternStr,')',...
                    'message(',msgPatternStr,')'];
                %
                if isRepStrSpec
                    addSuffix=', %s';
                    addArgList={reportStr};
                else
                    addSuffix='';
                    addArgList={};
                end
                
                self.verifyEqual(true,isOk,...
                    sprintf(...
                    ['\n no match found for pattern %s',...
                    ' exception details: \n %s',addSuffix],...
                    patternStr,errMsg,addArgList{:}))
                return;
            end
            self.verifyEqual(true,false,reportStr);
            function [isMatchVec,patternsStr]=checkCode(inpMeObj,...
                    fieldName,codeList)
                %
                errMsg=strrep(...
                    mxberry.core.MExceptionUtils.me2HyperString(...
                    inpMeObj),...
                    '%','%%');
                isMatchVec=cellfun(...
                    @(x)getIsCodeMatch(...
                    inpMeObj,causeCheckDepth,fieldName,x),codeList);
                %
                patternsStr=mxberry.core.string.catwithsep(codeList,', ');
                %
                
            end
            function isPositive=getIsCodeMatch(inpMeObj,checkDepth,...
                    fieldName,codeStr)
                fieldValue = inpMeObj.(fieldName);
                if isempty(fieldValue)
                    isPositive= isempty(codeStr);
                else
                    isPositive=~isempty(strfind(fieldValue,codeStr));
                end
                causeList=inpMeObj.cause;
                nCauses=length(causeList);
                if checkDepth>0&&nCauses>0
                    for iCause=1:nCauses
                        isPositive=isPositive||getIsCodeMatch(...
                            causeList{iCause},checkDepth-1,...
                            fieldName,codeStr);
                    end
                end
            end
        end
        function resTime=runAndMeasureTime(self,varargin)
            % RUNANDMEASURETIME executes the specified command and displayes
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
            profileMgr=mxberry.dev.prof.ProfileManager(...
                self.PROF_MODE,self.PROF_DIR);
            %
            resTime=profileMgr.runAndProcess(varargin{:});
        end
    end
end