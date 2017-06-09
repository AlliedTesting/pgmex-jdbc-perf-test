% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
function isPos=issvn(pathStr)
if nargin==0
    pathStr=fileparts(mfilename('fullpath'));
end
svnVersionStr=mxberry.dev.scm.subversion.getrevisionbypath(...
    pathStr,'ignoreErrors',true);
isPos=isempty(regexpi(svnVersionStr,'unversioned|exported'));