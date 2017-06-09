% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef OwnPathUtils
    properties (Constant,Access=private)
        EXCLUDE_REGEX_PATTERN='TTD|\.git'
        EXCLUDE_DEP='externals';
    end
    methods (Static)
        function [dirList,excludePattern]=getOwnAndDepCodeDirList()
            parentDir=mxberry.io.PathUtils.rmLastPathParts(...
                fileparts(which('s_install')),1);
            %
            dirList={[parentDir,filesep,'products']};
            excludePattern=...
                mxberry.selfmnt.OwnPathUtils.EXCLUDE_REGEX_PATTERN;
        end
        function [dirList,excludePattern]=getOwnCodeDirList()
            [dirList,excludePattern]=...
                mxberry.selfmnt.OwnPathUtils.getOwnAndDepCodeDirList;
            excludePattern=[excludePattern,'|',...
                mxberry.selfmnt.OwnPathUtils.EXCLUDE_DEP];
        end
        %
        function fileList=getFileListByExtensionList(extList)
            import mxberry.selfmnt.OwnPathUtils;
            import mxberry.io.listfilesrecursive;
            extPattern=strcat('\.',...
                mxberry.core.string.catwithsep(extList,'|'));
            %
            [dirList,patternToExclude]=...
                OwnPathUtils.getOwnCodeDirList();
            %
            regexStr=['regex:^(?:(?!(',patternToExclude,')).)*',...
                extPattern,'$'];
            %
            fileList=getFieldListByDirListAndRegex(dirList,regexStr);
        end
        function fileList=getFieldListByExtAndPkgList(pkgNameList,extList)
            import mxberry.selfmnt.OwnPathUtils;
            extPattern=strcat('\.',...
                mxberry.core.string.catwithsep(extList,'|'));
            %
            fPkg2Pattern=@(x)mxberry.core.string.catwithsep(...
                strcat('\+',strsplit(x,'.')),['\',filesep]);
            pkgPattern=mxberry.core.string.catwithsep(...
                cellfun(fPkg2Pattern,pkgNameList,...
                'UniformOutput',false),'|');
            %
            [dirList,patternToExclude]=...
                OwnPathUtils.getOwnCodeDirList();
            %
            regexStr=['regex:^(?!.*(',patternToExclude,')).*(',...
                pkgPattern,').*',extPattern,'$'];
            fileList=getFieldListByDirListAndRegex(dirList,regexStr);
        end
    end
end
%
function fileList=getFieldListByDirListAndRegex(dirList,regexStr)
import mxberry.io.listfilesrecursive;
fileListOfList=cellfun(...
    @(x)listfilesrecursive(x,regexStr,Inf),...
    dirList,'UniformOutput',false);
fileList=vertcat(fileListOfList{:});
end