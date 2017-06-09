function [fullErrMsgStr,errMsgStr,stackTraceStr]=me2String(meObj,varargin)
% ME2STRING returns a string representation of an MException
%   object
%
% Input:
%   regular:
%     meObj: MException [1,1]
%
%   properties:
%       useHyperlink: logical [1,1] - if true - use hyperlinks
%           suitable for displaying in Matlab console.
%               Default=true.
%
%       prefixStr: char [1,] - a prefix to print at the
%           beginning of each line of the stack trace.
%               Default = ''.
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
[errMsgStr,stackTraceStr]=...
    mxberry.core.MExceptionUtils.me2ErrStackStrings(...
    meObj,varargin{:});
%
stackTraceStr = sprintf('%s\n', stackTraceStr);
fullErrMsgStr=sprintf('Traceback (most recent call first): %s\nError: %s',...
    stackTraceStr,errMsgStr);
end