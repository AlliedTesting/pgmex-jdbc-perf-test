% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef MExceptionUtils
    methods (Static)
        [fullErrMsgStr,errMsgStr,stackTraceStr]=me2PlainString(meObj)
        [fullErrMsgStr,errMsgStr,stackTraceStr]=me2HyperString(meObj)
        [fullErrMsgStr,errMsgStr,stackTraceStr]=me2String(meObj,varargin)
        %
        varargout=me2ErrStackStrings(meObj,varargin)
        %
        stackTraceStr = meStack2PlainString(StackVec,varargin)
        stackTraceStr = meStack2HyperString(StackVec,varargin)
        stackTraceStr = meStack2String(StackVec,varargin)
    end
    %
    methods (Access=private,Static)
        %
        function [errStr, stackStr] = parseMeErrorMessage(meObj,varargin)
            %
            errStr=['message:[',meObj.message '], identifier:[',meObj.identifier,']'];
            %
            if nargout>1
                REF_AS_ERR_MSG_REG_EXP=['Error: <a.*opentoline\(''(.*)'',\d+,\d+\).*',...
                    'File:\ ([\w\ \.,$&/\\:@]*.m)\ Line: (\w*)\ Column: (\w*)\s*</a>\n*(.*)'];
                StackVec=meObj.stack;
                %
                tokens = regexp(errStr,REF_AS_ERR_MSG_REG_EXP,'tokens','once');
                if ~isempty(tokens)
                    fullFileName=tokens{1};
                    shortFileName=tokens{2};
                    lineNumber=tokens{3};
                    errStr=tokens{5};
                    StackEntry=struct('file',fullFileName,'name',shortFileName,...
                        'line',str2double(lineNumber));
                    StackVec=[StackEntry;StackVec];
                else
                    [tokens] = regexp(errStr,...
                        'Error using ==> <a href.*>(.*)</a>\n(.*)', 'tokens', 'once');
                    if (length(tokens) == 2)
                        errStr = char(tokens(2));
                    end
                end
                stackStr=mxberry.core.MExceptionUtils.meStack2String(...
                    StackVec,varargin{:});
            end
        end
    end
end