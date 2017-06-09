function SData=updateleavesext(SData,fUpdateFunc)
% UPDATELEAVESEXT applies the specified function to each
% structure leave value and returns the updated structure, potentially with
% changed field paths
%
% Input:
%   regular:
%       SData: struct[1,1] - input data structure
%       fUpdateFunc: function_handle[1,1] - function with 2 input
%           arguments: field value and field path and 2 output argument -
%           updated field value and updated field path
%
% Output
%   SData: struct[1,1] - updated structure
%
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
%
import mxberry.core.struct.getleavelist;
[pathList,fieldValList]=getleavelist(SData);
SData=struct();
if ~isempty(pathList)
    [fieldValList,pathList]=cellfun(fUpdateFunc,fieldValList,...
        pathList,'UniformOutput',false);
    cellfun(@setSDataField,pathList,fieldValList);
end
    function setSDataField(subFieldNameList,value)
        SData=setfield(SData,subFieldNameList{:},value);
    end
end

