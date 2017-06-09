function [isPositive,isPosElemArr]=iscellnumeric(valueArr)
% ISCELLNUMERIC returns true for a cell arrays consisting of numeric
% elements only
%
% Input:
%   regular:
%       valueArr: any[nDim1,...,nDimK] - arbitrary array, might not be a
%           cell array
%
% Output:
%   isPositive: logical[1,1] - if true, valueArr is composed of numeric
%       elements only
%   isPosElemArr: logicla[nDim1,...,nDimK] - contains true values for those
%       elements that correspond to numeric elements in valueArr array
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2014-2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
if iscell(valueArr)
    if isempty(valueArr)
        isPositive=false;
        if nargout>1
            isPosElemArr=logical.empty(size(valueArr));
        end
    else
        isPosElemArr=cellfun('isclass',valueArr,'double')|...
            cellfun('isclass',valueArr,'int32')|...
            cellfun('isclass',valueArr,'int64')|...
            cellfun('isclass',valueArr,'int16')|...
            cellfun('isclass',valueArr,'int8')|...
            cellfun('isclass',valueArr,'uint32')|...
            cellfun('isclass',valueArr,'uint64')|...
            cellfun('isclass',valueArr,'uint16')|...
            cellfun('isclass',valueArr,'uint8')|...
            cellfun('isclass',valueArr,'single');
        %
        isPositive=all(isPosElemArr(:));
    end
else
    isPositive=false;
    if nargout>1
        isPosElemArr=false(size(valueArr));
    end
end