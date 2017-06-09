% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef EntityFactory
    methods (Static)
        function resArr=create(valMat,varargin)
            import mxberry.core.parseparext;
            [reg,~,isUniqueIsMemberChecked]=parseparext(varargin,...
                {'checkUniqueIsMember';true},[0 1],'regDefList',{true});
            %
            isSortable=reg{1};
            %
            if isUniqueIsMemberChecked
                if isSortable
                    fCreate=@mxberry.core.test.aux.SortableEntityRedirected;
                else
                    fCreate=@mxberry.core.test.aux.CompEntityRedirected;
                end
            else
                if isSortable
                    fCreate=@mxberry.core.test.aux.SortableEntity;
                else
                    fCreate=@mxberry.core.test.aux.CompEntity;
                end
            end
            %
            nElems=numel(valMat);
            sizeVec=size(valMat);
            resCArr=cell(sizeVec);
            for iElem=nElems:-1:1
                resCArr{iElem}=fCreate(valMat(iElem));
            end
            resArr=reshape([resCArr{:}],sizeVec);
        end
    end
end