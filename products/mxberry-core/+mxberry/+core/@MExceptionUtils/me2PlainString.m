function [fullErrMsgStr,errMsgStr,stackTraceStr]=me2PlainString(meObj)% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
[fullErrMsgStr,errMsgStr,stackTraceStr]=...
    mxberry.core.MExceptionUtils.me2String(meObj,...
    'useHyperlinks',false);
