function [pidHostStr,pidVal,hostName]=getpidhost()
%GETPIDHOST returns process id (PID) of current Matlab instance along with
%a host name it is running on
%
% Output:
%   pidHostStr: char[1,] - pid/host string in pid@host format
%   pid: double[1,1] - pid of current Matlab instance
%   hostName: char[1,] - host name
%
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
%
mxBeanObj=java.lang.management.ManagementFactory.getRuntimeMXBean();
pidHostStr=char(mxBeanObj.getName());
if nargout>1
    resCell=strsplit(pidHostStr,'@');
    pidVal=str2double(resCell{1});
    hostName=resCell{2};
end