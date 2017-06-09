% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef ADiskBasedHashMapTC < mxberry.unittest.TestCase
    %
    properties
        map
        mapFactory
        rel1
        rel2
        testParamList
        resTmpDir
    end
    %
    methods
        function self = ADiskBasedHashMapTC(varargin)
            self = self@mxberry.unittest.TestCase(varargin{:});
        end
    end
    methods (TestMethodTeardown)
        %
        function self = tearDown(self)
            mxberry.io.rmdir(self.resTmpDir,'s');
        end
    end
    properties (MethodSetupParameter,Abstract)
        argList
    end
    methods (TestMethodSetup)
        function self = setUp(self,argList)
            self.mapFactory=argList{1};
            self.resTmpDir=mxberry.test.TmpDataManager.getDirByCallerKey();
            storageRootDir=self.resTmpDir;
            self.map=self.mapFactory.getInstance('storageBranchKey',...
                'testBranch','storageLocationRoot',storageRootDir,...
                argList{2:end});
            %
            self.rel1=struct(...
                'gamma',{{[1 2 3],[1 2 3]}},...
                'delta',{{[1 2 3], [4 5 6]}},...
                'epsilon',{{'nu','mu'}},...
                'zeta',int16([144 1]),...
                'eta',logical([1 1]),...
                'theta',{{'nu','nu'}},...
                'iota',{{'nu','mu'}});
            %
            self.rel2=struct(...
                'gamma',{{[1 2 3],[1 2 44545453]}},...
                'delta',{{[1 2.676676734 3], [4.23232423423424 5 6]}},...
                'epsilon',{{'nu','mu'}},...
                'zeta',int8([431 2121]),...
                'eta',logical([1 0]),...
                'theta',{{'nu','nu'}},...
                'iota',{{'nu','mu'}});
            %
            self.testParamList=[argList{2:end},...
                {'storageLocationRoot',storageRootDir}];
            self.map.removeAll();
        end
    end
    methods (Test)
        %
        function self = test_constructor(self)
            obj1=self.mapFactory.getInstance();
            metaClass=metaclass(obj1);
            inpParamList=mxberry.core.parseparams(...
                self.testParamList,{'storageLocationRoot'});
            obj2=self.mapFactory.getInstance('storageLocationRoot',...
                fileparts(which(metaClass.Name)),inpParamList{:});
            self.verifyEqual(strcmp(obj1.getStorageLocation(),...
                obj2.getStorageLocation),true);
        end
        %
        function self=test_putGet(self)
            rel1=self.rel1; %#ok<*PROP>
            rel2=self.rel2;
            %
            self.map=self.mapFactory.getInstance('storageBranchKey',...
                'aaa',self.testParamList{:});
            inpObjList={rel1,rel2};
            keyList={'rel1','rel2'};
            %
            self.map.put(keyList,inpObjList);
            valueObjList=fliplr(self.map.get(fliplr(keyList),'UniformOutput',false));
            isEqual=all(cellfun(@isequal,inpObjList,valueObjList));
            self.verifyEqual(isEqual,true);
            %
            map=self.map;
            map.removeAll();
            %
        end
        %
        function self=test_longKeyPutGet(self)
            rel=self.rel1;
            self.map=self.mapFactory.getInstance('storageBranchKey',...
                'aaa',self.testParamList{:});
            map=self.map;
            map.removeAll();
            keyStr=repmat('a',namelengthmax); %#ok<NASGU>
            self.runAndCheckError('map.put({keyStr},{rel})',':wrongInput');
            self.runAndCheckError('map.get({keyStr})',':wrongInput');
            %
            keyStr=repmat('a',1,namelengthmax);
            map.put({keyStr},{rel});
            resObj=map.get({keyStr});
            isEqual=isequal(rel,resObj);
            self.verifyEqual(true,isEqual);
        end
        %
        function self=test_getKeyList(self)
            rel1=self.rel1;
            rel2=self.rel2;
            self.map=self.mapFactory.getInstance('storageBranchKey',...
                'aaa',self.testParamList{:});
            self.map.removeAll();
            inpObjList={rel1,rel2};
            keyList={'rel1','rel2'};
            self.map.put(keyList,inpObjList);
            isEqual=isequal(sort(keyList),sort(self.map.getKeyList));
            self.verifyEqual(isEqual,true);
            self.map.remove('rel2');
            isEqual=isequal({'rel1'},self.map.getKeyList);
            self.verifyEqual(isEqual,true);
            self.map.removeAll();
        end
        %
        function self=test_putGetWithoutCells(self)
            rel1=self.rel1;
            self.map=self.mapFactory.getInstance('storageBranchKey',...
                'aaa',self.testParamList{:});
            inpObjList={rel1};
            keyList='rel1';
            self.map.put(keyList,inpObjList);
            valueObjList=self.map.get(keyList,'UniformOutput',false);
            isEqual=all(cellfun(@isequal,inpObjList,valueObjList));
            self.verifyEqual(isEqual,true);
            inpObjList=rel1;
            keyList={'rel1'};
            self.map.put(keyList,inpObjList);
            valueObjList=self.map.get(keyList,'UniformOutput',false);
            inpObjList={inpObjList};
            isEqual=all(cellfun(@isequal,inpObjList,valueObjList));
            self.verifyEqual(isEqual,true);
        end
        %
        function self=test_isKeyAndRemove(self)
            rel1=self.rel1;
            rel2=self.rel2;
            rel3=self.rel2;
            self.map=self.mapFactory.getInstance('storageBranchKey',...
                'aaa',self.testParamList{:});
            inpObjList={rel1,rel2,rel3};
            keyList={'rel1','rel2','rel3'};
            self.map.put(keyList,inpObjList);
            self.map.remove(keyList{3});
            self.verifyEqual(self.map.isKey(keyList{3}),false);
            inpObjList=inpObjList(1:2);
            keyList=keyList(1:2);
            valueObjList=fliplr(self.map.get(fliplr(keyList),...
                'UniformOutput',false));
            isEqual=all(cellfun(@isequal,inpObjList,valueObjList));
            self.verifyEqual(isEqual,true);
            self.map.removeAll();
        end
        %
        function self=test_removeAll(self)
            rel1=self.rel1;
            rel2=self.rel2;
            inpObjList={rel1,rel2};
            keyList={'rel1','rel2'};
            self.map.put(keyList,inpObjList);
            self.map.remove('rel2');
            %
            map1=self.mapFactory.getInstance('storageBranchKey',...
                'testBranch2',self.testParamList{:});
            map1.removeAll();
            map1.put('rel1',rel1);
            %
            isThere1=self.map.isKey(keyList);
            isThere2=map1.isKey(keyList);
            self.verifyEqual(all(isThere1==isThere2),true);
            map1.removeAll();
            isThere=map1.isKey({'rel1'});
            self.verifyEqual(isThere,false);
            self.map.removeAll();
        end
        %
        function self=test_getFileNameByKey(self)
            rel1=self.rel1;
            self.map=self.mapFactory.getInstance('storageBranchKey',...
                'aaa',self.testParamList{:});
            inpObjList={rel1};
            keyList='rel1';
            self.map.put(keyList,inpObjList);
            self.map.getFileNameByKey(keyList);
        end
    end
end