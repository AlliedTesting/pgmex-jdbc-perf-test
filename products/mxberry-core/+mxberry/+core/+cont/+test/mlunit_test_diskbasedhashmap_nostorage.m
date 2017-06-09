% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef mlunit_test_diskbasedhashmap_nostorage < matlab.unittest.TestCase
    properties (Access=private)
        map
        rel1
        rel2
    end
    %
    methods
        function self = mlunit_test_diskbasedhashmap_nostorage(varargin)
            self = self@matlab.unittest.TestCase(varargin{:});
        end
    end
    methods (TestMethodSetup)
        function self = setUp(self)
            import mxberry.core.cont.DiskBasedHashMap;
            self.map=DiskBasedHashMap('storageBranchKey',...
                'testBranch','storageFormat','none');
            %
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
            self.map.removeAll();
        end
    end
    methods(Test)
        function self=test_putGet(self)
            rel1=self.rel1; %#ok<*PROP>
            rel2=self.rel2;
            inpObjList={rel1,rel2};
            keyList={'rel1','rel2'};
            self.map.put(keyList,inpObjList);
            isThere=fliplr(self.map.isKey(fliplr(keyList)));
            isEqual=any(isThere==true);
            self.verifyEqual(isEqual,false);
            self.map.removeAll();
        end
        function self=test_getKeyList(self)
            rel1=self.rel1;
            rel2=self.rel2;
            inpObjList={rel1,rel2};
            keyList={'rel1','rel2'};
            self.map.put(keyList,inpObjList);
            isEqual=isequal({},self.map.getKeyList);
            self.verifyEqual(isEqual,true);
            self.map.remove('rel2');
            isEqual=isequal({},self.map.getKeyList);
            self.verifyEqual(isEqual,true);
            self.map.removeAll();
        end
        function self=test_isKeyAndRemove(self)
            rel1=self.rel1;
            rel2=self.rel2;
            rel3=self.rel2;
            inpObjList={rel1,rel2,rel3};
            keyList={'rel1','rel2','rel3'};
            self.map.put(keyList,inpObjList);
            self.map.remove(keyList{3});
            self.verifyEqual(self.map.isKey(keyList{3}),false);
            keyList=keyList(1:2);
            isThere=fliplr(self.map.isKey(fliplr(keyList)));
            isEqual=any(isThere==true);
            self.verifyEqual(isEqual,false);
            self.map.removeAll();
        end
        function self=test_getFileNameByKey(self)
            rel1=self.rel1;
            inpObjList={rel1};
            keyList='rel1';
            self.map.put(keyList,inpObjList);
            self.map.getFileNameByKey(keyList);
        end
    end
end