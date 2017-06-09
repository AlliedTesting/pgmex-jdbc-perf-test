% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef mlunit_test_nostorage < mxberry.unittest.TestCase
    properties (SetAccess=private,GetAccess=public)
        map
    end
    %
    methods
        function self = mlunit_test_nostorage(varargin)
            self = self@mxberry.unittest.TestCase(varargin{:});
        end
    end
    methods (TestMethodSetup)
        %
        function self = setUp(self)
            self.map=mxberry.core.cont.ondisk.HashMapXMLMetaData(...
                'storageFormat','none');
            self.map.removeAll();
        end
    end
    methods (Test)
        function self=test_putGetWithMetaData(self)
            rel1=struct('a',1,'b',2);
            rel2=struct('a',1,'b',2,'c',3);
            metaData1=struct('version','1.0','author','test1');
            metaData2=struct('version','2.0','author','test2',...
                'application','testApplication');
            inpObjList={rel1,rel2};
            keyList={'rel1','rel2'};
            metaDataList={metaData1,metaData2};
            self.map.put(keyList,inpObjList,metaDataList);
            inpArgList={fliplr(keyList),'UniformOutput',false}; %#ok<NASGU>
            self.runAndCheckError(...
                '[valueObjList,metaDataGetList]=self.map.get(inpArgList{:})',...
                'AHASHMAP:GETFILENAMEBYKEY:noRecord');
            %
            self.map.removeAll();
        end
    end
end