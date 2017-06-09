function valueMat=createarraybytypesizeinfo(STypeSizeInfoInp)
% CREATEARRAYBYTYPESIZEINFO generates an array based on TYPESIZEINFO
% structure
%
% Input:
%   regular:
%       STypeSizeInfo: struct[1,1]
%
% Output
%   valueMat []
%
% Example:
%   valueMat=createarraybytypesizeinfo(STypeSizeInfoInp,'createIsNull',[true false])
%
% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
valueMat=createarraybytypesizeinfo_int(STypeSizeInfoInp);

    function [valueMat,isCellStr]=createarraybytypesizeinfo_int(STypeSizeInfo)
        %
        isCellStr=false;
        %
        if STypeSizeInfo.isCell
            if ~isempty(STypeSizeInfo.itemTypeInfo)
                [valueMat,isCellStrCMat]=arrayfun(@createarraybytypesizeinfo_int,...
                    STypeSizeInfo.itemTypeInfo,...
                    'UniformOutput',false);
                %decrease nesting of value array level by 1 for cell strs
                if prod(STypeSizeInfo.sizeVec)==0
                    valueMat=reshape(valueMat([]),STypeSizeInfo.sizeVec);
                end
                isCellStrCMat=cell2mat(isCellStrCMat);
                if all(isCellStrCMat(:))
                    valueMat=cell2mat(valueMat);
                end
            else
                valueMat=cell(STypeSizeInfo.sizeVec);
            end
        else
            %
            valueMat=mxberry.core.createarray(STypeSizeInfo.type,STypeSizeInfo.sizeVec);
            %
        end
    end
end