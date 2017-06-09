% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef mlunit_test_common < mxberry.unittest.TestCase
    methods
        function self = mlunit_test_common(varargin)
            self = self@mxberry.unittest.TestCase(varargin{:});
        end
    end
    methods (Test)
        function testIsVar(self)
            a=1; %#ok<NASGU>
            isOk=mxberry.core.isvar('a');
            self.verifyTrue(isOk);
            isOk=mxberry.core.isvar('b');
            self.verifyTrue(~isOk);
        end
        function testAbsRelCompare(self)
            import mxberry.core.absrelcompare;
            % size error
            self.runAndCheckError(...
                'mxberry.core.absrelcompare([1 1], [1; 1], 0.1, [], @abs)', ...
                'wrongInput:wrongArgs');
            % absTol error #1
            self.runAndCheckError(...
                'mxberry.core.absrelcompare([1 1], [1 1], -0.1, [], @abs)', ...
                'wrongInput:wrongAbsTol');
            % absTol error #2
            self.runAndCheckError([...
                'mxberry.core.absrelcompare([1 1], [1 1], [0.1, 0.1], [],', ...
                ' @abs)'], 'wrongInput:wrongAbsTol');
            % absTol error #3
            self.runAndCheckError([...
                'mxberry.core.absrelcompare([1 1], [1 1], [], [],', ...
                ' @abs)'], 'wrongInput:wrongAbsTol');
            % relTol error #1
            self.runAndCheckError(...
                'mxberry.core.absrelcompare([1 1], [1 1], 0.1, -0.1, @abs)',...
                'wrongInput:wrongRelTol');
            % relTol error #2
            self.runAndCheckError([...
                'mxberry.core.absrelcompare([1 1], [1 1], 0.1, [0.1, 0.1],',...
                ' @abs)'], 'wrongInput:wrongRelTol');
            % fNormOp error
            self.runAndCheckError(...
                'mxberry.core.absrelcompare([1 1], [1 1], 0.1, [], 100)', ...
                'wrongInput:wrongNormOp');
            % result tests
            SRes = calc([], [], 0.5, [], @abs);
            SExpRes = struct('isEqual', true, 'absDiff', [], 'isRel', ...
                false, 'relDiff', [], 'relMDiff', []);
            check(SExpRes, SRes);
            %
            xVec = [1 2]; yVec = [2 4];
            SRes = calc(xVec, yVec, 2, [], @abs);
            SExpRes.isEqual = true;
            SExpRes.absDiff = 2;
            check(SExpRes, SRes);
            %
            SRes = calc(xVec, yVec, 1, [], @abs);
            SExpRes.isEqual = false;
            check(SExpRes, SRes);
            %
            SRes = calc(xVec, yVec, 2, 2/3, @abs);
            SExpRes.isEqual = true;
            check(SExpRes, SRes);
            %
            SRes = calc(xVec, yVec, 1, 2/3, @abs);
            SExpRes.isRel = true;
            SExpRes.relDiff = 2/3;
            SExpRes.relMDiff = 2;
            check(SExpRes, SRes);
            %
            SRes = calc(xVec, yVec, 1, 0.5, @abs);
            SExpRes.isEqual = false;
            check(SExpRes, SRes);
            %
            SRes = calc(xVec, yVec, 0.5, 0.5, @abs);
            check(SExpRes, SRes);
            function SRes = calc(varargin)
                [SRes.isEqual, SRes.absDiff, SRes.isRel, SRes.relDiff, ...
                    SRes.relMDiff] = mxberry.core.absrelcompare(varargin{:});
            end
            function check(leftArray,rightArray)
                self.verifyEqual(true,isequal(leftArray,...
                    rightArray));
            end
        end
        function self=testCheckMultVar(self)
            import mxberry.core.check.lib.*;
            %
            a='sdfadf';
            b='asd';
            %
            checkP(@(x1)isstring(x1),1,a,'varNameList',{'alpha'});
            checkP(@(x1)isstring(x1)',1,a);
            checkP('numel(x1)==numel(x2)',2,a,a);
            checkP('numel(x1)==numel(x2)',2,a,a,'varNameList',{'alpha'});
            checkP('numel(x1)==numel(x2)',2,a,a,'varNameList',{'alpha','beta'});
            %
            checkNSuperMaster('');
            checkNSuperMaster('MyMessage','errorMessage','MyMessage');
            %
            function checkNSuperMaster(errorMessage,varargin)
                
                checkNMaster('',errorMessage,varargin{:});
                checkNMaster('wrongParam:badType',errorMessage,'errorTag',...
                    'wrongParam:badType',varargin{:});
                %
                checkNMaster('wrongParam:badType',errorMessage,'errorTag',...
                    'wrongParam:badType',varargin{:});
            end
            %
            function checkNMaster(expTag,expMessage,varargin)
                isEmptyMsg=isempty(expMessage);
                checkN('numel(x1)==numel(x2)',2,expTag,expMessage,a,a,...
                    'varNameList',{'alpha','beta','gamma'},varargin{:});
                if isEmptyMsg
                    expMessage='Alpha,Beta';
                end
                checkN('numel(x1)==numel(x2)',2,expTag,expMessage,a,b,...
                    'varNameList',{'Alpha','Beta'},varargin{:});
                if isEmptyMsg
                    expMessage='Alpha,b';
                end
                checkN('numel(x1)==numel(x2)',2,expTag,expMessage,a,b,...
                    'varNameList',{'Alpha'},varargin{:});
            end
            
            %
            function checkN(typeSpec,nPlaceHolders,expTag,expMsg,a,b,varargin)
                if isempty(expMsg)
                    runArgList={};
                else
                    runArgList={expMsg};
                end
                if isempty(expTag)
                    expTag=':wrongInput';
                end
                import mxberry.core.check.lib.*;
                try
                    mxberry.core.checkmultvar(...
                        typeSpec,nPlaceHolders,a,b,varargin{:});
                catch meObj %#ok<NASGU>
                    self.runAndCheckError(...
                        'rethrow(meObj)',expTag,runArgList{:});
                end
                fHandle=typeSpec2Handle(typeSpec,nPlaceHolders);
                try
                    mxberry.core.checkmultvar(...
                        fHandle,nPlaceHolders,a,b,varargin{:});
                catch meObj %#ok<NASGU>
                    self.runAndCheckError(...
                        'rethrow(meObj)',expTag,runArgList{:});
                end
            end
            %
            function checkP(typeSpec,nPlaceHolders,varargin)
                import mxberry.core.throwerror;
                mxberry.core.checkmultvar(typeSpec,...
                    nPlaceHolders,varargin{:});
                fHandle=typeSpec2Handle(typeSpec,nPlaceHolders);
                mxberry.core.checkmultvar(fHandle,...
                    nPlaceHolders,varargin{:});
            end
            %
            function fHandle=typeSpec2Handle(typeSpec,nPlaceHolders)
                import mxberry.core.check.lib.*;
                if ischar(typeSpec)
                    switch nPlaceHolders
                        case 1
                            fHandle=eval(['@(x1)(',typeSpec,')']);
                        case 2
                            fHandle=eval(['@(x1,x2)(',typeSpec,')']);
                        case 3
                            fHandle=eval(['@(x1,x2,x3)(',typeSpec,')']);
                        otherwise
                            throwerror('wrongInput',...
                                'unsupported number of arguments');
                    end
                else
                    fHandle=typeSpec;
                end
            end
        end
        function self=testCheckVar(self)
            import mxberry.core.check.lib.*;
            a='sdfadf';
            mxberry.core.checkvar(a,@isstring);
            mxberry.core.checkvar(a,@isstring,'aa');
            a=1;
            checkN(a,@(x)isstring(x));
            checkN(a,@(x)iscelloffunc(x));
            %
            checkP(a,@(x)(isstring(x)||isrow(x)));
            %
            checkP(a,@(x)(isstring(x)||isrow(x)||isabrakadabra(x)));
            %
            a=1;
            checkN(a,@(x)(isstring(x)&&isvec(x)));
            checkN(a,@(x)(isstring(x)&&isabrakadabra(x)));
            %
            a=true;
            checkP(a,@(x)(islogical(x)&&isscalar(x)));
            a=struct();
            checkP(a,@(x)(isstruct(x)&&isscalar(x)));
            %
            a={'a','b'};
            checkP(a,@(x)(iscellofstring(x)));
            a={'a','b';'d','e'};
            checkP(a,@(x)(iscellofstring(x)));
            a={'a','b'};
            checkP(a,@(x)(iscellofstring(x)));
            a={'a','b';'d','e'};
            checkP(a,@(x)iscellofstring(x));
            a={'a','b';'d','esd'.'};
            checkN(a,@(x)iscellofstring(x));
            %
            a={@(x)1,@(x)2};
            checkP(a,@(x)iscelloffunc(x));
            a={@(x)1,'@(x)2'};
            checkN(a,@iscelloffunc);
            %
            checkNE('','myMessage',a,@iscelloffunc,...
                'errorMessage','myMessage');
            checkNE('wrongType:wrongSomething','myMessage',a,...
                @iscelloffunc,...
                'errorMessage','myMessage','errorTag',...
                'wrongType:wrongSomething');
            checkNE('wrongType:wrongSomething','',a,@iscelloffunc,...
                'errorTag','wrongType:wrongSomething');
            %
            function checkN(x,typeSpec,varargin)
                checkNE('','',x,typeSpec,varargin{:});
                
            end
            %
            function checkNE(errorTag,errorMessage,x,typeSpec,varargin) %#ok<INUSL>
                import mxberry.core.check.lib.*;
                if isempty(errorTag)
                    errorTag=':wrongInput';
                end
                if isempty(errorMessage)
                    addArgList={};
                else
                    addArgList={errorMessage};
                end
                self.runAndCheckError(...
                    ['mxberry.core.checkvar(x,',...
                    'typeSpec,varargin{:})'],...
                    errorTag,addArgList{:});
                if ischar(typeSpec)
                    fHandle=eval(['@(x)(',typeSpec,')']); %#ok<NASGU>
                else
                    fHandle=typeSpec; %#ok<NASGU>
                end
                %
                self.runAndCheckError(...
                    ['mxberry.core.checkvar(x,',...
                    'fHandle,varargin{:})'],...
                    errorTag,addArgList{:});
            end
            %
            function checkP(x,typeSpec,varargin)
                import mxberry.core.check.lib.*;
                mxberry.core.checkvar(x,typeSpec,varargin{:});
                if ischar(typeSpec)
                    fHandle=eval(['@(x)(',typeSpec,')']);
                else
                    fHandle=typeSpec;
                end
                mxberry.core.checkvar(x,fHandle,varargin{:});
            end
            
        end
        %
        
        function testThrowWarn(self)
            check('wrongInput','test message');
            check('wrongInput',...
                'test \n message C:\\SomeFolder\\sdf/sdf/sdfsdf');
            function check(identifier,message)
                ID_STR=...
                    ['MXBERRY:CORE:TEST:MLUNIT_TEST_COMMON:TESTTHROWWARN:',...
                    identifier];
                %
                lastwarn('');
                s=warning('off',...
                    'MXBERRY:CORE:TEST:MLUNIT_TEST_COMMON:TESTTHROWWARN:wrongInput');
                mxberry.core.throwwarn('wrongInput',message);
                warning(s);
                [lastMsg,lastId]=lastwarn();
                self.verifyEqual(true,isequal(sprintf(message),lastMsg));
                self.verifyEqual(true,isequal(ID_STR,lastId));
            end
        end
        function self=testThrowError(self)
            check('wrongInput','test message');
            check('wrongInput',...
                'test \\ message C:\\SomeFolder\\sdf/sdf/sdfsdf');
            function check(identifier,message)
                meExpObj=mxberry.core.throwerror(identifier,message);
                try
                    mxberry.core.throwerror(identifier,message);
                catch meObj
                    self.verifyEqual(true,isequal(meObj.identifier,meExpObj.identifier));
                    self.verifyEqual(true,isequal(meObj.message,meExpObj.message));
                    self.verifyEqual(true,isequal(meObj.cause,meExpObj.cause));
                end
            end
        end
        function testGenFileName(self)
            resStr=mxberry.core.genfilename('sdfsdfsdf.;:sdfd');
            expStr='sdfsdfsdf.;_sdfd';
            self.verifyEqual(true,isequal(resStr,expStr));
        end
        function testInd2SubMat(self)
            sizeVec=[2,3];
            indVec=1:6;
            %
            nDims=length(sizeVec);
            indSubList=cell(1,nDims);
            indMat=mxberry.core.ind2submat(sizeVec,indVec);
            [indSubList{:}]=ind2sub(sizeVec,indVec.');
            indExpMat=[indSubList{:}];
            self.verifyEqual(true,isequal(indMat,indExpMat));
        end
        %
        function self=test_ismembercellstr(self)
            import mxberry.core.ismembercellstr;
            aList={'asdfsdf','sdfsfd','sdfsdf','sdf'};
            bList={'sdf','sdfsdf','ssdfsfsdfsd','sdf'};
            [isTVec,indLVec]=ismember(aList,bList,'legacy');
            [isTOVec,indLOVec]=ismembercellstr(aList,bList,true);
            self.verifyEqual(true,isequal(isTVec,isTOVec));
            self.verifyEqual(true,isequal(indLVec,indLOVec));
            %
            [isTOVec,indLOVec]=ismembercellstr(aList,bList);
            self.verifyEqual(true,isequal([false false true true],isTOVec));
            self.verifyEqual(true,isequal([0 0 2 1],indLOVec));
            %
            [isTOVec,indLOVec]=ismembercellstr(aList,'sdfsfd');
            self.verifyEqual(true,isequal([false true false false],isTOVec));
            self.verifyEqual(true,isequal([0 1 0 0],indLOVec));
            %
            [isTOVec,indLOVec]=ismembercellstr('sdfsfd',aList);
            self.verifyEqual(true,isequal(true,isTOVec));
            self.verifyEqual(true,isequal(2,indLOVec));
            [isTOVec,indLOVec]=ismembercellstr('sdfsfd','sdfsfd');
            self.verifyEqual(true,isTOVec);
            self.verifyEqual(indLOVec,1);
            [isTOVec,indLOVec]=ismembercellstr('sdfsfd','sdfsf');
            self.verifyEqual(false,isTOVec);
            self.verifyEqual(indLOVec,0);
            %
            [isTOVec,indLOVec]=ismembercellstr('alpha',{'a','b','c'});
            self.verifyEqual(false,isTOVec);
            self.verifyEqual(indLOVec,0);
            %
            [isTOVec,indLOVec]=ismembercellstr({'a','b','c'},'alpha');
            self.verifyEqual(true,isequal(false(1,3),isTOVec));
            self.verifyEqual(true,isequal(zeros(1,3),indLOVec));
            %
        end
        function self=test_isunique(self)
            self.verifyEqual(false,mxberry.core.isunique([1 1]));
            self.verifyEqual(true,mxberry.core.isunique([1 2]));
        end
        function self=test_cell2tablestr(self)
            fNeg=@()check(1000,-1,{'1000'});
            self.runAndCheckError(fNeg,'wrongInput');
            check(1000,4,{'1000'});
            check(1000,3,{'1e+003','1e+03'});
            function check(value,numPrecision,expStr)
                resStr=mxberry.core.cell.cell2tablestr([],num2cell(value),'_',...
                    'numPrecision',numPrecision);
                self.verifyEqual(true,any(strcmp(expStr,resStr)));
            end
        end
        
        function self = test_cellfunallelem(self)
            inpCell=repmat({rand(7,7,7)<10},4*500,2);
            %
            self.aux_test_cellfunallelem(inpCell,@all);
            self.aux_test_cellfunallelem(inpCell,@any);
            %
            inpCell=repmat({rand(7,7,7)},4*500,2);
            self.aux_test_cellfunallelem(inpCell,@max);
            self.aux_test_cellfunallelem(inpCell,@min);
        end
    end
    methods
        function self=aux_test_cellfunallelem(self,inpCell,hFunc)
            import mxberry.core.cellfunallelem;
            %tic;
            res=cellfunallelem(hFunc,inpCell);
            %toc;
            resCheck=cellfun(@(x)hFunc(x(:)),inpCell);
            self.verifyEqual(isequal(res,resCheck),true);
            %
            %tic;
            res=cellfunallelem(hFunc,inpCell,'UniformOutput',false);
            %toc;
            resCheck=cellfun(@(x)hFunc(x(:)),inpCell,'UniformOutput',false);
            self.verifyEqual(isequal(res,resCheck),true);
        end
    end
    methods (Test)
        %
        function self=test_subreffrontdim(self)
            inp=[1 2;3 4];
            res=mxberry.core.subreffrontdim(inp,1);
            self.verifyEqual(res,[1 2]);
        end
        %
        function self=test_num2cell(self)
            inpArray=rand(3,20);
            self.aux_test_num2cell(inpArray);
            %
            inpMat=rand(2,3,4);
            resCellEthalon=num2cell(inpMat);
            resCell=mxberry.core.num2cell(inpMat);
            self.verifyEqual(true,isequal(resCell,resCellEthalon));
        end
        %
        function self=test_num2cell_empty(self)
            inpArray=zeros(3,0);
            self.aux_test_num2cell(inpArray);
        end
        %
    end
    methods
        function self=aux_test_num2cell(self,inpArray)
            resCellEthalon={inpArray(1,:);inpArray(2,:);inpArray(3,:)};
            resCell=mxberry.core.num2cell(inpArray,2);
            self.verifyEqual(true,isequal(resCell,resCellEthalon));
            %
        end
    end
    methods(Test)
        function self=test_iscelllogical(self)
            isTrue=mxberry.core.iscelllogical({true,false});
            self.verifyEqual(true,isTrue);
            isTrue=mxberry.core.iscelllogical({});
            self.verifyEqual(false,isTrue);
        end
    end
    methods
        function self=aux_test_iscellnumeric(self,isOk,isEmpty)
            sizeVec=[1 1];
            typeList={'single','double','int8','int16','int32','int64'};
            for iType=1:length(typeList)
                obj={mxberry.core.createarray(typeList{iType},sizeVec)};
                if isEmpty
                    obj(:)=[];
                end
                
                isTrue=mxberry.core.iscellnumeric(obj);
                self.verifyEqual(isOk,isTrue,...
                    ['failed for type ',typeList{iType}]);
            end
        end
    end
    methods (Test)
        function self=test_iscellnumeric(self)
            self.aux_test_iscellnumeric(true,false);
            self.aux_test_iscellnumeric(false,true);
        end
        %
        function self=test_isvec(self)
            isPositive=mxberry.core.iscol(rand(10,1));
            self.verifyEqual(isPositive,true);
            %
            isPositive=mxberry.core.iscol(rand(10,2));
            self.verifyEqual(isPositive,false);
            %
            isPositive=mxberry.core.iscol(zeros(0,1));
            self.verifyEqual(isPositive,true);
            %
            isPositive=mxberry.core.iscol(zeros(1,0));
            self.verifyEqual(isPositive,false);
            %
            isPositive=mxberry.core.iscol(zeros(0,0));
            self.verifyEqual(isPositive,false);
            %
            isPositive=mxberry.core.isvec(rand(10,1));
            self.verifyEqual(isPositive,true);
            isPositive=mxberry.core.isvec(rand(1,10));
            self.verifyEqual(isPositive,true);
            isPositive=mxberry.core.isvec(rand(1,1,10));
            self.verifyEqual(isPositive,false);
            %
            self.verifyEqual(mxberry.core.isrow(rand(10,1)),false);
            self.verifyEqual(mxberry.core.isrow(rand(1,10)),true);
            self.verifyEqual(mxberry.core.isrow([]),false);
            %
            self.verifyEqual(mxberry.core.isrow(zeros(0,1)),false);
            self.verifyEqual(mxberry.core.isrow(zeros(1,0)),true);
            %
            self.verifyEqual(mxberry.core.iscol(rand(10,1)),true);
            self.verifyEqual(mxberry.core.iscol(rand(1,10)),false);
            self.verifyEqual(mxberry.core.iscol([]),false);
            %
            self.verifyEqual(mxberry.core.isrow(rand(1,1,2)),false);
        end
        function self=test_error(self)
            inpArgList={'myTag','myMessage %d',1}; %#ok<NASGU>
            self.runAndCheckError(...
                'mxberry.core.test.aux.testerror(inpArgList{:})',...
                'MXBERRY:CORE:TEST:AUX:TESTERROR:myTag','myMessage 1');
        end
        function test_parseparext_touch(~)
            [reg,isRegSpec,putStorageHook,getStorageHook]=...
                mxberry.core.parseparext(...
                {},{...
                'putStorageHook','getStorageHook';...
                @(x,y)x,@(x,y)x;...
                @(x)isa(x,'function_handle'),@(x)isa(x,'function_handle')},...
                'regCheckList',...
                {@(x)isa(x,...
                'mxberry.core.struct.AStructChangeTracker')}); %#ok<ASGLU>
        end
        function self=test_parseparext_obligprop(self)
            inpProp={1,'aa',1,'bb',2,'cc',3};
            isObligatoryPropVec=[false false false];
            check();
            isObligatoryPropVec=[false false true];
            self.runAndCheckError(@check,':wrong');
            function check()
                [reg,isRegSpec,prop,isPropSpec]=...
                    mxberry.core.parseparext(inpProp,{'aa','bb','dd'},...
                    'propRetMode','list','isObligatoryPropVec',...
                    isObligatoryPropVec); %#ok<ASGLU>
            end
        end
        function test_parseparams_duplicate(self)
            self.runAndCheckError(@check,...
                'wrongInput:duplicatePropertiesSpec');
            self.runAndCheckError(@check1,...
                'wrongInput:duplicatePropertiesSpec');
            function check()
                mxberry.core.parseparams(...
                    {1,2,'prop1',1,'prop2',2,'prop2',3},{'prop1','prop2'},[0 2]);
            end
            function check1()
                mxberry.core.parseparams(...
                    {1,2,'prop1',1,'prop2',2,'prop2',3});
            end
        end
        function test_parseparext_isdefspecvec(self)
            self.runAndCheckError(@check,...
                'wrongInput:defPropSpecVecNotInListMode');
            self.runAndCheckError(@check2,...
                'wrongInput:defPropSpecVecNoDefValues');
            %
            [regList,isRegSpecVec,propList,isPropSpecVec]=check3();
            expPropList={'prop1',1,'prop3',2};
            expRegList={1,2};
            isExpRegSpecVec=[true,true];
            isExpPropSpecVec=[true,false,false];
            %
            expCompare();
            %
            [regList,isRegSpecVec,propList,isPropSpecVec]=check4();
            %
            expPropList={'prop1',1,'prop2',1,'prop3',2};
            %
            expCompare();
            function expCompare()
                self.verifyEqual(true,isequal(expRegList,regList));
                self.verifyEqual(true,isequal(expPropList,propList));
                self.verifyEqual(true,isequal(isExpRegSpecVec,isRegSpecVec));
                self.verifyEqual(true,isequal(isExpPropSpecVec,isPropSpecVec));
            end
            function check()
                mxberry.core.parseparext(...
                    {1,2,'prop1',1},...
                    {'prop1','prop2','prop3';...
                    [],1,2},'isDefaultPropSpecVec',[false,false,true],'propRetMode','separate');
            end
            function check2()
                mxberry.core.parseparext(...
                    {1,2,'prop1',1},...
                    {'prop1','prop2','prop3'},'isDefaultPropSpecVec',[false,false,true],'propRetMode','list');
            end
            function [regList,isRegSpec,propList,isPropSpec]=check3()
                [regList,isRegSpec,propList,isPropSpec]=mxberry.core.parseparext(...
                    {1,2,'prop1',1},...
                    {'prop1','prop2','prop3';...
                    [],1,2},'isDefaultPropSpecVec',[false,false,true],'propRetMode','list');
            end
            function [regList,isRegSpec,propList,isPropSpec]=check4()
                [regList,isRegSpec,propList,isPropSpec]=mxberry.core.parseparext(...
                    {1,2,'prop1',1},...
                    {'prop1','prop2','prop3';...
                    [],1,2},'propRetMode','list');
            end
        end
        function test_parseparext_duplicate(self)
            self.runAndCheckError(@check,...
                'wrongInput:duplicatePropertiesSpec');
            self.runAndCheckError(@check1,...
                'wrongInput:duplicatePropertiesSpec');
            function check()
                mxberry.core.parseparext(...
                    {1,2,'prop1',1,'prop2',2,'prop2',3},{'prop1','prop2'},[0 2]);
            end
            function check1()
                mxberry.core.parseparext(...
                    {1,2,'prop1',1,'prop2',2,'prop2',3},[],[0 2],...
                    'propRetMode','list');
            end
            mxberry.core.parseparext({'prop0',1,'prop1',1,'prop2',2},...
                {'prop1','prop2'},[0 2]);
        end
        function self=test_parseparext_simple(self)
            %
            inpReg={1};
            inpFirstProp={'aa',1};
            inpSecProp={'bb',2,'cc',3};
            inpProp=[inpFirstProp,inpSecProp];
            self.runAndCheckError(...
                'mxberry.core.parseparext(inpReg,[],''propRetMode'',''separate'')',...
                ':wrong');
            %
            [reg,isRegSpec,prop,isPropSpec]=...
                mxberry.core.parseparext([inpReg,inpProp],[],...
                'propRetMode','list');
            self.verifyEqual(3,length(isPropSpec));
            self.verifyEqual(true,all(isPropSpec));
            self.verifyEqual(true,isRegSpec);
            self.verifyEqual(true,isequal(reg,inpReg));%
            self.verifyEqual(true,isequal(prop,inpProp));%
            %
            [reg,isRegSpec,prop,isPropSpec]=...
                mxberry.core.parseparext([inpReg,inpProp],{'bb','cc'},...
                'propRetMode','list');
            self.verifyEqual([true,true,true],isRegSpec);
            self.verifyEqual(true,isequal(reg,[inpReg,inpFirstProp]));%
            self.verifyEqual(true,isequal(prop,inpSecProp));%
            self.verifyEqual(true,all(isPropSpec));
            self.verifyEqual(2,length(isPropSpec));
            %
            [reg,isRegSpec,prop,isPropSpec]=...
                mxberry.core.parseparext({},{'bb','cc'},...
                'propRetMode','list');
            self.verifyEqual(true,isempty(reg));
            self.verifyEqual(true,isempty(prop));
            self.verifyEqual(true,isempty(isRegSpec));
            self.verifyEqual(false,any(isPropSpec));
            self.verifyEqual(2,length(isPropSpec));
            %
            [reg,isRegSpec,prop,isPropSpec]=...
                mxberry.core.parseparext({},[],...
                'propRetMode','list');
            self.verifyEqual(true,isempty(reg));
            self.verifyEqual(true,isempty(prop));
            self.verifyEqual(true,isempty(isRegSpec));
            self.verifyEqual(true,isempty(isPropSpec));
            %
            nRegs=1;
            regDefList={1,3};
            nRegExpMax=[0,2];
            initInpArgList={1,'joinByInst',true,'keepJoinId',true};
            propCheckMat={'joinByInst','keepJoinId';...
                false,false;...
                'isscalar(x)&&islogical(x)','isscalar(x)&&islogical(x)'};
            %
            checkMaster();
            nRegExpMax=[1,2];
            checkMaster();
            %
            nRegExpMax=[0,1];
            checkN('regCheckList',{'true','true'});
            nRegExpMax=1;
            checkN('regCheckList',{'true','true'});
            %
            propCheckMat={'joinByInst','keepJoinId';...
                false,false;...
                @(x)isscalar(x)&&islogical(x),...
                @(x)isscalar(x)&&islogical(x)};
            nRegExpMax=[0,2];
            checkMaster();
            nRegExpMax=[1,2];
            checkMaster();
            nRegExpMax=[0,2];
            nRegs=0;
            initInpArgList={'joinByInst',true,'keepJoinId',true};
            checkMaster();
            %
            function checkMaster()
                checkP();
                checkP('regCheckList',{'true'});
                checkP('regCheckList',{@true});
                checkN('regCheckList','true');
                if nRegs>=1
                    checkN('regCheckList',{'false'});
                end
                checkP('regCheckList',{'true','true'});
                checkP('regCheckList',{@true,@true});
            end
            function checkN(varargin)
                inpArgList={initInpArgList,propCheckMat,nRegExpMax,...
                    varargin{:}}; %#ok<CCAT,NASGU>
                self.runAndCheckError(...
                    'mxberry.core.parseparext(inpArgList{:})',...
                    ':wrong');
            end
            function checkP(varargin)
                [reg1,isRegSpec1Vec]=checkPInt(varargin{:});
                [reg2,isRegSpec2Vec]=checkPInt(varargin{:},'regDefList',regDefList);
                if nRegs>=1
                    self.verifyEqual(true,isequal(reg1{1},reg2{1}));
                    self.verifyEqual(true,...
                        isequal(isRegSpec1Vec(1),isRegSpec2Vec(1)));
                end
                self.verifyEqual(false,isRegSpec2Vec(2));
                self.verifyEqual(true,isequal(nRegs,length(isRegSpec1Vec)));
                self.verifyEqual(true,isequal(2,length(isRegSpec2Vec)));
                self.verifyEqual(true,isequal(nRegs,length(reg1)));
                self.verifyEqual(true,isequal(2,length(reg2)));
                self.verifyEqual(true,isequal(3,reg2{2}));
                %
                inpArgList={initInpArgList,...
                    varargin{:},'regDefList',[regDefList,4]}; %#ok<CCAT,NASGU>
                self.runAndCheckError(...
                    'mxberry.core.parseparext(inpArgList{:})',...
                    ':wrong');
                %
                function [reg,isRegSpecVec]=checkPInt(varargin)
                    [reg,isRegSpecVec,isJoinByInst,isJoinIdKept]=...
                        mxberry.core.parseparext(initInpArgList,...
                        propCheckMat,nRegExpMax,...
                        varargin{:});
                    if nRegs>=1
                        self.verifyEqual(true,isRegSpecVec(1));
                        self.verifyEqual(true,isequal(reg(1:nRegs),{1}));
                    else
                        [~,prop]=mxberry.core.parseparams(varargin,{'regDefList'});
                        if isempty(prop)
                            self.verifyEqual(true,isempty(isRegSpecVec));
                            self.verifyEqual(true,isempty(reg));
                        else
                            self.verifyEqual(false,any(isRegSpecVec))
                            self.verifyEqual(length(prop{2}),...
                                length(reg));
                        end
                    end
                    %
                    self.verifyEqual(true,isJoinByInst);
                    self.verifyEqual(true,isJoinIdKept);
                end
            end
            
        end
        function self=test_parseparams(self)
            [reg,prop]=getparse({'alpha'});
            self.verifyEqual(true,isequal(reg,{'alpha'}));
            self.verifyEqual(true,isequal(prop,{}));
            %
            [reg,prop]=getparse({'alpha','beta',1});
            self.verifyEqual(true,isequal(reg,{'alpha'}));
            self.verifyEqual(true,isequal(prop,{'beta',1}));
            %
            [reg,prop]=getparse({'alpha',1,3,'beta',1});
            self.verifyEqual(true,isequal(reg,{'alpha',1,3}));
            self.verifyEqual(true,isequal(prop,{'beta',1}));
            %
            [reg,prop]=getparse({'alpha',1,3,'beta',1},{'alpha'});
            self.verifyEqual(true,isequal(reg,{3,'beta',1}));
            self.verifyEqual(true,isequal(prop,{'alpha',1}));
            %
            [reg,prop]=getparse({'alpha',1,3,'beta',1},{});
            self.verifyEqual(true,isequal(reg,{'alpha',1,3,'beta',1}));
            self.verifyEqual(true,isequal(prop,{}));
            %
            [reg,prop]=getparse({'alpha',1,3,'beta',1,'gamma',1},'gamma');
            self.verifyEqual(true,isequal(reg,{'alpha',1,3,'beta',1}));
            self.verifyEqual(true,isequal(prop,{'gamma',1}));
            %
            [reg,prop]=getparse({'alpha',1,3,'gamma',1,'beta',1},'gamma');
            self.verifyEqual(true,isequal(reg,{'alpha',1,3,'beta',1}));
            self.verifyEqual(true,isequal(prop,{'gamma',1}));
            %
            [reg,prop]=getparse({'alpha',1,3,'beta',1,'gamma',1},'Gamma');
            self.verifyEqual(true,isequal(reg,{'alpha',1,3,'beta',1}));
            self.verifyEqual(true,isequal(prop,{'gamma',1}));
            %
            [reg,prop]=getparse({'alpha',1},'beta');
            self.verifyEqual(true,isequal(reg,{'alpha',1}));
            self.verifyEqual(true,isequal(prop,{}));
            %
            [reg,prop]=getparse({'alpha',1},'beta',[0 2]);
            self.verifyEqual(true,isequal(reg,{'alpha',1}));
            self.verifyEqual(true,isequal(prop,{}));
            %
            [reg,prop]=getparse({1,'alpha'},'alpha');
            self.verifyEqual(true,isequal(reg,{1,'alpha'}));
            self.verifyEqual(true,isequal(prop,{}));
            %
            [reg,prop]=getparse(...
                {1,'alpha',3,'beta',3,'gamma'},{'alpha','gamma'});
            self.verifyEqual(true,isequal(reg,{1,'beta',3,'gamma'}));
            self.verifyEqual(true,isequal(prop,{'alpha',3}));
            function [reg,prop]=getparse(argList,varargin)
                if (nargin>1)
                    propInpNameList=varargin{1};
                    if isnumeric(propInpNameList)&&isempty(propInpNameList)
                        isPropNameSpec=false;
                    else
                        if ischar(propInpNameList)
                            propInpNameList={lower(propInpNameList)};
                        else
                            propInpNameList=lower(propInpNameList);
                        end
                        isPropNameSpec=true;
                    end
                else
                    isPropNameSpec=false;
                end
                %
                [reg,prop]=mxberry.core.parseparams(argList,varargin{:});
                %
                if isPropNameSpec&&numel([varargin{:}])>0
                    nPairs=length(propInpNameList);
                    outCell=cell(1,2*nPairs);
                    [reg1,~,outCell{:}]=...
                        mxberry.core.parseparext(argList,varargin{:});
                    %
                    [propValList,isSpecVec]=getval(outCell);
                    %
                    propNameList=propInpNameList;
                    %
                    self.verifyEqual(true,isequal(reg,reg1));
                    isEqual=isequal(propNameList,...
                        propInpNameList)||isempty(propNameList)&&...
                        isempty(propInpNameList);
                    self.verifyEqual(true,isEqual);
                    pNameList=propNameList(isSpecVec);
                    pValList=propValList(isSpecVec);
                    inpArgList=[pNameList;pValList];
                    s1=struct(inpArgList{:});
                    s2=struct(prop{:});
                    isEqual=isequal(s1,s2);
                    self.verifyEqual(true,isEqual);
                    %
                    if ~all(isSpecVec)
                        defValList=num2cell(rand(size(propNameList)));
                        [reg2,~,outCell{:}]=...
                            mxberry.core.parseparext(argList,...
                            [propNameList;defValList],varargin{2:end});
                        self.verifyEqual(true,isequal(reg,reg2));
                        [propValList,isSpecVec]=getval(outCell);
                        isEqual=isequal(propValList(~isSpecVec),...
                            defValList(~isSpecVec));
                        self.verifyEqual(true,isEqual);
                        %
                        checkStrList=repmat({'false'},size(defValList));
                        checkStrList(isSpecVec)={'true'};
                        [reg3,~,outCell{:}]=...
                            mxberry.core.parseparext(argList,...
                            [propNameList;defValList;...
                            checkStrList],varargin{2:end});
                        [propValList3,isSpecVec3]=getval(outCell);
                        self.verifyEqual(true,isequal(reg,reg3));
                        self.verifyEqual(true,isequal(propValList3,propValList));
                        self.verifyEqual(true,isequal(isSpecVec,isSpecVec3));
                    end
                end
                %
                function [propValList,isSpecVec]=getval(outCell)
                    propValList=outCell(1:nPairs);
                    isSpecVec=[outCell{nPairs+1:nPairs*2}];
                end
            end
        end
        function self=test_parseparams_negative(self)
            inpArgList={'alpha',1,3,'beta',1,'gamma',1};
            %
            [reg1,prop1]=mxberry.core.parseparams(inpArgList);
            [reg2,prop2]=mxberry.core.parseparams(inpArgList,[]);
            %
            self.verifyEqual(true,isequal(reg1,reg2));
            self.verifyEqual(true,isequal(prop1,prop2));
            %
            self.runAndCheckError(...
                'mxberry.core.parseparams(inpArgList,[],0);',...
                ':wrongParamList');
            mxberry.core.parseparams(inpArgList,[],3);
            mxberry.core.parseparams(inpArgList,[],3,[]);
            mxberry.core.parseparams(inpArgList,[],3,2);
            mxberry.core.parseparams(inpArgList,[],[],2);
            mxberry.core.parseparams(inpArgList,[],[3,3]);
            mxberry.core.parseparams(inpArgList,[],[3,3],[]);
            mxberry.core.parseparams(inpArgList,[],[3,6],2);
            mxberry.core.parseparams(inpArgList,[],[0,3],2);
            self.runAndCheckError(...
                'mxberry.core.parseparams(inpArgList,[],3,3);',...
                ':wrongParamList');
            %
            self.runAndCheckError(...
                'mxberry.core.parseparams(inpArgList,[],[0,3],2.5);',...
                ':wrongInput');
            %
            self.runAndCheckError(...
                'mxberry.core.parseparams(inpArgList,[],[],3);',...
                ':wrongParamList');
            self.runAndCheckError(...
                'mxberry.core.parseparams(inpArgList,[],3.5,3);',...
                ':wrongInput');
            self.runAndCheckError(...
                'mxberry.core.parseparams(inpArgList,[],[-3 3],2);',...
                ':wrongInput');
            self.runAndCheckError(...
                'mxberry.core.parseparams(inpArgList,[],[3.5 3.4],3);',...
                ':wrongInput');
            self.runAndCheckError(...
                'mxberry.core.parseparams(inpArgList,[],[3.5 3.4],3);',...
                ':wrongInput');
            self.runAndCheckError(...
                'mxberry.core.parseparams(inpArgList,[],[4 4],2);',...
                ':wrongParamList');
            self.runAndCheckError(...
                'mxberry.core.parseparams(inpArgList,[],[4 6],2);',...
                ':wrongParamList');
            self.runAndCheckError(...
                'mxberry.core.parseparams(inpArgList,[],[0 2],2);',...
                ':wrongParamList');
        end
        function self=test_getfirstdimsize(self)
            expSizeVec=[2,3];
            inpArray=rand([expSizeVec,4,5]);
            self.verifyEqual(expSizeVec,...
                mxberry.core.getfirstdimsize(inpArray,2));
            expSizeVec=[2,3,1];
            inpArray=rand([expSizeVec,1,1]);
            self.verifyEqual(expSizeVec,...
                mxberry.core.getfirstdimsize(inpArray,3));
            self.verifyEqual([expSizeVec,[1 1]],...
                mxberry.core.getfirstdimsize(inpArray,5));
            self.verifyEqual(true,...
                isempty(mxberry.core.getfirstdimsize(inpArray,0)));
            self.runAndCheckError(...
                'mxberry.core.getfirstdimsize(inpArray,-1)',...
                ':wrongInput');
            %
        end
        function self=test_checksize(self)
            
            self.verifyEqual(true,mxberry.core.checksize(rand(2,3),[2,3,1]));
            self.verifyEqual(true,mxberry.core.checksize(rand(2,3),[2,3]));
            self.verifyEqual(false,mxberry.core.checksize(rand(2,4),[2,3]));
            self.verifyEqual(false,mxberry.core.checksize(rand(2,4,5),[2,4]));
            self.verifyEqual(true,mxberry.core.checksize([],[]));
            self.verifyEqual(false,mxberry.core.checksize(1,[]));
        end
        function self=test_cat(self)
            typeList={'int8','double','logical','struct'};
            for iType=1:length(typeList)
                for jType=1:length(typeList)
                    iObj=mxberry.core.createarray(typeList{iType},[]);
                    jObj=mxberry.core.createarray(typeList{jType},[]);
                    res=mxberry.core.cat(1,iObj,jObj);
                    self.verifyEqual(true,...
                        isa(res,typeList{iType}));
                end
            end
        end
        function self=test_getcallernameext(self)
            testClassA=GetCallerNameExtTestClassA;
            [methodName,className]=getCallerInfo(testClassA); %#ok<*NCOMMA>
            self.verifyEqual(true,...
                isequal(methodName,'GetCallerNameExtTestClassA')&&...
                isequal(className,'GetCallerNameExtTestClassA'));
            testClassA=simpleMethod(testClassA);
            [methodName,className]=getCallerInfo(testClassA);
            self.verifyEqual(true,...
                isequal(methodName,'simpleMethod')&&...
                isequal(className,'GetCallerNameExtTestClassA'));
            testClassA=subFunctionMethod(testClassA);
            [methodName,className]=getCallerInfo(testClassA);
            self.verifyEqual(true,...
                isequal(methodName,'subFunctionMethod/subFunction')&&...
                isequal(className,'GetCallerNameExtTestClassA'));
            testClassA=subFunctionMethod2(testClassA);
            [methodName,className]=getCallerInfo(testClassA);
            self.verifyEqual(true,...
                isequal(methodName,'subFunctionMethod2/subFunction')&&...
                isequal(className,'GetCallerNameExtTestClassA'));
            testClassA=subFunctionMethod3(testClassA);
            [methodName,className]=getCallerInfo(testClassA);
            self.verifyEqual(true,...
                isequal(methodName,'subFunctionMethod3/subFunction/subFunction2')&&...
                isequal(className,'GetCallerNameExtTestClassA'));
            %
            testClassB=GetCallerNameExtTestClassB;
            [methodName,className]=getCallerInfo(testClassB);
            self.verifyEqual(true,...
                isequal(methodName,'GetCallerNameExtTestClassB')&&...
                isequal(className,'GetCallerNameExtTestClassB'));
            simpleMethod(testClassB);
            [methodName,className]=getCallerInfo(testClassB);
            self.verifyEqual(true,...
                isequal(methodName,'simpleMethod')&&...
                isequal(className,'GetCallerNameExtTestClassB'));
            subFunctionMethod(testClassB);
            [methodName,className]=getCallerInfo(testClassB);
            self.verifyEqual(true,...
                isequal(methodName,'subFunctionMethod/subFunction')&&...
                isequal(className,'GetCallerNameExtTestClassB'));
            subFunctionMethod2(testClassB);
            [methodName,className]=getCallerInfo(testClassB);
            self.verifyEqual(true,...
                isequal(methodName,'subFunctionMethod2/subFunction')&&...
                isequal(className,'GetCallerNameExtTestClassB'));
            subFunctionMethod3(testClassB);
            [methodName,className]=getCallerInfo(testClassB);
            self.verifyEqual(true,...
                isequal(methodName,'subFunctionMethod3/subFunction/subFunction2')&&...
                isequal(className,'GetCallerNameExtTestClassB'));
            %
            testClassB=getcallernameexttest.GetCallerNameExtTestClassB;
            [methodName,className]=getCallerInfo(testClassB);
            self.verifyEqual(true,...
                isequal(methodName,'GetCallerNameExtTestClassB')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassB'));
            simpleMethod(testClassB);
            [methodName,className]=getCallerInfo(testClassB);
            self.verifyEqual(true,...
                isequal(methodName,'simpleMethod')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassB'));
            subFunctionMethod(testClassB);
            [methodName,className]=getCallerInfo(testClassB);
            self.verifyEqual(true,...
                isequal(methodName,'subFunctionMethod/subFunction')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassB'));
            subFunctionMethod2(testClassB);
            [methodName,className]=getCallerInfo(testClassB);
            self.verifyEqual(true,...
                isequal(methodName,'subFunctionMethod2/subFunction')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassB'));
            subFunctionMethod3(testClassB);
            [methodName,className]=getCallerInfo(testClassB);
            self.verifyEqual(true,...
                isequal(methodName,'subFunctionMethod3/subFunction/subFunction2')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassB'));
            %
            testClassC=GetCallerNameExtTestClassC;
            [methodName,className]=getCallerInfo(testClassC);
            self.verifyEqual(true,...
                isequal(methodName,'GetCallerNameExtTestClassB')&&...
                isequal(className,'GetCallerNameExtTestClassB'));
            testClassC=GetCallerNameExtTestClassC(false);
            [methodName,className]=getCallerInfo(testClassC);
            self.verifyEqual(true,...
                isequal(methodName,'GetCallerNameExtTestClassC')&&...
                isequal(className,'GetCallerNameExtTestClassC'));
            simpleMethod(testClassC);
            [methodName,className]=getCallerInfo(testClassC);
            self.verifyEqual(true,...
                isequal(methodName,'simpleMethod')&&...
                isequal(className,'GetCallerNameExtTestClassC'));
            subFunctionMethod(testClassC);
            [methodName,className]=getCallerInfo(testClassC);
            self.verifyEqual(true,...
                isequal(methodName,'subFunctionMethod/subFunction')&&...
                isequal(className,'GetCallerNameExtTestClassC'));
            subFunctionMethod2(testClassC);
            [methodName,className]=getCallerInfo(testClassC);
            self.verifyEqual(true,...
                isequal(methodName,'subFunctionMethod2/subFunction')&&...
                isequal(className,'GetCallerNameExtTestClassB'));
            subFunctionMethod3(testClassC);
            [methodName,className]=getCallerInfo(testClassC);
            self.verifyEqual(true,...
                isequal(methodName,'subFunctionMethod3/subFunction/subFunction2')&&...
                isequal(className,'GetCallerNameExtTestClassC'));
            %
            testClassC=getcallernameexttest.GetCallerNameExtTestClassC;
            [methodName,className]=getCallerInfo(testClassC);
            self.verifyEqual(true,...
                isequal(methodName,'GetCallerNameExtTestClassB')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassB'));
            testClassC=getcallernameexttest.GetCallerNameExtTestClassC(false);
            [methodName,className]=getCallerInfo(testClassC);
            self.verifyEqual(true,...
                isequal(methodName,'GetCallerNameExtTestClassC')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassC'));
            simpleMethod(testClassC);
            [methodName,className]=getCallerInfo(testClassC);
            self.verifyEqual(true,...
                isequal(methodName,'simpleMethod')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassC'));
            subFunctionMethod(testClassC);
            [methodName,className]=getCallerInfo(testClassC);
            self.verifyEqual(true,...
                isequal(methodName,'subFunctionMethod/subFunction')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassC'));
            subFunctionMethod2(testClassC);
            [methodName,className]=getCallerInfo(testClassC);
            self.verifyEqual(true,...
                isequal(methodName,'subFunctionMethod2/subFunction')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassB'));
            subFunctionMethod3(testClassC);
            [methodName,className]=getCallerInfo(testClassC);
            self.verifyEqual(true,...
                isequal(methodName,'subFunctionMethod3/subFunction/subFunction2')&&...
                isequal(className,'getcallernameexttest.GetCallerNameExtTestClassC'));
            %
            methodName='';className='';
            s_getcallernameext_test;
            self.verifyEqual(true,...
                isequal(methodName,'s_getcallernameext_test')&&...
                isequal(className,''));
            %
            methodName='';className='';
            getcallernameexttest.s_getcallernameext_test;
            self.verifyEqual(true,...
                isequal(methodName,'getcallernameexttest.s_getcallernameext_test')&&...
                isequal(className,''));
            %
            [methodName,className]=getcallernameext_simplefunction();
            self.verifyEqual(true,...
                isequal(methodName,'getcallernameext_simplefunction')&&...
                isequal(className,''));
            [methodName,className]=getcallernameext_subfunction();
            self.verifyEqual(true,...
                isequal(methodName,'getcallernameext_subfunction/subfunction')&&...
                isequal(className,''));
            [methodName,className]=getcallernameext_subfunction2();
            self.verifyEqual(true,...
                isequal(methodName,'getcallernameext_subfunction2/subfunction')&&...
                isequal(className,''));
            [methodName,className]=getcallernameext_subfunction3();
            self.verifyEqual(true,...
                isequal(methodName,'getcallernameext_subfunction3/subfunction/subfunction2')&&...
                isequal(className,''));
            %
            [methodName,className]=getcallernameexttest.getcallernameext_simplefunction();
            self.verifyEqual(true,...
                isequal(methodName,'getcallernameexttest.getcallernameext_simplefunction')&&...
                isequal(className,''));
            [methodName,className]=getcallernameexttest.getcallernameext_subfunction();
            self.verifyEqual(true,...
                isequal(methodName,'getcallernameexttest.getcallernameext_subfunction/subfunction')&&...
                isequal(className,''));
            [methodName,className]=getcallernameexttest.getcallernameext_subfunction2();
            self.verifyEqual(true,...
                isequal(methodName,'getcallernameexttest.getcallernameext_subfunction2/subfunction')&&...
                isequal(className,''));
            [methodName,className]=getcallernameexttest.getcallernameext_subfunction3();
            self.verifyEqual(true,...
                isequal(methodName,'getcallernameexttest.getcallernameext_subfunction3/subfunction/subfunction2')&&...
                isequal(className,''));
        end
    end
end