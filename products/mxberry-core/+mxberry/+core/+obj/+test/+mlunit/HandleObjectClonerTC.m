% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef HandleObjectClonerTC < mxberry.unittest.TestCase
    methods
        function self = HandleObjectClonerTC(varargin)
            self = self@mxberry.unittest.TestCase(varargin{:});
        end
    end
    methods (Test)
        function testUniqueNotInBinaryMode(self)
            objVec=mxberry.core.obj.test.HandleObjectClonerAdv.create(...
                [1,2,1],[1,2,2]);
            isOk=eq(objVec(1),objVec(3));
            self.verifyTrue(isOk);
            isOk=isEqual(objVec(1),objVec(3),'asBlob',true);
            self.verifyTrue(~isOk);
            isOk=isEqual(objVec(1),objVec(3),'asHandle',true);
            self.verifyTrue(~isOk);
            self.runAndCheckError(...
                'isOk=isEqual(objVec(1),objVec(3),''asHandle'',true,''asBlob'',true);',...
                'wrongInput:blobAndHandleIncompatible');
            %
            unqVec=unique(objVec);
            sortVec=sort(objVec);
            isOk=numel(unqVec)==3;
            self.verifyTrue(isOk);
            isOk=~any(isEqualElem(unqVec(1:end-1),unqVec(2:end),'asBlob',true));
            self.verifyTrue(isOk);
            isOk=all(isEqualElem(unqVec,sortVec,'asBlob',true));
            self.verifyTrue(isOk);
            isOk=isEqual(unqVec,sortVec,'asBlob',true);
            self.verifyTrue(isOk);
        end
        function testEqAsHandle(self)
            obj=mxberry.core.obj.test.HandleObjectCloner(1);
            self.checkEqAsHandle(self,obj);
        end
        function testAtemptToSortNotInBinaryMode(self)
            objVec=mxberry.core.obj.test.HandleObjectCloner.create(2);
            self.runAndCheckError(@()mxberry.core.sort.mergesort(objVec),...
                'wrongInput:signNotDefForAllElems');
        end
        function testUniqueIsmemberCallNumber(~)
            import mxberry.core.test.aux.EqualCallCounter;
            %
            nObjVec=[3,2,5];
            for iCase=1:numel(nObjVec)
                nObj=nObjVec(iCase);
                objVec=...
                    mxberry.core.obj.test.HandleObjectClonerTrickyCount.create(nObj);
                EqualCallCounter.checkCalls(objVec);
            end
        end
    end
    methods (Static)
        function checkEqAsHandle(self,obj)
            obj2=obj.clone;
            check(false,'asHandle',true);
            check(true);
            %
            function check(isPosExpected,varargin)
                chk(@isequal);
                chk(@eq);
                chk(@(varargin)~ne(varargin{:}));
                chk(@isequaln);
                chk(@isequaln);
                function chk(fOp)
                    isEq=fOp(obj,obj2,varargin{:});
                    self.verifyEqual(isEq,isPosExpected);
                end
            end
        end
    end
end