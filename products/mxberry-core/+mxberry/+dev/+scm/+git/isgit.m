% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
function res=isgit(pathStr)
persistent mp
if isempty(mp)
    mp=containers.Map();
end
if mp.isKey(pathStr)
    res=mp(pathStr);
else
    if nargin==0
        pathStr=fileparts(mfilename('fullpath'));
    end
    res=~strcmp(mxberry.dev.scm.git.gitgethash(pathStr),'unversioned');
    mp(pathStr)=res;
end
end