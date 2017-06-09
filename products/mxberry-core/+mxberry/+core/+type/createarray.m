function valueArray=createarray(className,sizeVec)
% CREATEARRAY creates an array of specified size and type filling it with
% some values
%
% Input:
%   regular:
%       className: char[1,] - class name for a target array
%       sizeVec: numeric[1,] - size for a target array
%
% Output:
%   valueArray className[] - resulting array of size sizeVec
%
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
%
persistent numericTypeList;
if ~ischar(className)
    mxberry.core.throwerror('wrongInput',...
        'className is expected to be a string');
end
%
if ~(isnumeric(sizeVec)&&(mxberry.core.isrow(sizeVec)||isempty(sizeVec)))
    mxberry.core.throwerror('wrongInput',...
        'sizeVec is expected to a numeric row-vector');
end
%
if isempty(numericTypeList)
    numericTypeList={'int8','int16','int32','int64','double','logical','single',...
        'uint8','uint16','uint32','uint64','char'};
end
%
nElem=prod(sizeVec);
isNumeric=false;
for iType=1:numel(numericTypeList)
    isNumeric=strcmp(numericTypeList{iType},className);
    if isNumeric
        break
    end
end
%
if isNumeric
    if isempty(sizeVec)
        valueArray=feval(className,[]);
    else
        valueArray=feval(className,zeros(sizeVec));
    end
else
    if isempty(sizeVec)
        valueArray=feval([className,'.empty'],[0 0]);
    elseif nElem==0
        valueArray=feval([className,'.empty'],sizeVec);
    else
        enumMemberList=meta.class.fromName(className).EnumerationMemberList;
        if isempty(enumMemberList)
            valueArray=mxberry.core.type.createvaluearray(className,...
                feval(className),sizeVec);
        else
            scalarEnumVal=eval([className,'.',enumMemberList(1).Name]);
            valueArray=repmat(scalarEnumVal,sizeVec);
        end
    end
end