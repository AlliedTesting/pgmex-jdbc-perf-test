function URL=svngeturl(WorkingCopy)
% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$

% call subversion with the given parameter string to get a list of all
% properties
ParamStr=sprintf('info "%s"',WorkingCopy);
svnMsg=mxberry.dev.scm.subversion.svncall(ParamStr);

URL_Idx=strfind(svnMsg,'URL:');
if isempty(URL_Idx)
    error('SVN:versioningProblem', '%s',...
        ['Problem using version control system - no URL found:' 10 ...
        ' ' [svnMsg{:}]])
end
URL=svnMsg{URL_Idx}(6:end);
