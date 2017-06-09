% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
function [userName,hostName]=getuserhost()
persistent hostNameCached userNameCached
if nargout>1
    if isempty(hostNameCached)
        [~,~,hostNameCached]=mxberry.system.getpidhost();
    end
    hostName=hostNameCached;
end
if isempty(userNameCached)
    userNameCached=char(java.lang.System.getProperty('user.name'));
end
userName=userNameCached;