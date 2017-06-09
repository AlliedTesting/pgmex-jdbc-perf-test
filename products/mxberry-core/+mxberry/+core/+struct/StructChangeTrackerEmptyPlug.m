% STRUCTCHANGETRACKEREMPTYPLUG is an empty impementation of
%   ASTRUCTCHANGETRACKER interface
% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef StructChangeTrackerEmptyPlug<mxberry.core.struct.AStructChangeTracker
    methods
        function self=StructChangeTrackerEmptyPlug()
        end
        function SInput=applyPatches(~,SInput,~,~,~)
        end
        function [SInput,confVersion]=applyAllLaterPatches(~,SInput,...
                confVersion)
        end
        function lastRev=getLastRevision(~)
            lastRev=-Inf;
        end
    end
end
