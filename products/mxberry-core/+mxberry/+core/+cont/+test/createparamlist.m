% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
function SParam=createparamlist(mapFactory,formatList,isHashedVec)
import mxberry.core.cont.*;
import mxberry.core.cont.test.*;
%
%
nHashVals=numel(isHashedVec);
%
nFormats=numel(formatList);
argList=cell(nFormats,nHashVals);
markerList=cell(nFormats,nHashVals);
%
for iFormat=1:nFormats
    for iVal=1:nHashVals
        isHashed=isHashedVec(iVal);
        %
        argList{iFormat,iVal}={mapFactory,...
            'storageFormat',formatList{iFormat},...
            'useHashedKeys',isHashed};
        %
        %
        markerList{iFormat,iVal}=[formatList{iFormat},...
            sprintf('_useHashedKeys%d',isHashed)];
    end
end
argList=argList(:).';
markerList=markerList(:).';
defCMat=[markerList;num2cell(argList)];
SParam=struct(defCMat{:});