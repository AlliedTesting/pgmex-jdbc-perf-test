function outStr = catwithsep(inpStrList,sepStr)
% CATWITHSEP concatenates input cell array of strings inserting a specified
% separator between the strings
%
% Input:
%   regular:
%       inpStrList: cell[] of char[1,] - cell array of strings
%       sepStr: char[1,] - separator
%
% Output:
%   outStr: char[1,] - resulting string
%
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
%
outStr='';
nElems=numel(inpStrList);
for iElem=1:nElems
    outStr=horzcat(outStr, inpStrList{iElem}, sepStr); %#ok<AGROW>
end
nSepSymb=length(sepStr);
outStr=outStr(1:(end-nSepSymb));