% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef mlunit_test_xmlloadsave < mxberry.unittest.TestCase
    properties
        locDir
        fileName
        simpleData
        simpleMetaData
        xmlsaveParams
        resTmpDir
    end
    properties (MethodSetupParameter)
        argList={{},{'insertTimestamp',false},{'forceon'}};
        marker={'','insertTimestampFalse','forceon'};
    end
    %
    methods (TestMethodTeardown)
        function self = tearDown(self)
            mxberry.io.rmdir(self.resTmpDir,'s');
        end
    end
    methods (TestMethodSetup,ParameterCombination='sequential')
        function self=setUp(self,marker,argList)  %#ok<INUSL>
            import mxberry.xml.*;
            self.resTmpDir=mxberry.test.TmpDataManager.getDirByCallerKey();
            self.fileName=[self.resTmpDir,filesep,'tmp.xml'];
            Data.a=[1 2 3];
            Data.b=[1 2 3].';
            Data.c='sdfasdfa';
            Data.d='sdfasdfa'.';
            self.simpleData=Data;
            self.simpleMetaData=struct('version','0.1','someparam',...
                'abra-kadabra');
            self.xmlsaveParams=argList;
        end
    end
    methods
        function self = mlunit_test_xmlloadsave(varargin)
            import mxberry.xml.*;
            self = self@mxberry.unittest.TestCase(varargin{:});
            metaClass=metaclass(self);
            self.locDir=fileparts(which(metaClass.Name));
        end
    end
    methods (Test)
        function testTrickySize(self)
            Data.alpha={'alpha'.'};
            check();
            Data.theta.gamma={'alpha'.'};
            Data.beta=repmat('c',20,30);
            Data.vega=zeros(2,3,4);
            check();
            function check()
                import mxberry.xml.*;
                reg=mxberry.core.parseparams(self.xmlsaveParams);
                ResData=xmlparse(xmlformat(Data,reg{:}));
                self.verifyEqual(true,isequal(Data,ResData));
            end
        end
        
        function testEmpty(self)
            expVar=struct('alpha',zeros(1,0));
            check();
            expVar=zeros(1,0);
            check();
            function check()
                import mxberry.xml.*;
                resVar=xmlparse(xmlformat(expVar));
                self.verifyEqual(true,isequal(resVar,expVar));
            end
        end
        function self=testMultidimStructField(self)
            import mxberry.xml.*;
            SData.alpha(2,3).a=1;
            SRes=xmlparse(xmlformat(SData,'on'));
            self.verifyEqual(isequaln(SRes,SData),true);
        end
        function self = testInteger(self)
            import mxberry.xml.*;
            SData.a=int32([1,2,3]);
            SData.b=int64([1,2,3]);
            SData.c=uint64([1,2,3;2 3 3]);
            SData.d=uint32([1,2,3;4 2 4]);
            SData.a1=uint32([]);
            SData.b1=uint64([]);
            SData.c1=int64([]);
            SData.d1=int32([]);
            SData.test=SData;
            %
            self.xmlsave(self.fileName,SData);
            SRes=xmlload(self.fileName);
            self.verifyEqual(isequaln(SRes,SData),true);
        end
        function testNegative(self)
            import mxberry.xml.*;
            if verLessThan('matlab','R2016a')
                checkN(handle([1,2]));
            else
                checkP(handle([1,2]));
            end
            %
            checkN(complex([1,2],[1,2]));
            checkN(complex(int32([1,2]),int32([1,2])));
            checkN(sparse([1,2]));
            %
            function checkP(inpArray)
                SData.alpha=inpArray;
                self.xmlsave(self.fileName,SData);
            end
            function checkN(inpArray)
                SData.alpha=inpArray; %#ok<STRNU>
                self.runAndCheckError('self.xmlsave(self.fileName,SData);',...
                    ':wrongInput');
                
            end
        end
        function self = test_complexstructure(self)
            import mxberry.xml.*;
            Data(1)=mxberry.core.genteststruct(1);
            Data(2)=mxberry.core.genteststruct(2);
            self.xmlsave(self.fileName,Data);
            SRes=xmlload(self.fileName);
            self.verifyEqual(isequaln(SRes,Data),true);
            delete(self.fileName);
            %
            Data=mxberry.core.genteststruct(1);
            self.xmlsave(self.fileName,Data);
            SRes=xmlload(self.fileName);
            self.verifyEqual(isequaln(SRes,Data),true);
            delete(self.fileName);
        end
        function self = test_complexstructure_backwardcompatibility(self)
            import mxberry.xml.*;
            import mxberry.test.TmpDataManager;
            tmpDir=TmpDataManager.getDirByCallerKey();
            file1ElemShortName='test_complexstructure_1elem.xml';
            file1ElemName=[self.locDir,filesep,file1ElemShortName];
            file1ElemTmpName=[tmpDir,filesep,file1ElemShortName];
            fileArrayShortName='test_complexstructure_array.xml';
            fileArrayName=[self.locDir,filesep,fileArrayShortName];
            fileArrayTmpName=[tmpDir,filesep,fileArrayShortName];
            %
            SRes=xmlload(file1ElemName);
            self.xmlsave(file1ElemTmpName,SRes);
            SResTmp=xmlload(file1ElemTmpName);
            self.verifyEqual(isequaln(SRes,SResTmp),true);
            delete(file1ElemTmpName);
            %
            SRes=xmlload(fileArrayName);
            self.xmlsave(fileArrayTmpName,SRes);
            SResTmp=xmlload(fileArrayTmpName);
            self.verifyEqual(isequaln(SRes,SResTmp),true);
            delete(fileArrayTmpName);
        end
        function self = test_simple(self)
            import mxberry.xml.*;
            self.xmlsave(self.fileName,self.simpleData);
            SRes=xmlload(self.fileName);
            self.verifyEqual(isequaln(SRes,...
                self.simpleData),true)
            delete(self.fileName);
        end
        function self=test_simple_metadata(self)
            import mxberry.xml.*;
            self.xmlsave(self.fileName,self.simpleData,'on',self.simpleMetaData);
            [SRes,SMetaData]=xmlload(self.fileName);
            self.verifyTrue(isequaln(SRes,...
                self.simpleData));
            self.verifyTrue(isequal(SMetaData,...
                self.simpleMetaData));
        end
        function self=test_simple_metadata_negative(self)
            import mxberry.xml.*;
            self.runAndCheckError(@runWithFailure,':wrongInput');
            %
            function runWithFailure()
                metaData=self.simpleMetaData;
                metaData.badParam=zeros(1,3);
                self.xmlsave(self.fileName,self.simpleData,'on',metaData);
                self.verifyEqual(true,false);
            end
        end
        function self = test_parseFormatEmptyStruct(self)
            import mxberry.xml.*;
            self.verifyEqual(true,isequal(....
                struct(),...
                xmlparse(xmlformat(struct()),'on')));
            self.verifyEqual(true,isequal(....
                struct([]),...
                xmlparse(xmlformat(struct([])),'on')));
        end
    end
    methods
        function xmlsave(self,filePath,data,varargin)
            import mxberry.xml.*;
            [reg1,prop1]=mxberry.core.parseparams(varargin,...
                {'insertTimestamp'});
            [reg2,prop2]=mxberry.core.parseparams(self.xmlsaveParams);
            nReg1=numel(reg1);
            nReg2=numel(reg2);
            if nReg1<nReg2
                reg=[reg1,reg2(nReg1+1:end)];
            else
                reg=reg1;
            end
            xmlsave(filePath,data,reg{:},prop1{:},prop2{:});
        end
    end
end