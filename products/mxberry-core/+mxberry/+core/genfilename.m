function fileName = genfilename(inpStr)
%GENFILENAME generates a valid file name based on a given string
%
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
%
ILLEGAL_CHARACTER_LIST = { '/', '\n', '\r', '\t', '\f', '`', '?', '*', '\\', '<', '>', '|', '\"', ':' };
illegalCharList=cellfun(@sprintf,ILLEGAL_CHARACTER_LIST,'UniformOutput',false);
isBadCVec=cellfun(@(x)(inpStr==x),illegalCharList,'UniformOutput',false);
isBadMat=vertcat(isBadCVec{:});
isBadVec=any(isBadMat,1);
fileName=inpStr;
fileName(isBadVec)='_';