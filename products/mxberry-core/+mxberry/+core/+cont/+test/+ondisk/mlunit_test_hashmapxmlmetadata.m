% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef mlunit_test_hashmapxmlmetadata<...
        mxberry.core.cont.test.ADiskBasedHashMapTC
    methods
        function self = mlunit_test_hashmapxmlmetadata(varargin)
            self = self@ mxberry.core.cont.test.ADiskBasedHashMapTC(varargin{:});
        end
    end
    properties (MethodSetupParameter)
        argList=mxberry.core.cont.test.createparamlist(...
            mxberry.core.cont.test.ondisk.HashMapXMLMetaDataFactory(),...
            {'verxml'},[true,false]);
    end
    methods (Test)
        function self=test_putGetWithMetaData(self)
            rel1=self.rel1;
            rel2=self.rel2;
            metaData1=struct('version','1.0','author','test1');
            metaData2=struct('version','2.0','author','test2',...
                'application','testApplication');
            self.map=self.mapFactory.getInstance('storageBranchKey',...
                'aaa',self.testParamList{:});
            inpObjList={rel1,rel2};
            keyList={'rel1','rel2'};
            metaDataList={metaData1,metaData2};
            self.map.put(keyList,inpObjList,metaDataList);
            [valueObjList,metaDataGetList]=self.map.get(...
                fliplr(keyList),'UniformOutput',false);
            valueObjList=fliplr(valueObjList);
            metaDataGetList=fliplr(metaDataGetList);
            %compare values
            isEqual=all(cellfun(@isequal,inpObjList,valueObjList));
            self.verifyEqual(isEqual,true);
            %compare meta data
            isEqual=all(cellfun(@isequal,metaDataList,metaDataGetList));
            self.verifyEqual(isEqual,true);
            %
            self.map.removeAll();
        end
    end
end