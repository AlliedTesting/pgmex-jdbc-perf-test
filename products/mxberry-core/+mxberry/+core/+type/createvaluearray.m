function valueArray=createvaluearray(className,value,sizeVec)
% CREATEVALUEARRAY is designed for creating arrays of a specified type and
% size filled with a specified value
%
% Input:
%   regular:
%       className: char[1,] - class of an array to create
%       value: [1,1,...,n1_n2,...,n_k] - value having the singular
%          dimensionality along the first s dimensions where s is a length of
%          sizeVec parameter
%       sizeVec: numeric[1,] - size along the first s dimensions for the
%          target array
%
% Output:
%   valueArray: className[m_1,..,m_s,n_1,...,n_k] where sizeVec=[m_1,...,m_s]
%
%
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
%
if numel(value)~=1
    mxberry.core.throwerror('wrongInput',...
        'only scalar value is expected');
end
%
isHandle=isa(value,'handle');
if isHandle||~isa(value,className)
    value=feval(className,value);
end
%
nElem=prod(sizeVec);
if nElem==0
    valueArray=feval([className,'.empty'],sizeVec);
    return;
end
%
if isHandle
    valueArray(nElem)=value;
    if nElem>1
        for iElem=1:nElem-1
            valueArray(iElem)=feval(className,value);
        end
        valueArray=reshape(valueArray,sizeVec);
    end
else
    valueArray=repmat(value,sizeVec);
end