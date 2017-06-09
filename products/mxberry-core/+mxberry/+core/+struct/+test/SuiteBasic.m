% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef SuiteBasic < mxberry.unittest.TestCase %#ok<*NASGU>
    methods
        function self = SuiteBasic(varargin)
            self = self@mxberry.unittest.TestCase(varargin{:});
        end
    end
    methods (Test)
        function testStructGetPath(self)
            SInp.a.b=21;
            SInp.a.c=3;
            SInp.cd.u=2;
            SInp.m=2;
            SInp.alpha.beta.gamma=3;
            %
            checkEmpty();
            checkEmpty(true);
            checkEmpty(false);
            checkEmpty(true,false);
            checkEmpty(false,false);
            checkEmpty(false,true);
            checkEmpty(true,true);
            %
            checkMaster();
            checkMaster(true);
            checkMaster(false);
            %
            checkBadField('MATLAB:nonExistentField');
            %
            SInp(2).alpha.beta=[1;2;3;4;5;6;6;7];
            SInp(1).alpha.beta=[2,3,3;4 5 6];
            %
            checkBadField('MATLAB:cell2mat:MixedDataTypes');
            %
            checkMasterVec();
            checkMasterVec(true);
            checkMasterVec(false);
            %
            checkJustCheck(true,true);
            %
            fRun=@()checkJustCheck(false,false);
            self.runAndCheckError(fRun,'MATLAB:catenate:dimensionMismatch');
            %
            function checkEmpty(varargin)
                [SRes,isThere]=mxberry.core.struct.structgetpath(SInp,'');
                self.verifyTrue(isThere);
                self.verifyEqual(SRes,SInp);
            end
            
            function checkBadField(exceptionTag)
                checkMasterNeg(true);
                fRun=@()checkMasterNeg(false);
                self.runAndCheckError(fRun,exceptionTag);
            end
            function checkJustCheck(isThereExp,isJustCheck)
                check('alpha.beta',struct.empty(0,0),isThereExp,true,isJustCheck);
                check('alpha.beta',struct.empty(0,0),isThereExp,false,isJustCheck);
                check('alpha.beta2',struct.empty(0,0),false,true,isJustCheck);
                check('alpha.beta2',struct.empty(0,0),false,false,isJustCheck);
            end
            %
            function checkMasterVec(varargin)
                SExp(2).beta=[1;2;3;4;5;6;6;7];
                SExp(1).beta=[2,3,3;4 5 6];
                check('alpha',SExp,true,varargin{:});
            end
            %
            function checkMaster(varargin)
                check('a.b',21,true,varargin{:});
                check('m',2,true,varargin{:});
            end
            function checkMasterNeg(varargin)
                check('a.bb',struct.empty(0,0),false,varargin{:});
                check('m2',struct.empty(0,0),false,varargin{:});
            end
            function check(pathStr,val,isThereExp,varargin)
                res=mxberry.core.struct.structgetpath(SInp,pathStr,...
                    varargin{:});
                isOk=isequal(res,val);
                self.verifyTrue(isOk);
                [res,isThere]=mxberry.core.struct.structgetpath(SInp,...
                    pathStr,varargin{:});
                if isThere
                    isThereCheck=mxberry.core.struct.structcheckpath(SInp,...
                        pathStr);
                    isOk=isequal(isThere,isThereCheck);
                    self.verifyTrue(isOk);
                end
                %
                isOk=isequal(res,val);
                self.verifyTrue(isOk);
                %
                isOk=isequal(isThere,isThereExp);
                self.verifyTrue(isOk);
            end
        end
        function testPathFilterStruct(self)
            SInp.a.b=2;
            SInp.a.c=3;
            SInp.cd.u=2;
            SInp.m=2;
            SInp.alpha.beta.gamma=3;
            %
            SRes=mxberry.core.struct.pathfilterstruct(SInp,{'a.b','cd.u','.m'});
            SExp.a.b=2;
            SExp.cd.u=2;
            SExp.m=2;
            [isOk,reportStr]=mxberry.core.struct.structcompare(SExp,SRes);
            self.verifyTrue(isOk,reportStr);
            %
            SRes=mxberry.core.struct.pathfilterstruct(SInp,{'a','a.b','cd.u','.m'});
            SExp.a.c=3;
            [isOk,reportStr]=mxberry.core.struct.structcompare(SExp,SRes);
            self.verifyTrue(isOk,reportStr);
        end
        %
        function testBinaryUnionStruct(self)
            SLeft.alpha=[1,2];
            SRight.alpha=[3,4];
            SLeft.beta=3;
            SRight.gamma=4;
            SRes=mxberry.core.struct.binaryunionstruct(SLeft,SRight,@horzcat);
            SExp.alpha=[1,2,3,4];
            SExp.beta=3;
            SExp.gamma=4;
            [isOk,reportStr]=mxberry.core.struct.structcompare(SExp,SRes);
            self.verifyTrue(isOk,reportStr);
            SRes=mxberry.core.struct.binaryunionstruct(SLeft,SRight,@horzcat,...
                @(x)x*100,@(x)x*10);
            SExp.alpha=[1,2,3,4];
            SExp.beta=300;
            SExp.gamma=40;
            [isOk,reportStr]=mxberry.core.struct.structcompare(SExp,SRes);
            self.verifyTrue(isOk,reportStr);
        end
    end
end