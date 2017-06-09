% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef CreateArraySuite < mxberry.core.type.test.mlunit.ArrayTestPropForSuite
    methods
        function self = CreateArraySuite(varargin)
            self = self@mxberry.core.type.test.mlunit.ArrayTestPropForSuite(varargin{:});
        end
        function self = test_checkvaluematchisnull_mixedcell_sametype(self)
            value={{1 2 3};{1,2};{1}};
            STypeSizeInfo=mxberry.core.type.legacy.generatetypesizeinfostruct(value);
            isOk=mxberry.core.type.legacy.istypesizeinfouniform(STypeSizeInfo);
            self.verifyEqual(isOk,true);
            %
        end
        function self = test_checkvaluematchisnull_mixedcell_differenttype(self)
            value={{1 2 3};{'a','b'};{1}};
            STypeSizeInfo=mxberry.core.type.legacy.generatetypesizeinfostruct(value);
            isOk=mxberry.core.type.legacy.istypesizeinfouniform(STypeSizeInfo);
            self.verifyEqual(isOk,false);
            %
        end
        function aux_test_classname2typeinfo(self,typeList,sizeCVec)
            for iSize=1:length(sizeCVec)
                sizeVec=sizeCVec{iSize};
                STypeInfoCheckVec=cellfun(@mxberry.core.type.legacy.classname2typeinfo,...
                    typeList);
                objCell=arrayfun(@(x)mxberry.core.type.legacy.createarraybytypeinfo(...
                    x,sizeVec),...
                    STypeInfoCheckVec,'UniformOutput',false);
                %
                STypeSizeInfoVec=cellfun(@mxberry.core.type.legacy.generatetypesizeinfostruct,objCell);
                [~,STypeInfoVec]=...
                    arrayfun(@mxberry.core.type.legacy.istypesizeinfouniform,...
                    STypeSizeInfoVec);
                isEqualVec=cellfun(@isequal,num2cell(STypeInfoVec),...
                    num2cell(STypeInfoCheckVec));
                %
                self.verifyEqual(all(isEqualVec),...
                    true,['failed for size ',num2str(sizeVec)]);
            end
        end
        function self=test_classname2typeinfo(self)
            %
            sizeCVec={[1 10]};
            self.aux_test_classname2typeinfo(self.typeList,sizeCVec);
            %
            %
        end
        %
        function self=test_typeinfo2classname(self)
            typeList=self.typeList;
            typeList(end-1)=[];
            STypeInfoCheckVec=cellfun(@mxberry.core.type.legacy.classname2typeinfo,...
                typeList);
            resTypeList=cellfun(@mxberry.core.type.legacy.typeinfo2classname,...
                num2cell(STypeInfoCheckVec),'UniformOutput',false);
            self.verifyEqual(true,isequal(typeList,resTypeList));
        end
        %
        function aux_test_generatetypeinfostruct(self,typeList,sizeCVec,...
                isRelaxedComparison)
            if nargin<4
                isRelaxedComparison=false;
            end
            for iSize=1:length(sizeCVec)
                sizeVec=sizeCVec{iSize};
                STypeInfoCheckVec=cellfun(@mxberry.core.type.legacy.classname2typeinfo,...
                    typeList);
                objCell=arrayfun(@(x)mxberry.core.type.legacy.createarraybytypeinfo(...
                    x,sizeVec),...
                    STypeInfoCheckVec,'UniformOutput',false);
                %
                [isUniformVec,STypeInfoVec]=...
                    cellfun(@mxberry.core.type.legacy.generatetypeinfostruct,...
                    objCell);
                %
                self.verifyEqual(all(isUniformVec),true);
                %
                if isRelaxedComparison
                    fCompare=@isequal_relaxed;
                else
                    fCompare=@isequal;
                end
                isEqualVec=arrayfun(fCompare,STypeInfoVec,STypeInfoCheckVec);
                %
                self.verifyEqual(all(isEqualVec),true,...
                    ['failed for size ',mat2str(sizeVec)]);
            end
            function isPositive=isequal_relaxed(s1,s2)
                if isempty(s1.type)
                    isPositive=s1.depth<=s2.depth;
                else
                    isPositive=isequal(s1,s2);
                end
            end
        end
        function self=test_generatetypeinfostruct(self)
            sizeCVec={[1 10]};
            self.aux_test_generatetypeinfostruct(self.typeList,sizeCVec);
            sizeCVec={[]};
            self.aux_test_generatetypeinfostruct(self.typeList,sizeCVec,true);
            %
        end
        function self=test_generatetypeinfostruct_mixedtype(self)
            objCell={{{[1 2 3],{'aa','bb'}};{[1 2],[3 4]}}};
            
            STypeSizeInfoVec=cellfun(@mxberry.core.type.legacy.generatetypesizeinfostruct,objCell);
            [isUniformCheckVec,STypeInfoCheckVec]=...
                arrayfun(@mxberry.core.type.legacy.istypesizeinfouniform,...
                STypeSizeInfoVec);
            
            %
            [isUniformVec,STypeInfoVec]=...
                cellfun(@mxberry.core.type.legacy.generatetypeinfostruct,...
                objCell);
            %
            self.verifyEqual(isUniformCheckVec,isUniformVec);
            if any(isUniformVec)&&isequal(isUniformCheckVec,isUniformVec)
                isEqualVec=arrayfun(@isequal,STypeInfoVec(isUniformVec),STypeInfoCheckVec(isUniformVec));
                self.verifyEqual(all(isEqualVec),true);
            end
            %
        end
        function self=test_createarraybytypesizeinfo(self)
            sizeCVec=self.sizeCVec;
            typeList=self.typeList;
            for iSize=1:length(sizeCVec)
                sizeVec=sizeCVec{iSize};
                STypeInfoCheckVec=cellfun(...
                    @mxberry.core.type.legacy.classname2typeinfo,...
                    typeList);
                objCell=arrayfun(...
                    @(x)mxberry.core.type.legacy.createarraybytypeinfo(...
                    x,sizeVec),...
                    STypeInfoCheckVec,'UniformOutput',false);
                %
                isOkVec=cellfun(@(x)isequal(size(x),sizeVec),...
                    objCell);
                self.verifyEqual(true,all(isOkVec));
                %
                STypeSizeInfoVec=cellfun(...
                    @mxberry.core.type.legacy.generatetypesizeinfostruct,...
                    objCell);
                obj2Cell=...
                    arrayfun(...
                    @mxberry.core.type.legacy.createarraybytypesizeinfo,...
                    STypeSizeInfoVec,'UniformOutput',false);
                self.verifyEqual(isequal(objCell,obj2Cell),...
                    true,['failed for size ',num2str(sizeVec)]);
            end
        end
        function self=test_createvaluearray(self)
            sizeCVec=self.sizeCVec;
            typeList=self.typeList;
            for iSize=1:length(sizeCVec)
                %
                sizeVec=sizeCVec{iSize};
                STypeInfoCheckVec=cellfun(...
                    @mxberry.core.type.legacy.classname2typeinfo,...
                    typeList);
                %
                objCell=arrayfun(...
                    @(x)mxberry.core.type.legacy.createarraybytypeinfo(...
                    x,sizeVec),...
                    STypeInfoCheckVec,'UniformOutput',false);
                %
                isOkVec=cellfun(@(x)isequal(size(x),sizeVec),...
                    objCell);
                self.verifyEqual(true,all(isOkVec));
                %
                objEthalonCell=arrayfun(...
                    @(x)mxberry.core.type.legacy.createarraybytypeinfo(...
                    x,[1 1]),...
                    STypeInfoCheckVec,'UniformOutput',false);
                %
                obj2Cell=arrayfun(...
                    @(y,x)mxberry.core.type.createvaluearray(y{1}{1},...
                    x{1}(1),sizeVec),...
                    typeList,objEthalonCell,'UniformOutput',false);
                %
                self.verifyEqual(true,isequann(objCell,obj2Cell));
            end
        end
        function self=test_createvaluearray_handleType(self)
            nElem=10;
            obj1Vec=mxberry.core.type.createarray(...
                'mxberry.core.type.test.TestHandleType',[nElem 1]);
            obj2Vec=mxberry.core.type.createvaluearray(...
                'mxberry.core.type.test.TestHandleType',...
                mxberry.core.type.test.TestHandleType,[nElem 1]);
            value=rand(1);
            obj1Vec(1).setValue(value);
            obj2Vec(1).setValue(value);
            obj2Vec(1).setValue(value);
            for iElem=2:nElem
                self.verifyEqual(false,...
                    isequal(obj1Vec(1),obj1Vec(iElem)));
            end
            %
            self.verifyEqual(true,isequaln(obj1Vec,obj2Vec));
        end
        function self=test_createarraybytypeinfo_redundancy(self)
            sizeCVec=self.sizeCVec;
            typeList=self.typeList;
            for iSize=1:length(sizeCVec)
                %
                sizeVec=sizeCVec{iSize};
                STypeInfoCheckVec=cellfun(...
                    @mxberry.core.type.legacy.classname2typeinfo,...
                    typeList);
                %
                objCell=arrayfun(...
                    @(x)mxberry.core.type.legacy.createarraybytypeinfo(...
                    x,sizeVec),...
                    STypeInfoCheckVec,'UniformOutput',false);
                isOkVec=cellfun(@checkRedundancy,objCell);
                self.verifyEqual(true,all(isOkVec));
            end
            function isOk=checkRedundancyNested(inpArray)
                if iscell(inpArray)
                    isOkArray=cellfun(@checkRedundancyNested,inpArray);
                    isOk=all(isOkArray(:));
                else
                    isOk=isempty(inpArray);
                end
            end
            function isOk=checkRedundancy(inpArray)
                if iscell(inpArray)
                    isOk=checkRedundancyNested(inpArray);
                else
                    isOk=true;
                end
            end
        end
        function self=test_generatetypeinfostruct_Precise(self)
            %positive tests
            self.checkGenTypeInfo({},true,1,'');
            self.checkGenTypeInfo({{}},true,2,'');
            self.checkGenTypeInfo({{},{}},true,2,'');
            self.checkGenTypeInfo({{},{{}}},true,3,'');
            self.checkGenTypeInfo({{1},{2}},true,2,'double');
            self.checkGenTypeInfo({{1},{}},true,2,'double');
            self.checkGenTypeInfo({{'1'},{'2'}},true,2,'char');
            self.checkGenTypeInfo({{},{{1}},{}},true,3,'double');
            self.checkGenTypeInfo(1,true,0,'double');
            %negative tests
            self.checkGenTypeInfo({{1},{{}}},false);
            self.checkGenTypeInfo({{1},{{1}}},false);
            self.checkGenTypeInfo({{1},{'a'}},false);
            self.checkGenTypeInfo({{{'a'}},{'a'}},false);
            self.checkGenTypeInfo({{1},{true}},false);
        end
        function self=checkGenTypeInfo(self,value,...
                isUniformExp,expDepth,expType)
            if nargin<=3
                expDepth=nan;
                expType='';
            end
            %
            STypeInfoExp=struct('type',expType,'depth',expDepth);
            [isUniform,STypeInfo]=...
                mxberry.core.type.NestedArrayType.generatetypeinfostruct(value);
            self.verifyEqual(isUniformExp,isUniform);
            self.verifyEqual(true,isequaln(STypeInfoExp,STypeInfo));
            %
        end
        function self=test_createarray_negative(self)
            inpArgCombList={{{'int8'},[1 2]},...
                {'int8',[1;2]},...
                {'int8',{[1 2]}}};
            %
            for iArgComb=1:length(inpArgCombList)
                self.runAndCheckError(...
                    'mxberry.core.type.createarray(inpArgCombList{iArgComb})',...
                    ':wrongInput');
            end
        end
        function self=test_createarray(self)
            import mxberry.core.throwerror;
            sizeCVec=[self.sizeCVec,{[]}];
            typeList=self.simpleTypeNoCharList;
            for iSize=1:length(sizeCVec)
                for iType=1:length(typeList)
                    className=typeList{iType}{1};
                    errorMsg=sprintf('failed for type %s and size %s',...
                        className,mat2str(sizeCVec{iSize}));
                    %
                    try
                        resArray=mxberry.core.type.createarray(...
                            className,sizeCVec{iSize});
                    catch  meObj
                        newObj=throwerror('testFailed',errorMsg);
                        %
                        newObj=addCause(newObj,meObj);
                        throw(newObj);
                    end
                    
                    %
                    self.verifyEqual(true,...
                        mxberry.core.checksize(resArray,...
                        sizeCVec{iSize}),errorMsg);
                    %
                    self.verifyEqual(true,...
                        isa(resArray,className),errorMsg);
                end
            end
        end
    end
end