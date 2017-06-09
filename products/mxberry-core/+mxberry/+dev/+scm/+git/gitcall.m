% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
function [gitMsgLineList, varargout]=gitcall(ParamStr,pathStr)
isPath=nargin>1;

SMsg=struct([]);
% call git with the given parameter string
if isPath
    curDirStr=pwd();
    cd(pathStr);
end
gitDirStr=pwd();
callStr=sprintf('git %s',ParamStr);
if isunix
    callStr=['TERM=ansi ',callStr];
end
%
[gitErr,gitMsg]=system(callStr);
if isPath
    cd(curDirStr);
end

% create cellstring with one row per line
gitMsgLineList=strsplit(gitMsg,sprintf('\r\n'));
%
% check for an error reported by the operating system
if gitErr~=0
    % an error is reported
    if isempty(gitMsgLineList)
        SMsg(1).identifier='GIT:versioningProblem';
        SMsg(1).message=['Problem using version control system:' 10 ...
            ' Git could not be executed! Error code is ' ...
            num2str(gitErr) 10 ' Path is ' gitDirStr];
    elseif strncmp('''git',gitMsgLineList{1},4)
        SMsg(1).identifier='GIT:installationProblem';
        SMsg(1).message=['Problem using version control system:' 10 ...
            ' Git could not be executed!' 10 'Path is ' gitDirStr];
    else
        SMsg(1).identifier='GIT:versioningProblem';
        SMsg(1).message=['Problem using version control system:' 10 ...
            mxberry.core.cell.cellstr2colstr(gitMsgLineList,' ') 10 ' Path is ' gitDirStr];
    end
elseif ~isempty(gitMsgLineList)
    if strncmp('git:',gitMsgLineList{1},4)
        SMsg(1).identifier='GIT:versioningProblem';
        SMsg(1).message=['Problem using version control system:' 10 ...
            mxberry.core.cell.cellstr2colstr(gitMsgLineList,' ') 10 ...
            ' Path is ' gitDirStr];
    end
end

if nargout>1
    varargout{1}=SMsg;
else
    error(SMsg);
end