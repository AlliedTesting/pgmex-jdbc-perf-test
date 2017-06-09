% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef StructCompareTC < matlab.unittest.TestCase
    properties
        SXComp
        SYComp
    end
    methods (TestMethodSetup)
        function self = setUp(self)
            s.a=1;
            s.b=2;
            S(1)=s;
            S(2)=s;
            S2=S;
            S(2).b=3;
            X=S;
            Y=S;
            X([1 2])=S;
            Y([1 2])=S2;
            [X.c]=deal(S);
            [Y.c]=deal(S2);
            X=[X;X];
            Y=[Y;Y];
            self.SXComp=X;
            self.SYComp=Y;
        end
    end
    methods
        function self = StructCompareTC(varargin)
            self = self@matlab.unittest.TestCase(varargin{:});
        end
    end
    methods (Test)
        function self = test_simplestruct_positive(self)
            S1=struct('a',1,'b',2);
            S2=struct('a',2,'b',2);
            isEqual=mxberry.core.struct.structcompare(S1,S2,0);
            self.verifyEqual(isEqual,false);
        end
        %
        function testUpdateLeavesEmpty(self)
            S.alpha=struct();
            S.beta=1;
            Res=mxberry.core.struct.updateleaves(S,@(x,y)x);
            self.verifyTrue(isequal(S,Res));
        end
        %
        function testVectorialStruct(self)
            S1=struct();
            S1(2,2).alpha=4;
            S2=struct();
            S2(4).alpha=4;
            check();
            %
            S1=struct();
            S1.alpha(2,3).a=6;
            %
            S2=struct();
            S2.alpha(6).a=6;
            check();
            function check()
                isEqual=mxberry.core.struct.structcompare(S1,S2);
                self.verifyEqual(false,isEqual);
            end
        end
        %
        function self = test_simplestruct_int64(self)
            check(int64(1),int64(1),0,true);
            check(uint64(1),uint64(2),3,true);
            check(uint64(1),uint64(2),0,false);
            %
            function check(value1,value2,tol,expRes)
                S1=struct('a',1,'b',value1);
                S2=struct('a',1,'b',value2);
                isEqual=mxberry.core.struct.structcompare(S1,S2,tol);
                self.verifyEqual(isEqual,expRes);
            end
        end
        %
        function testInf(self)
            S1=struct('a',1,'b',[nan inf -inf 1]);
            isEqual=mxberry.core.struct.structcompare(S1,S1,0);
            self.verifyEqual(isEqual,true);
        end
        %
        function self = test_simplestruct_negative(self)
            S1=struct('a',1,'b',nan);
            S2=struct('a',1,'b',2);
            isEqual=mxberry.core.struct.structcompare(S1,S2,0);
            self.verifyEqual(isEqual,false);
        end
        function self = test_simplestruct_negative2(self)
            S1=struct('a',1,'b',2);
            S2=struct('a',1,'b',2);
            isEqual=mxberry.core.struct.structcompare(S1,S2,0);
            self.verifyEqual(isEqual,true);
        end
        function self = test_simplestruct2_negative(self)
            S1=struct('a',struct('a',1+1e-10,'b',1),'b',2);
            S2=struct('a',struct('a',1,'b',1),'b',2);
            isEqual=mxberry.core.struct.structcompare(S1,S2,1e-11);
            self.verifyEqual(isEqual,false);
        end
        function self = test_simplestruct2_positive(self)
            S1=struct('a',struct('a',1+1e-10,'b',1),'b',2);
            S2=struct('a',struct('a',1,'b',1),'b',2);
            [isEqual,reportStr]=mxberry.core.struct.structcompare(S1,S2,1e-9);
            self.verifyEqual(isEqual,true,reportStr);
        end
        function self = test_simplestruct3_negative(self)
            S1=struct('a',struct('a',nan,'b',1),'b',2);
            S2=struct('a',struct('a',1,'b',1),'b',2);
            isEqual=mxberry.core.struct.structcompare(S1,S2,0);
            self.verifyEqual(isEqual,false);
        end
        
        function self = test_simplestructarray1_negative(self)
            S1(1)=struct('a',struct('a',1+1e-10,'b',1),'b',2);
            S1(2)=struct('a',struct('a',nan,'b',1),'b',2);
            S2(1)=struct('a',struct('a',1,'b',1),'b',2);
            S2(2)=struct('a',struct('a',1,'b',1),'b',2);
            isEqual=mxberry.core.struct.structcompare(S1,S2,0);
            self.verifyEqual(isEqual,false);
        end
        function self = test_simplestructarray1_positive(self)
            S2(1)=struct('a',struct('a',1,'b',1),'b',2);
            S2(2)=struct('a',struct('a',1,'b',1),'b',2);
            S1=S2;
            [isEqual,reportStr]=mxberry.core.struct.structcompare(S1,S2,0);
            self.verifyEqual(isEqual,true,reportStr);
        end
        function self = test_complex1_positive(self)
            [isEqual,reportStr]=mxberry.core.struct.structcompare(self.SXComp,self.SXComp,0);
            self.verifyEqual(isEqual,true,reportStr);
        end
        function self = test_complex1_negative(self)
            [isEqual,reportStr]=mxberry.core.struct.structcompare(self.SXComp,self.SYComp,0);
            self.verifyEqual(isEqual,false);
            self.verifyEqual(numel(strfind(reportStr,sprintf('\n'))),5);
        end
        function self = test_optional_tolerance_arg(self)
            [isEqual,reportStr]=mxberry.core.struct.structcompare(self.SXComp,self.SYComp,0);
            [isEqual2,reportStr2]=mxberry.core.struct.structcompare(self.SXComp,self.SYComp);
            self.verifyEqual(isEqual,isEqual2);
            self.verifyEqual(reportStr,reportStr2);
        end
        function self = test_complex2_negative(self)
            S1=struct('a',1,'b',repmat([2 nan 3],2,1));
            S2=struct('a',2,'b',repmat([1 nan 2],2,1));
            [isEqual,reportStr]=mxberry.core.struct.structcompare(S1,S2,0.1);
            self.verifyEqual(isEqual,false);
            self.verifyEqual(2,numel(strfind(reportStr,'Max.')));
        end
        function self = test_differentsize_negative(self)
            S1=struct('a',1,'b',repmat([2 nan 3 3],2,1));
            S2=struct('a',2,'b',repmat([1 nan 2],2,1));
            [isEqual,reportStr]=mxberry.core.struct.structcompare(S1,S2,0.1);
            self.verifyEqual(isEqual,false);
            self.verifyEqual(1,numel(strfind(reportStr,'Max.')));
            self.verifyEqual(1,numel(strfind(reportStr,'Different sizes')));
        end
        function self = test_cell_positive(self)
            S1=struct('a',1,'b',{{NaN;struct('c',{'aaa'})}});
            isEqual=mxberry.core.struct.structcompare(S1,S1,0);
            self.verifyEqual(isEqual,true);
        end
        function self = test_cell_negative(self)
            S1=struct('a',1,'b',{{NaN;struct('c',{'aaa'})}});
            S2=struct('a',1,'b',{{NaN;struct('c',{'bbb'})}});
            [isEqual,reportStr]=mxberry.core.struct.structcompare(S1,S2,0);
            self.verifyEqual(isEqual,false);
            self.verifyEqual(1,numel(strfind(reportStr,'values are different')));
        end
        function self = test_simplestruct_order_positive(self)
            S1=struct('a',1,'b',2);
            S2=struct('b',2,'a',1);
            isEqual=mxberry.core.struct.structcompare(S1,S2,0);
            self.verifyEqual(isEqual,true);
        end
        function self = test_relative_negative(self)
            S1=struct('a',1e+10,'b',2e+12);
            %
            S2=struct('b',2e+12, 'a',1e+10 + 1e+6);
            [isEqual,reportStr]=mxberry.core.struct.structcompare(S1, S2, ...
                1e-10, 1e-5);
            check_neg(1);
            %
            S2=struct('b',2e+12 - 1e+2, 'a',1e+10 + 1e+6);
            [isEqual,reportStr]=mxberry.core.struct.structcompare(S1, S2, ...
                1e+3, 1e-5);
            check_neg(1);
            %
            S2=struct('b',2e+12 - 1e+9, 'a',1e+10 + 1e+6);
            [isEqual,reportStr]=mxberry.core.struct.structcompare(S1, S2, ...
                1e+3, 1e-5);
            check_neg(2);
            %
            S1=struct('a',1e+6 - 2,'b',2e+6, 'c', 'aab');
            S2=struct('a',1e+6,'b',2e+6 + 4, 'c', 'aab');
            [isEqual,reportStr]=mxberry.core.struct.structcompare(S1, S2, ...
                1, 1e-7);
            check_neg(2);
            function check_neg(repMsgCount)
                self.verifyEqual(isEqual,false);
                self.verifyEqual(repMsgCount, ...
                    numel(strfind(reportStr, 'Max. relative difference')));
            end
        end
        function self = test_relative_positive(self)
            S1=struct('a',1e+6 - 0.5,'b',2e+6, 'c', 'aab');
            S2=struct('a',1e+6,'b',2e+6 +1, 'c', 'aab');
            isEqual=mxberry.core.struct.structcompare(S1, S2, 1e-10, 1e-6);
            self.verifyEqual(isEqual,true);
            %
            S1=struct('a',1e+10,'b',2e+12);
            S2=struct('b',2e+12, 'a',1e+10 + 1e+2);
            isEqual=mxberry.core.struct.structcompare(S1, S2, 1e-10, 1e-5);
            self.verifyEqual(isEqual,true);
            %
            S2=struct('b',2e+12 - 1e+4, 'a',1e+10 + 1e+2);
            isEqual=mxberry.core.struct.structcompare(S1, S2, 1e+3, 1e-5);
            self.verifyEqual(isEqual,true);
        end
    end
end
