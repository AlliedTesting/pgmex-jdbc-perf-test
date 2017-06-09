function stackTraceStr=meStack2HyperString(StackVec)
% MESTACK2HYPERSTRING returns a string representation of an MException
%   object
%
% Input:
%   regular:
%     StackVec: struct[1,1] - stack trace vector
%
% Output:
%   stackTraceStr: char [1,] - string representation of the stack trace
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
stackTraceStr=...
    mxberry.core.MExceptionUtils.meStack2String(StackVec,...
    'useHyperlinks',true);
