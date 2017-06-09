function [urlTypeMarkerStr,urlStr,branchName,revisionStr]=...
    getrepoparams(repoDir)
% GETREPOPARAMS returns generic parameters of SCM repository (currently
% only git and subversion repositories are supported
%
% Input:
%   optional:
%       repoDir: char[1,] - an arbitrary sub-folder within a repository
%           if not specified the path if determined automatically based on
%           location of the function
% Output:
%   urlType: char[1,] - repository URL marker (svnURL or gitURL)
%   urlStr: char[1,] - URL itself
%   branchName: char[1,] - current branch name
%   revisionStr: char[1,] - current revision
%
% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
import mxberry.core.throwerror;
if nargin==0
    callerPath=mfilename('fullpath');
    if isempty(callerPath)%command line
        repoDir=cd();
    else
        repoDir=fileparts(callerPath);
    end
end
urlTypeMarkerStr='';
try
    isSvn=mxberry.dev.scm.subversion.issvn(repoDir);
    if isSvn
        isGit=false;
        urlTypeMarkerStr='svnURL';
        urlStr=mxberry.dev.scm.subversion.svngeturl(repoDir);
    else
        isGit=mxberry.dev.scm.git.isgit(repoDir);
        if isGit
            urlTypeMarkerStr='gitURL';
            urlStr=mxberry.dev.scm.git.gitgeturl(repoDir);
        else
            throwerror('wrongObjState',...
                'Files with code should be under either SVN or Git');
        end
    end
catch
    isSvn=false;
    isGit=false;
    urlTypeMarkerStr='unknownURL';
    urlStr='unknown';
end
if isSvn
    revisionStr=mxberry.dev.scm.subversion.getrevision('ignoreErrors',...
        true);
    branchName='unknown';
elseif isGit
    revisionStr=mxberry.dev.scm.git.gitgethash(repoDir);
    branchName=mxberry.dev.scm.git.gitgetbranch(repoDir);
else
    revisionStr='unversioned';
    branchName='unknown';
end
end