% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef MatlabPathMgr
    methods (Static)
        function setUp(rootDirList)
            if ischar(rootDirList)
                rootDirList={rootDirList};
            end
            disp('Setting MatrixBerry path...');
            [~,pathPatternToExclude]=...
                mxberry.selfmnt.OwnPathUtils.getOwnAndDepCodeDirList();
            if ~isempty(pathPatternToExclude)
                pathPatternToExclude=[pathPatternToExclude,...
                    '|((\\|\/)(\@|\+|private))'];
            end
            pathList=...
                mxberry.io.PathUtils.genPathByRootList(rootDirList,...
                pathPatternToExclude);
            warning('off','MATLAB:lang:cannotClearExecutingFunction');
            restoredefaultpath;
            warning('on','MATLAB:lang:cannotClearExecutingFunction');
            addpath(pathList{:});
            disp('Setting MatrixBerry path: done.'); 
        end        
    end
end

