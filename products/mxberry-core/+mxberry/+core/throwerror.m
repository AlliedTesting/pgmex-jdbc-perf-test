function meObj=throwerror(msgTag,varargin)
% THROWERROR works similarly to built-in ERROR function in case
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
%   properties:
%       nCallerStackStepsUp: numeric[1,1] - number of steps up in the call
%           stacks for the caller, by which name the full message tag is to
%           be generated, =1 by default
%
% Output:
%   optional: meObj: MException[1,1]
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
import mxberry.core.getcallername;
import mxberry.core.parseparext;
[reg,~,nCallerStackStepsUp]=parseparext(varargin,...
    {'nCallerStackStepsUp';1},'propRetMode','separate');
callerName=getcallername(1+nCallerStackStepsUp,'full');
callerName=strrep(callerName,'.',':');

meObj=MException([upper(callerName),':',msgTag],reg{:});
if nargout==0
    throwAsCaller(meObj);
end
