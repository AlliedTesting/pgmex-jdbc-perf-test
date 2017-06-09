function valueArray=createarraybytypeinfo(STypeInfo,sizeVec)
% CREATEARRAYBYTYPEINFO creates an array of STypeInfo structure
%
% Input:
%   regular:
%       STypeInfo: struct[1,1] - structure containing type information
%       sizeVec: double [1,nDims] - size of the array to be created
%
%
% Output:
%   valueArray: requested type of size specified by sizeVec parameter
%
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
%
import mxberry.core.throwerror;
import mxberry.core.repmat;
if isempty(STypeInfo.type)
    throwerror('wrongInput','type field cannot be empty');
end
%
if numel(sizeVec)==1
    if sizeVec(1)==0
        sizeVec=[0 0];
    else
        sizeVec=[sizeVec,1];
    end
end
if STypeInfo.depth==0
    valueArray=mxberry.core.type.createarray(STypeInfo.type,sizeVec);
else
    nestedType=STypeInfo.type;
    valueArray=repmat(createnestedcell(STypeInfo.depth),...
        sizeVec);
end
%
    function valueArray=createnestedcell(depth)
        if depth>0
            valueArray={createnestedcell(depth-1)};
        else
            valueArray=mxberry.core.type.createarray(nestedType,[0 0]);
        end
    end
end