% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
function urlStr=gitgeturl(WorkingCopy)
urlStrList=mxberry.dev.scm.git.gitcall('ls-remote --get-url',WorkingCopy);
urlStr=[urlStrList{:}];
urlStr=strtrim(urlStr);