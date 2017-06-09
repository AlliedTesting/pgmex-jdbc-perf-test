% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef StaticPropStorage<mxberry.core.obj.StaticPropStorage
    methods (Static)
        function [propVal,isThere]=getProp(propName,varargin)
            branchName=mfilename('class');
            [propVal,isThere]=mxberry.core.obj.StaticPropStorage.getPropInternal(...
                branchName,propName,varargin{:});
        end
        function setProp(propName,propVal)
            branchName=mfilename('class');
            mxberry.core.obj.StaticPropStorage.setPropInternal(...
                branchName,propName,propVal);
        end
        function flush()
            branchName=mfilename('class');
            mxberry.core.obj.StaticPropStorage.flushInternal(branchName);
        end
    end
end
