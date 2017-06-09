function isPos=isverlessthen(verStr)
% ISVERLESSTHEN returns true if current java version is less than specified
% one
%
% Input:
%   regular:
%       verStr: char[1,] - version string in format 'x.x' (1.7 for
%       instnace)
%
% Output:
%   isPos: logical[1,1] - true if current version is less than a specified
%   version
%
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
curStr=char(java.lang.System.getProperty('java.version'));
isPos = (sign(getParts(curStr) - getParts(verStr)) * [1;0.1]) < 0;
end
function verVec = getParts(verStr)
verVec = sscanf(verStr, '%d.%d')';
end