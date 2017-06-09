function resStr=cellstr2colstr(inpCArr,indentStr)
% CELLSTR2COLSTR transforms a cell array of strings into a row string that
% looks like a column when displayed
%
% Input:
%   regular:
%       inpCArr: cell[] of char[1,] - input array of strings
%   optional:
%       indentStr: char[1,] - an indent applied to each of the strings in
%          the input array
%           Default: '' i.e. no indent
%
% Output:
%   resStr: char[1,] - resulting string
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
newLineSep=sprintf('\n');
if nargin>1
    inpCArr=strcat({indentStr}, inpCArr,{newLineSep});
else
    inpCArr=strcat({indentStr}, inpCArr);
end
%
resStr=[inpCArr{:}];
resStr=resStr(1:(end-length(newLineSep)));