function SData=updateleaves(SData,fUpdateFunc)
% UPDATELEAVES applies the specified function to each structure leave value
% and returns the updated structure
%
% Input:
%   regular:
%       SData: struct[1,1] - input data structure
%       fUpdateFunc: function_handle[1,1] - function with 2 input
%           arguments: field value and field path and 1 output argument -
%           updated field value
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
SData=mxberry.core.struct.updateleavesext(SData,@fUpdateExtFunc);
    function [val,path]=fUpdateExtFunc(val,path)
        val=fUpdateFunc(val,path);
    end
end

