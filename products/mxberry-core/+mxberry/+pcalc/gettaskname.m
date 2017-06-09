function [taskName,SProp]=gettaskname()
% GETTASKNAME returns task name and some additional properties
%
% Usage: [taskName,SProp]=gettaskname()
%
% Input:
%
% Output:
%   taskName: char[1,] - name of the current task
%   SProp: struct[1,1] - properties structure with the following fields:
%       isMain: logical[1,1] - true if current process is main, false if child
%       taskId: numerical[1,1] - number of child task
%       taskName: char[1,] - same as above
%
%
% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
%
[isParTbxInstalled,isAltPartTbxInstalled]=...
    mxberry.pcalc.isparttbxinst();
%
if isParTbxInstalled
    %
    [taskName,SProp]=mxberry.pcalc.gettasknamepcomp();
    %        
elseif isAltPartTbxInstalled
    %
    [taskName,SProp]=mxberry.pcalcalt.gettaskname();
    %    
else
    taskName='master';
    SProp.isMain=true;
    SProp.taskId='';
    SProp.taskName=taskName;
end