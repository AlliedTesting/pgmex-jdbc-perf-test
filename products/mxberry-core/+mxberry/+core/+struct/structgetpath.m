function [SRes,isThere]=structgetpath(SInpArr,pathStr,isPresenceChecked,...
    isJustCheck)
% STRUCTGETPATH extract a value from a given structure array using a path
% specified either as a string or as a sequence of field names separated
% by dots. It is assumed that all values located at the specified path
% are of the same size.
%
% Usage:
%   SRes=structgetpath(SInpArr,pathStr)
%   SRes=structgetpath(SInpArr,pathStr,false)
%
% Input:
%   regular:
%       SInpArr: struct[] - input struct array
%       pathStr: char[1,]/cell[1,] of char[1,] - path in the SInp
%       isPresenceChecked: logical[1,1] - if true, the function doesn't
%           throw an exception if the path is not found and returns
%           isThere=false instead.
%               Default value is FALSE.
%       isJustCheck: logical[1,1] - if true, no value is extracted, just a
%           presence of the specified path is checked. When
%           isJustCheck=true isPresenceChecked is automatically set to true
%               Default value is FALSE.
%
%   Note: when isJustCheck=true the function is more prohibitive as it
%       doesn't check for consistency of sizes for values of different
%       structure array elements. However, when isJustCheck=false the
%       function attempts to extract values concatenating them via cell2mat
%       function. This may result into either a failure
%       (isPresenceChecked=false) or isThere=false when
%       (isPresenceChecked=true) even if with isJustCheck=true the function
%       returned isThere=true.
%
% Output:
%   SRes: struct[] - struct array of the same size as SInpArr
%   isThere: logical[1,1] - if false, the specified path is not found in
%       SInpArr
%
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2011-2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
%
import mxberry.core.throwerror;
import mxberry.core.check.lib.iscellofstring;
import mxberry.core.check.lib.isstring;
if ~isstruct(SInpArr)
    throwerror('wrongInpt','SInpArr is expected to be a structure');
end
%
if ~(isstring(pathStr)||ischar(pathStr)&&isempty(pathStr)||...
        iscellofstring(pathStr))
    throwerror('wrongInpt',['pathStr is expected to be ',...
        'either a string or a list of strings']);
end
if nargin<4
    isJustCheck=false;
    if nargin<3
        isPresenceChecked=false;
    elseif ~(islogical(isPresenceChecked)&&isscalar(isPresenceChecked))
        throwerror('wrongInpt',...
            'isPresenceChecked is expected to be a logical scalar');
    end
elseif ~(islogical(isJustCheck)&&isscalar(isJustCheck))
    throwerror('wrongInpt',...
        'isJustCheck is expected to be a logical scalar');
end
SRes=struct.empty(0,0);
%
if isJustCheck
    isPresenceChecked=true;
end
%
if isempty(pathStr)
    if ~isJustCheck
        SRes=SInpArr;
    end
    isThere=true;
else
    if ischar(pathStr)
        fieldNameList=regexp(pathStr,'([^\.]*)','match');
    else
        fieldNameList=pathStr;
    end
    %
    firstField=fieldNameList{1};
    %
    if isscalar(SInpArr)
        [SResArr,isThere]=getField(SInpArr,firstField,...
            isPresenceChecked);
        %
        if isThere
            if length(fieldNameList)>1
                [SRes,isThere]=mxberry.core.struct.structgetpath(SResArr,...
                    fieldNameList(2:end),isPresenceChecked,isJustCheck);
            else
                SRes=SResArr;
            end
        end
    else
        [SResCArr,isThereCArr]=arrayfun(...
            @(x)getField(x,firstField,isPresenceChecked),...
            SInpArr,'UniformOutput',false);
        isThere=all([isThereCArr{:}]);
        %
        if isThere
            if isJustCheck
                if length(fieldNameList)>1
                    [~,isThereArr]=cellfun(...
                        @(x)mxberry.core.struct.structgetpath(x,...
                        fieldNameList(2:end),isPresenceChecked,isJustCheck),...
                        SResCArr,'UniformOutput',false);
                    isThere=all([isThereArr{:}]);
                end
            else
                try
                    SResArr=cell2mat(SResCArr);
                catch meObj
                    if isPresenceChecked
                        isThere=false;
                    else
                        rethrow(meObj);
                    end
                end
                if isThere
                    if length(fieldNameList)>1
                        [SRes,isThere]=...
                            mxberry.core.struct.structgetpath(SResArr,...
                            fieldNameList(2:end),isPresenceChecked,...
                            isJustCheck);
                    else
                        SRes=SResArr;
                    end
                end
            end
        end
    end
end
end
function [SRes,isThere]=getField(SInpArr,fieldName,isPresenceChecked)
if isPresenceChecked
    if isfield(SInpArr,fieldName)
        isThere=true;
        SRes=SInpArr.(fieldName);
    else
        isThere=false;
        SRes=struct.empty(0,0);
    end
else
    SRes=SInpArr.(fieldName);
    isThere=true;
end
end