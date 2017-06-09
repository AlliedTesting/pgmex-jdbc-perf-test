function isPositive=isdir(dirName,isJavaBased)
% ISDIR returns true if a specified name corresponds to an existing
% directory
%
% Input:
%   regular:
%       dirName: char[1,] - directory name to check
%
%   optional:
%       isJavaBased: logical[1,1] - if true (default), Java-based
%           implementation is used and Matlab implementation - otherwise.
% Output:
%   isPositive: logical[1,1] - true if the directory exists
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
if nargin<2
    isJavaBased=true;
end
if isJavaBased
    isPositive=mxberry.io.FileUtils.isDirectory(dirName);
else
    isPositive=exist(dirName,'dir')==7;
end