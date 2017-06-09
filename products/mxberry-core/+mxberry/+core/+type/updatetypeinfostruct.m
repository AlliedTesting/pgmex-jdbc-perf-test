% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
function STypeInfo = updatetypeinfostruct(SOldTypeInfo)
if  ~isfield(SOldTypeInfo,'itemTypeInfo')
    %nothing to update
    STypeInfo=SOldTypeInfo;
else
    
    maxDepth=nan;
    bottomType='';
    %
    if isfield(SOldTypeInfo,'isNested')
        getbottomtype_v1(SOldTypeInfo,0);
    elseif isfield(SOldTypeInfo,'isCell')
        getbottomtype_v2(SOldTypeInfo,0);
    else
        mxberry.core.throwerror('wrongInput',...
            'unknown format of STypeInfo');
    end
    %
    STypeInfo=struct('type',bottomType,'depth',maxDepth);
end
%
    function getbottomtype_v1(STypeInfo,level)
        if STypeInfo.isNested
            getbottomtype_v1(STypeInfo.itemTypeInfo,level+1)
        else
            maxDepth=level;
            bottomType=STypeInfo.type;
        end
    end
    function getbottomtype_v2(STypeInfo,level)
        if STypeInfo.isCell
            getbottomtype_v2(STypeInfo.itemTypeInfo,level+1)
        else
            maxDepth=level;
            bottomType=STypeInfo.type;
        end
    end
end