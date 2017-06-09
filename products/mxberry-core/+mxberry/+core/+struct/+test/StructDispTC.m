% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com>,
%          Alexander Karev <Alexander.Karev.30@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef StructDispTC < mxberry.unittest.TestCase %#ok<*NASGU>
    %
    properties (Access=private)
        testDataRootDir
        resTmpDir
    end
    methods
        function self = StructDispTC(varargin)
            self = self@mxberry.unittest.TestCase(varargin{:});
            [~,className]=mxberry.core.getcallernameext(1);
            shortClassName=mfilename('classname');
            self.testDataRootDir=[fileparts(which(className)),...
                filesep,'TestData',filesep,shortClassName];
        end
    end
    methods (TestMethodSetup)
        function self = set_up(self)
            self.resTmpDir=mxberry.test.TmpDataManager.getDirByCallerKey();
        end
    end
    methods (TestMethodTeardown)
        function self = tear_down(self)
            mxberry.io.rmdir(self.resTmpDir,'s');
        end
    end
    methods (Test)
        %
        function self = test_strucdisp(self)
            import mxberry.core.struct.strucdisp;
            S.name='';
            S.description=[]; %#ok<STRNU>
            %
            res=evalc('strucdisp(S)');
            ind=strfind(res,'name');
            self.verifyEqual(1,numel(ind));
            ind=strfind(res,'description');
            self.verifyEqual(1,numel(ind));
        end
        function testStruct2Str(self)
            import mxberry.core.struct.strucdisp;
            S.alpha=1;
            S.beta=2;
            S.gamma.alpha=1;
            S.gamma.beta=2;
            resStr=strucdisp(S);
            resStr2=mxberry.core.struct.struct2str(S);
            self.verifyEqual(true,isequal(resStr,resStr2));
        end
        function testStrucDispSimpleRegress(self)
            import mxberry.core.struct.strucdisp;
            S.alpha=1;
            S.beta=2;
            S.gamma.alpha=1;
            S.gamma.beta=2;
            expList={'|    ';...
                '|--- gamma';...
                '|       |    ';...
                '|       |-- alpha : 1';...
                '|       |--- beta : 2';...
                '|       O';...
                '|    ';...
                '|-- alpha : 1';...
                '|--- beta : 2'};
            check(S,expList);
            function check(S,expList)
                import mxberry.core.struct.strucdisp;
                inpArgList={S,'depth',2,'printValues',true};
                resStr=evalc('mxberry.core.struct.strucdisp(inpArgList{:})');
                resStr2=strucdisp(inpArgList{:});
                self.verifyEqual(true,isequal(resStr,resStr2));
                resList=textscan(resStr,'%s','delimiter','\n');
                resList=resList{1};
                self.verifyEqual(true,isequal(resList,expList));
            end
        end
        function testStrucDispRegress(self)
            %
            ARG_COMB_LIST={...
                {'depth',100,'printValues',false,'maxArrayLength',100},...
                {'depth',100,'printValues',true,'maxArrayLength',100},...
                {'depth',2,'printValues',true},...
                {'depth',100,'printValues',true},...
                {'depth',100,'printValues',false}};
            %
            methodName=mxberry.core.getcallernameext(1);
            inpFileName=[self.testDataRootDir,filesep,[methodName,'_inp.mat']];
            
            resMap=mxberry.core.cont.ondisk.HashMapMatXML(...
                'storageLocationRoot',self.testDataRootDir,...
                'storageBranchKey',[methodName,'_out'],'storageFormat','mat',...
                'useHashedPath',false,'useHashedKeys',true);
            SData=load(inpFileName);
            structNameList=fieldnames(SData);
            nFields=length(structNameList);
            nArgCombs=length(ARG_COMB_LIST);
            %
            %resTmpDir=self.resTmpDir;
            %resFileName=[resTmpDir,filesep,'out.txt'];
            for iField=1:nFields
                structName=structNameList{iField};
                S=SData.(structName);
                for iArgComb=1:nArgCombs
                    inpArgList=ARG_COMB_LIST{iArgComb};
                    resStr=evalc('mxberry.core.struct.strucdisp(S,inpArgList{:})');
                    inpKey=mxberry.core.hash({S,inpArgList});
                    SRes.S=S;
                    SRes.inpArgList=inpArgList;
                    SRes.resStr=resStr;
                    %
                    %resMap.put(inpKey,SRes);
                    SExpRes=resMap.get(inpKey);
                    [isPos,reportStr]=...
                        mxberry.core.struct.structcompare(SRes,SExpRes);
                    self.verifyEqual(true,isPos,reportStr);
                end
            end
            %
        end
        function testGetLeaveList(self)
            Data=mxberry.core.genteststruct(0);
            check();
            Data=struct();
            Data.alpha(2,1).a=2;
            Data.alpha(2,4).a=6;
            check();
            Data=struct();
            Data.alpha(1).a=2;
            Data.alpha(4).a=6;
            check();
            Data=struct();
            Data.alpha(2,1,5).a=2;
            Data.alpha(2,4,4).a=6;
            %
            check();
            function SRes=check()
                SRes=checkGetField();
                compare();
                SRes=checkValue();
                compare();
                %
                function compare()
                    [isEqual,reportStr]=mxberry.core.struct.structcompare(SRes,Data);
                    self.verifyEqual(true,isEqual,reportStr);
                    self.verifyEqual(true,isequaln(SRes,Data));
                end
                function SRes=checkValue()
                    [pathSpecList,valList]=mxberry.core.struct.getleavelist(Data);
                    nPaths=numel(pathSpecList);
                    SRes=struct();
                    for iPath=1:nPaths
                        SRes=setfield(SRes,pathSpecList{iPath}{:},...
                            valList{iPath});
                    end
                end
                function SRes=checkGetField()
                    pathSpecList=mxberry.core.struct.getleavelist(Data);
                    nPaths=numel(pathSpecList);
                    SRes=struct();
                    for iPath=1:nPaths
                        SRes=setfield(SRes,pathSpecList{iPath}{:},...
                            getfield(Data,pathSpecList{iPath}{:}));
                    end
                end
            end
        end
        function test_updateLeaves(self)
            import mxberry.core.struct.updateleavesext;
            SData.a.b=1;
            SRes=updateleavesext(SData,@fTransform);
            %
            SExp.a.bb=1;
            self.verifyEqual(true,isequal(SRes,SExp));
            %
            function [val,path]=fTransform(val,path)
                path{4}=repmat(path{4},1,2);
            end
        end
        function testGetUpdateLeaves(self)
            checkPathList(mxberry.core.struct.getleavelist(struct()));
            %
            SData.a.b=1;
            SData.a.c=20;
            SData.b.a.d=1;
            SData.c=10;
            SData.d='c';
            SData.alpha.beta.gamma.theta=2;
            SData.alpha.beta.gamma.delta='vega';
            SData.alpha.beta.gamma.delta2=1;
            %
            check();
            SData=struct();
            check();
            SData=mxberry.core.genteststruct(0);
            check();
            function check()
                SRes=mxberry.core.struct.updateleaves(SData,@(x,y)x);
                self.verifyEqual(true,...
                    isequaln(SData,SRes));
                SRes=mxberry.core.struct.updateleaves(SData,@fMinus);
                SRes=mxberry.core.struct.updateleaves(SRes,@fMinus);
                self.verifyEqual(true,...
                    isequaln(SData,SRes));
                %
                pathExpList=mxberry.core.struct.getleavelist(SData);
                pathList={};
                %
                mxberry.core.struct.updateleaves(SRes,@storePath);
                self.verifyEqual(true,isequal(pathList,pathExpList));
                %
                function value=storePath(value,subFieldNameList)
                    pathList=[pathList;{subFieldNameList}];
                end
                function x=fMinus(x,~)
                    if isnumeric(x)
                        x=-x;
                    end
                end
            end
            function checkPathList(pathList)
                import mxberry.core.check.lib.iscellofstring;
                self.verifyEqual(true,iscell(pathList));
                if ~isempty(pathList)
                    self.verifyEqual(true,...
                        all(cellfun('isclass',pathList,'cell')));
                    self.verifyEqual(true,...
                        iscellofstring([pathList{:}]));
                end
            end
        end
        
        function self = testArrays(self)
            import mxberry.core.struct.strucdisp;
            S = struct('a', 1);
            str = evalc('strucdisp(S)');
            isOk = ~isempty(strfind(str, '1'));
            
            S = struct('a', [1 2 3]);
            str = evalc('strucdisp(S)');
            isOk = isOk & ~isempty(strfind(str, '[1 2 3]'));
            
            S = struct('a', ones(5, 3, 2));
            str = evalc('strucdisp(S)');
            isOk = isOk & ~isempty(strfind(str, '[5x3x2 Array]'));
            
            self.verifyEqual(isOk, true);
        end
        %
        function self = testLogicalFields(self)
            import mxberry.core.struct.strucdisp;
            S = struct('a', false(1, 2));
            str = evalc('strucdisp(S)');
            isOk = ~isempty(strfind(str, '[false false]'));
            
            S = struct('a', false);
            str = evalc('strucdisp(S)');
            isOk = isOk & ~isempty(strfind(str, 'false'));
            
            S = struct('a', false(5));
            str = evalc('strucdisp(S)');
            isOk = isOk & ~isempty(strfind(str, '[5x5 Logic array]'));
            
            self.verifyEqual(isOk, true);
        end
        
        function self = testUpdateRegress(self)
            import mxberry.core.struct.strucdisp;
            ARG_COMB_LIST={...
                {'depth',100,'printValues',false,'maxArrayLength',100},...
                {'depth',100,'printValues',true,'maxArrayLength',100},...
                {'depth',2,'printValues',true},...
                {'depth',100,'printValues',true},...
                {'depth',100,'printValues',false}};
            %
            methodName=mxberry.core.getcallernameext(1);
            
            inpResMap=mxberry.core.cont.ondisk.HashMapMatXML(...
                'storageLocationRoot',self.testDataRootDir,...
                'storageBranchKey',[methodName '_inp'],'storageFormat','mat',...
                'useHashedPath',false,'useHashedKeys',true);
            outResMap=mxberry.core.cont.ondisk.HashMapMatXML(...
                'storageLocationRoot',self.testDataRootDir,...
                'storageBranchKey',[methodName '_out'],'storageFormat','mat',...
                'useHashedPath',false,'useHashedKeys',true);
            nArgCombs=length(ARG_COMB_LIST);
            %
            keyList=inpResMap.getKeyList();
            nKeys=numel(keyList);
            for iKey=1:nKeys
                keyName=keyList{iKey};
                SDataVec=inpResMap.get(keyName);
                for iArgComb=1:nArgCombs
                    inpArgList=ARG_COMB_LIST{iArgComb};
                    nElems=numel(SDataVec);
                    stDispObj=mxberry.core.struct.StructDisp(SDataVec(1),...
                        inpArgList{:});
                    for iElem=1:nElems
                        if iElem==1
                            rowIndVec=nan(0,1);
                            colIndVec=nan(0,1);
                        else
                            [rowIndVec,colIndVec]=...
                                stDispObj.update(SDataVec(iElem));
                        end
                        resStr=char(stDispObj);
                        SRes=struct(...
                            'S',{SDataVec(iElem)},...
                            'inpArgList',{inpArgList},...
                            'rowIndVec',{rowIndVec},...
                            'colIndVec',{colIndVec},...
                            'resStr',{resStr});
                        self.verifyEqual(true,isequal(resStr,...
                            strucdisp(SDataVec(iElem),inpArgList{:})));
                        inpKey=mxberry.core.hash({SDataVec(iElem),...
                            inpArgList});
                        %
                        SExpRes=outResMap.get(inpKey);
                        if isunix()&&(iKey==3)
                            %different behavior on Linux
                            SExpRes.resStr=strrep(SExpRes.resStr,...
                                '-1430.13','-1430.12');
                            SExpRes.resStr=strrep(SExpRes.resStr,...
                                '-3102.63','-3102.62');
                        end
                        [isPos,reportStr]=...
                            mxberry.core.struct.structcompare(SRes,SExpRes);
                        self.verifyEqual(true,isPos,reportStr);
                    end
                end
            end
            %
        end
    end
end