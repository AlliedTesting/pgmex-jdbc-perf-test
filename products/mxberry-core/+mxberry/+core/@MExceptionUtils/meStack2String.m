function stackTraceStr = meStack2String(StackVec,varargin)
% MESTACK2STRING returns a string representation of a call
%   stack represented by a structure array in a formatt retured
%   by dbstack and used by MException.
%
% Input:
%   regular:
%     stackTrace: struct [n,1] - structure array returned by dbstack
%   properties:
%     useHyperlinks: logical [1,1] - print hyperlinks suitable for Matlab
%       screen output. Default = true.
%     prefixStr: char [1,n] - prefix to put at the beginning of each line
%       of the stack trace. Default = ''.
% Output:
%   stackTraceStr: char [m,n] - string representation of the stack trace
%
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
mxberry.core.check.checkgen(StackVec,@(x)isstruct(x)&&iscolumn(x));
areHyperlinksUsed = true;
prefixStr = sprintf('');
[~,propList]=parseparams(varargin);
nProps=length(propList);
for iProp=1:2:nProps
    switch lower(propList{iProp})
        case 'usehyperlinks'
            areHyperlinksUsed=propList{iProp+1};
        case 'prefixstr'
            prefixStr=propList{iProp+1};
        otherwise
            mxberry.core.throwerror('wrongInput',...
                'unknown property %s',propList{iProp});
    end
end
%
nLevels=numel(StackVec);
%
stackTraceStrList =cell(1,nLevels);
for iLevel = 1:nLevels
    %to prevent problems with sprintf treating "\" as escape symbol
    fileName=strrep(StackVec(iLevel).file,'\','/');
    %
    linktext=sprintf('in %s at line %d',fileName,StackVec(iLevel).line);
    if areHyperlinksUsed
        stackTraceStrList{iLevel}=[prefixStr, ...
            ['<a href="error:' fileName ','...
            num2str(StackVec(iLevel).line) ',' 1, '">' linktext '</a>']];
    else
        stackTraceStrList{iLevel}=[prefixStr, linktext];
    end
end
stackTraceStr=mxberry.core.string.catwithsep(stackTraceStrList,...
    sprintf('\n'));
end