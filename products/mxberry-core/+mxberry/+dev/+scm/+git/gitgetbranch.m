% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
function hashStr=gitgetbranch(pathStr)
persistent mp
if isempty(mp)
    mp=containers.Map();
end
if mp.isKey(pathStr)
    hashStr=mp(pathStr);
else
    if nargin==0
        pathStr=fileparts(mfilename('fullpath'));
    end
    [hashStr,StMsg]=mxberry.dev.scm.git.gitcall('rev-parse --abbrev-ref HEAD',...
        pathStr);
    if isempty(StMsg)
        hashStr=strtrim([hashStr{:}]);
    else
        if iscell(hashStr)&&isempty(hashStr)
            error(StMsg);
        elseif strcmp(StMsg.identifier,'GIT:versioningProblem')&&...
                strncmp(hashStr,'fatal: Not a git repository',...
                numel('fatal: Not a git repository'))
            hashStr='unversioned';
        else
            error(StMsg);
        end
    end
    mp(pathStr)=hashStr;
end