% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef JavaStaticPathMgr<mxberry.java.AJavaStaticPathMgr
    methods
        function self=JavaStaticPathMgr(varargin)
            self=self@mxberry.java.AJavaStaticPathMgr(varargin{:});
        end
        function fileNameList=getJarFileNameList(~)
            fileNameList={'mxberryfileutils.jar'};
        end
    end
    methods (Access=protected)
        function pathClassCMat=getRelativePathListToJars(~)
            pathClassCMat={'jmxberry\FileUtils\bin',mfilename('class'),0};
        end
    end
end