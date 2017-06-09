function isPos=structcheckpath(SInpArr,pathStr)
% STRUCTCHECKPATH for a given path ('a.b.c.d.' or {'a','b','c','d'}
% and a structure array SInpArr returns true, if this path exists
% for all structure array elements on any nesting level.
%
% Usage: isPos=structcheckpath(SInpArr,pathStr)
%
% Input:
%   regular:
%       SInpArr: struct[] - input structure array of arbitrary size
%       pathStr: char[1,]/cell[1,] of char[1,] - path to check
%
% Output:
%   isPos: logical[1,1] - true if the path SInp exists in the structure
%       pathStr
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2011-2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
[~,isPos]=mxberry.core.struct.structgetpath(SInpArr,pathStr,true,true);