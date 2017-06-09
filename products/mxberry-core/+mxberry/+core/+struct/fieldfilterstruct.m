function ResStruct=fieldfilterstruct(InpStruct,field2KeepList,isCheckField)
% FIELDFILTERSTRUCT leaves in input structure array only specified
% fields
%
% Usage: ResStruct=fieldfilterstruct(InpStruct,field2KeepList)
%
% input:
%   regular:
%       mandatory:
%           inpStruct: struct[multydimensional] - struct array;
%           field2KeepList: cell[1,nFields] - names of fields to leave;
%       optional:
%           isCheckField: logical[1] - if it is true all names from
%                   field2KeepList have to be names of fields from
%                   InpStruct or function displays error message;
%                   by default false;
% output:
%   regular:
%      ResStruct: struct[multydimensional] - struct array of the same size
%               as inpStruct;
%
% Example:  ResStruct=fieldfilterstruct(InpStruct,{'a','b'})
%
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
import mxberry.core.throwerror;
if nargin<3
    isCheckField=false;
end
if isempty(field2KeepList)
    ResStruct=InpStruct;
    return;
end
%
if ischar(field2KeepList)
    field2KeepList={field2KeepList};
end

initFieldList=fieldnames(InpStruct);
fieldList=setdiff(initFieldList,field2KeepList);
ResStruct=rmfield(InpStruct,fieldList);

if isCheckField
    isExist=ismember(field2KeepList,initFieldList);
    if ~all(isExist(:))
        indBad=find(~isExist,1,'first');
        throwerror('wrongFieldName',...
            'InpStruct does not contain %s field', field2KeepList{indBad});
    end
end