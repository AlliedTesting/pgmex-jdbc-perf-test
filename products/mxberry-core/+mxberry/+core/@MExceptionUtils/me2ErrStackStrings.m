function varargout=me2ErrStackStrings(meObj,varargin)
% ME2ERRSTACKSTRING returns a string representation of an MException
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
%   errMsgStr: char [1,] - error message
%   stackTraceStr: char [1,] - string representation of the stack trace
%
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
if nargout>1
    isStackTraceRequested=true;
    argOutList=cell(1,2);
    parseMsgOutList=cell(1,2);
else
    argOutList={};
    parseMsgOutList={};
end
%
[parseMsgOutList{:}]=...
    mxberry.core.MExceptionUtils.parseMeErrorMessage(meObj,...
    varargin{:});
%
nCause=length(meObj.cause);
%
for iCause=1:nCause
    [argOutList{:}]=...
        mxberry.core.MExceptionUtils.me2ErrStackStrings(...
        meObj.cause{iCause},varargin{:});
    %
    parseMsgOutList{1}=[parseMsgOutList{1},...
        sprintf('\n\tCause(%d): %s',iCause,argOutList{1})];
end
if isStackTraceRequested
    for iCause=1:nCause
        %
        parseMsgOutList{2}=[parseMsgOutList{2},...
            sprintf('\n\tCause(%d): %s',iCause,argOutList{2})];
    end
end
varargout=parseMsgOutList;
end