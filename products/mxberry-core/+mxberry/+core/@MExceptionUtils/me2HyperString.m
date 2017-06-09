function [fullErrMsgStr,errMsgStr,stackTraceStr]=me2HyperString(meObj)
% ME2HYPERSTRING returns a string representation of an MException
%   object
%
% Input:
%   regular:
%     meObj: MException [1,1]
%
% Output:
%   fullErrMsgStr: char[1,] - full error message
%   errMsgStr: char [1,] - error message
%   stackTraceStr: char [1,] - string representation of the stack trace
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
[fullErrMsgStr,errMsgStr,stackTraceStr]=...
    mxberry.core.MExceptionUtils.me2String(meObj,...
    'useHyperlinks',true);