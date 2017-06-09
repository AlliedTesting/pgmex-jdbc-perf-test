function isPos=ismaintask()
% ISMAINTASK returns true if current current task is not a child task
% launched via Matlab Parallel Toolbox
%
% Usage: isPos=ismaintask()
%
% Input:
%
% Output:
%   isPos: logical[1,1] - true if the current task is a main task and falst
%       otherwise
%
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
%
[~,SProp]=mxberry.pcalc.gettaskname();
isPos=SProp.isMain;