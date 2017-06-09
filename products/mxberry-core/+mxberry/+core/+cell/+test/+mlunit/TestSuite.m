% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef TestSuite < mxberry.unittest.TestCase
    properties
    end
    
    methods
        function self = TestSuite(varargin)
            self = self@mxberry.unittest.TestCase(varargin{:});
        end
        %
    end
    methods (Test)
        function testMultiDimSimple(self)
            resStr=mxberry.core.cell.showcell({reshape('ab',1,1,1,2),{}},...
                'showClass',true,'asExpression',true);
            self.verifyEqual(...
                '{reshape(''ab'',[1 1 1 2]),cell.empty(0,0)}',resStr);
            %
            resStr=mxberry.core.cell.showcell({repmat(' ',2,3)},...
                'asExpression',true);
            expStr='{reshape(''      '',[2 3])}';
            self.verifyEqual(resStr,expStr);
            %
            resStr=mxberry.core.cell.showcell({logical.empty(0,0,1)},...
                'asExpression',true);
            expStr='{logical.empty(0,0)}';
            self.verifyEqual(resStr,expStr);
        end
        function testShowCellTrickyTouch(self)
            inpCArr=cat(3,{'a','b','';'','c','d'},{'a','b','';'','c','d'});
            [~]=mxberry.core.cell.showcell(inpCArr);
            %
            addArgList={};            
            %
            isExtract=false;
            check();
            %
            checkEmpty();
            %
            addArgList={'nMaxShownArrayElems',inf};
            checkLogical();
            %
            checkDouble();
            %
            isExtract=true;
            addArgList={};
            checkEmpty();
            %
            function checkDouble()
                inpCArr={zeros(2,3,4,0,1)};
                check();
                inpCArr={ones(0,1)};
                check();
                inpCArr={ones(0,1,0)};
                check();
                inpCArr={ones(1,1,2,5,6)};
                check();
                inpCArr={zeros(2,3,4,5)};
                check();
            end              
            %
            function checkLogical()
                inpCArr={false(2,3,4,0,1)};
                check();
                inpCArr={true(0,1)};
                check();
                inpCArr={true(0,1,0)};
                check();
                inpCArr={true(1,1,2,5,6)};
                check();
                inpCArr={false(2,3,4,5)};
                check();
            end            
            %
            function checkEmpty()
                inpCArr={cell.empty(2,3,4,0,1)};
                check();
                inpCArr={cell.empty(0,1,2)};
                check();
                inpCArr={cell.empty(0,1)};
                check();
                inpCArr={cell.empty(0,1,1)};
                check();
                inpCArr={cell.empty(0,1,1)};
                check();
                inpCArr={cell.empty(0,0)};
                check();
            end
            %
            function check()
                if isExtract
                    inpCArr=inpCArr{1};
                end
                resStr=mxberry.core.cell.showcell(inpCArr,...
                    'asExpression',true,addArgList{:});
                resCArr=eval(resStr);
                isOk=isequaln(inpCArr,resCArr);
                self.verifyTrue(isOk);
            end
        end
        function testCellStr2Expr(self)
            N_DIGITS=20;
            expStr='{''''''''}';
            fToStr=@mxberry.core.cell.cellstr2expression;
            check();
            %
            checkShowCell(true);
            expStr='''''''';
            checkShowCell(false);
            %
            function checkShowCell(isExpr)
                fToStr=@(x)mxberry.core.cell.showcell(x,...
                    'showClass',true,'printVarName',false,...
                    'asExpression',isExpr,...
                    'nMaxShownArrayElems',Inf,'nDigits',N_DIGITS);
                check();
            end
            function check()
            resStr=fToStr({''''});
            isOk=isequal(expStr,resStr);
            self.verifyTrue(isOk);
            end
        end
        function testShowCellNegative(self)
            self.runAndCheckError(@check,'wrongInput');
            function check()
                import mxberry.core.cell.showcell;
                showcell(1)
            end
        end
        function testSimpleChar(self)
            %
            check('','''''');
            check('','''''','showClass',true);
            check('','{''''}','asExpression',true);
            check('','{''''}','asExpression',true,'showClass',true);
            function check(val,expStr,varargin)
                resStr=mxberry.core.cell.showcell({val},varargin{:});
                isOk=isequal(expStr,resStr);
                self.verifyTrue(isOk);
            end
        end
        %
        function testMultiDim(self)
            %
            check(repmat(' ',2,3,4),'3-D char');
            check(repmat(' ',2,3,4,5),'4-D char');
            check(repmat(' ',2,3),'2x3 char');
            %
            check(ones(2,3,4),'3-D double');
            check(ones(2,3,4),'reshape([1 1 1 1 1 1 1 1 1 1 1 1;1 1 1 1 1 1 1 1 1 1 1 1],[2 3 4])',...
                'nMaxShownArrayElems',Inf);
            %
            check(ones(2,3,4,5),'4-D double');
            check(ones(2,3),'2x3 double','nMaxShownArrayElems',3);
            check(ones(2,3),'[1 1 1;1 1 1]');
            function check(val,expStr,varargin)
                resStr=mxberry.core.cell.showcell({val},varargin{:});
                self.verifyEqual(expStr,resStr);
            end
        end
        function testSimpleRegr(self)
            isAsExp=true;
            isAsNoExp=true;
            %
            val={int8([])};
            expStr='[]';
            checkAll(expStr);
            %
            val={[]};
            expStr='[]';
            checkAll(expStr);
            %
            isAsNoExp=true;
            isAsExp=false;
            val={{}};
            expStr='{}';
            checkAll(expStr);            
            %
            isAsNoExp=false;
            isAsExp=true;
            expStr='cell.empty(0,0)';
            checkAll(expStr);
            %
            isAsNoExp=true;
            isAsExp=true;
            %
            val={true(1,9)};
            expStr='[true true true true true true true true true]';
            checkAll(expStr);
            %
            val={ones(1,9)};
            expStr='[1 1 1 1 1 1 1 1 1]';
            checkAll(expStr);
            %
            val={int8(ones(1,9))};
            checkAll(expStr);
            %
            function checkAll(expStr,varargin)
                valClass=class(val{1});
                masterCheck(expStr,varargin{:});
                isCellElem=iscell(val{1});
                if isCellElem
                    valStr=expStr;
                else
                    valStr=sprintf('%s(%s)',valClass,expStr);
                end
                masterCheck(valStr,...
                    'showClass',true,varargin{:});
                masterCheck(expStr,'nMaxShownArrayElems',9,varargin{:});
                %
                if ~(isempty(val{1})&&isCellElem)
                    if ~isempty(val{1})
                        valStr=sprintf('1x9 %s',valClass);
                    else
                        valStr='[]';
                    end
                    masterCheck(valStr,...
                        'nMaxShownArrayElems',8,varargin{:});
                end
            end
            %
            function masterCheck(inpStr,varargin)
                if isAsNoExp
                    check(inpStr,val,varargin{:});
                end
                %
                if isAsExp
                    check(sprintf('{%s}',inpStr),val,varargin{:},...
                        'asExpression',true);
                end
            %                
            end
            %
            function check(expStr,varargin)
                import mxberry.core.cell.showcell;
                resStr=showcell(varargin{:},'printVarName',false);
                isOk=isequal(expStr,resStr);
                self.verifyTrue(isOk);
            end
        end
        %
        function testShowCellBrackets(self)
            N_MAX_SHOWN_ELEMS=10;
            %
            check(false,{ones(1,N_MAX_SHOWN_ELEMS)});
            check(false,{ones(1,N_MAX_SHOWN_ELEMS+1)});
            check(false,{ones(1,N_MAX_SHOWN_ELEMS-1)});
            %
            checkAsExp(true,{ones(1,N_MAX_SHOWN_ELEMS)});
            checkAsExp(true,{ones(1,N_MAX_SHOWN_ELEMS+1)});
            checkAsExp(true,{ones(1,N_MAX_SHOWN_ELEMS-1)});            
            %
            function checkAsExp(varargin)
                check(varargin{:},'asExpression',true);
            end
            %
            function check(isPos,varargin)
                import mxberry.core.cell.showcell;                
                resStr=showcell(varargin{:},...
                    'nMaxShownArrayElems',N_MAX_SHOWN_ELEMS,...
                    'printVarName',false);
                self.verifyEqual(resStr(1)=='{',isPos);
            end
        end
        function testShowCellFormat(self)
            import mxberry.core.cell.showcell;
            res1=showcell({int8(1),int8(1);'a','b'},'nDigits',1);
            res2=showcell({int8(1),int8(1);'a','b'});
            self.verifyTrue(isequal(res1,res2));
            
        end
        function testCellStr2ColStr(self)
            resStr=mxberry.core.cell.cellstr2colstr(...
                {'alpha','beta','gamma'},' ');
            self.verifyTrue(isrow(resStr));
        end
        function testCell2Mat(self)
            inpCArr=repmat({[1;1;1],uint64([1;1;1])},1,1,5);
            %resExpMat=cell2mat(inpCArr);
            resExpMat=ones(3,2,5);
            check();
            obj=mxberry.core.cont.ValueBox();
            obj2=mxberry.core.cont.ValueBox();
            %
            inpCArr={[obj,obj2];[obj,obj2]};
            resExpMat=[obj,obj2;obj,obj2];
            check();
            %
            inpMat=rand(2,3,4,5);
            inpCArr=num2cell(inpMat);
            check2();
            %
            inpCArr=mat2cell(inpMat,ones(2,1),3,4,5);
            check2();
            resExpMat=inpCArr;
            inpCArr=num2cell(inpCArr);
            %
            check();
            inpCArr=cell(2,3,4,5);
            inpCArr=cellfun(@(varargin)repmat(char(fix(20*rand()+100)),...
                1,10),inpCArr,'UniformOutput',false);
            %
            check2();
            inpCArr=cell.empty(0,1);
            check2();
            inpCArr={1};
            check2();
            inpCArr={1,2;3,4};
            check2();
            function check()
                resMat=mxberry.core.cell.cell2mat(inpCArr);
                self.verifyEqual(true,isequal(resMat,resExpMat));
            end
            function check2()
                resExpMat=cell2mat(inpCArr);
                check();
            end
        end
        %
        function testCellStr2ExpressionSimple(self)
            inpList={'aaa','bbb'};
            expStr='{''aaa'',''bbb''}';
            check();
            check(false);
            expStr='[aaa,bbb]';
            check(true);
            %
            function check(varargin)
                resStr=mxberry.core.cell.cellstr2expression(inpList,...
                    varargin{:});
                self.verifyEqual(true,isequal(resStr,expStr));
            end
        end
        function testCellStr2Expression(self)
            inpCMat={'cos(t)','sin(t)';'-sin(t)','cos(t)'};
            timeVec=0:0.1:2*pi;
            etArray=evalStrMat(inpCMat,timeVec);
            resArray=evalOptMat(inpCMat,timeVec);
            fcnArray=evalFcnMat(inpCMat,timeVec);
            self.verifyEqual(true,isequal(etArray,resArray));
            self.verifyEqual(true,isequal(fcnArray,resArray));
            %
            function resArray=evalFcnMat(X,t)
                fHandle=mxberry.core.cell.cellstr2func(X,'t');
                t=shiftdim(t,-1);
                resArray=fHandle(t);
            end
            function resArray=evalOptMat(X,t)
                expStr=mxberry.core.cell.cellstr2expression(X,true);
                t=shiftdim(t,-1); %#ok<NASGU>
                resArray=eval(expStr);
            end
            %
            function Y=evalStrMat(X,t)
                msize=size(X);
                tsize=size(t);
                Y=zeros([msize tsize(2)]);
                for i=1:1:msize(1)
                    for j=1:1:msize(2)
                        Y(i,j,:)=eval(vectorize(X{i,j}));
                    end
                end
            end
        end
        %
        function self=test_parseparams_negative(self)
            import mxberry.core.cell.showcell;
            inpVar={}; %#ok<NASGU>
            resStr=evalc('showcell(inpVar);');
            self.verifyEqual(true,isempty(strfind(resStr,'inpVar')));
            %
            commandStr='showcell(inpVar,''printVarName'',false)';
            %
            resStr=evalc(commandStr);
            self.verifyEqual(true,isempty(strfind('inpVar',resStr)));
            %
            commandStr='showcell(inpVar,''printVarName'',true)';
            %
            resStr=evalc(commandStr);
            self.verifyEqual(false,isempty(strfind(resStr,'inpVar')));
        end
        %
        function testShowCellOnEnum(self)
            import mxberry.core.cell.showcell;
            if ~verLessThan('matlab','7.12')
                inpCell=cell(2,3);
                inpCell{1,2}=1;
                inpCell{2,2}=2;
                inpCell{1,3}=mxberry.core.cell.test.ShowCellTestEnum.Internal;
                inpCell{2,3}=[mxberry.core.cell.test.ShowCellTestEnum.Internal,...
                    ;mxberry.core.cell.test.ShowCellTestEnum.External];
                inpCell{1,1}=repmat(...
                    mxberry.core.cell.test.ShowCellTestEnum.Internal,[1,1,2,2]);
                resStr=evalc('showcell(inpCell,''printVarName'',false);');
                resStr=resStr(1:end-1);
                check();
                resStr=showcell(inpCell,'printVarName',false);
                check();
                resStr=showcell(inpCell,'printVarName',true);
                check(false);
            end
            function check(isOk)
                if nargin==0
                    isOk=true;
                end
                resStrList=strsplit(resStr,sprintf('\n'));
                resStrExpList={...
                    '4-D mxberry.core.cell.test.ShowCellTestEnum    1    Internal',...
                    '[]                                             2    2x1 mxberry.core.cell.test.ShowCellTestEnum'};
                resStrList=cellfun(@strtrim,resStrList,'UniformOutput',false);
                isPos=isequal(resStrList,resStrExpList);
                self.verifyEqual(isOk,isPos);
            end
        end
        function testShowCellOfCharCols(self)
            import mxberry.core.cell.showcell;
            inpCell={'a',1;'bb'.' 2}; %#ok<NASGU>
            resStr=evalc('display(inpCell)');
            self.verifyEqual(true,~isempty(strfind(resStr,'inpCell =')));
            resStr=evalc('disp(inpCell)');
            self.verifyEqual(true,isempty(strfind(resStr,'inpCell =')));
            %
            inpCell={repmat('z',10,1)}; %#ok<NASGU>
            evalc('showcell(inpCell)');
            res={repmat('z',10,1)}; %#ok<NASGU>
            evalc('res');
        end
        function testShowCellOfStruct(~)
            import mxberry.core.cell.showcell;
            evalc('showcell({struct(),struct(),struct()});');
        end
        function testShowCellOfSomeClass(~)
            import mxberry.core.cell.showcell;
            inpCell={mxberry.core.cell.test.SomeClass()}; %#ok<NASGU>
            evalc('showcell(inpCell)');
        end
        function testCsvWrite(self)
            fileName=[fileparts(mfilename('fullpath')) filesep 'test.csv'];
            inpCell={'C:\Folder','%s%d'};
            mxberry.core.cell.csvwrite(fileName,inpCell,'delimiter',';');
            fid=fopen(fileName);
            outCell=textscan(fid,'%s %s',-1,'delimiter',';');
            fclose(fid);
            self.verifyEqual(true,...
                isequal(num2cell(strcat('"',inpCell,'"')),...
                outCell));
            delete(fileName);
        end
    end
end