function throwwarn(msgTag,varargin)
% THROWWARN works similarly to built-in WARNING function in case
% when there is no output arguments but simpler to use
% as it automatically generates tags based on caller name
% When output argument is specified an exception object is returned instead
%
% Input:
%   regular:
%       msgTag: char[1,] error tag suffix which is complemented by
%           automatically generated part
%       ...
%       same inputs as in error function
%       ...
%
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
import mxberry.core.getcallername;
callerName=getcallername(2,'full');
callerName=strrep(callerName,'.',':');
warnId=[upper(callerName),':',msgTag];
warning(warnId,varargin{:});