% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
function resArray=subreffrontdim(inpArray,curInd)
resArray=inpArray(curInd,:);
newSizeVec=size(inpArray);
newSizeVec(1)=size(resArray,1);
resArray=reshape(inpArray(curInd,:),newSizeVec);