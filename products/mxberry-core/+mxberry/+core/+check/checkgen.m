function checkgen(x,typeSpec,varargin)
% CHECKGEN checks a generic condition provided by typeSpec string in the
% following format: 'isnumeric(x)&&isa(x,'int32')||isscalar(x)' etc
% In case validation fails an exception is thrown
%
% Input:
%   regular:
%       x: anyType[]
%       typeSpec: char[1,]/function_handle - check string in
%           the folowing format: 'isnumeric(x)&&ischar(x)'
%                       OR
%           function_handle[1,1]
%
%   optional:
%       varName: char[1,] - variable name - used optionally instead of
%           variable name determined auotmatically via inputname(1)
%   properties:
%
%       errorTag: char[1,] - tag for MException object thrown
%           in case of error. If not specified
%           '<CALLER_NAME>wrongInput' tag is used
%
%       errorMessage: char[1,] - error message for MException object
%           thrown in case of error. If not specified the message
%           is generated automatically.
%
%       nCallerStackStepsUp: numeric[1,1] - number of steps up in the call
%           stacks for the caller, by which name the full message tag is to
%           be generated, =1 by default
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
%
if isempty(varargin)
    reg=varargin;
    nCallerStackStepsUp=1;
else
    [reg,prop]=mxberry.core.parseparams(varargin,...
        {'nCallerStackStepsUp'});
    if isempty(prop)
        nCallerStackStepsUp=1;
    else
        nCallerStackStepsUp=prop{2};
    end
end
mxberry.core.checkvar(x,typeSpec,reg{:},'nCallerStackStepsUp',...
    1+nCallerStackStepsUp);
