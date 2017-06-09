% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef SuiteBasic < matlab.unittest.TestCase
    properties (Access=private)
        map
        mapFactory
        rel1
        rel2
        testParamList
    end
    %
    methods
        function self = SuiteBasic(varargin)
            self = self@matlab.unittest.TestCase(varargin{:});
        end
    end
    methods (Test)
        %
        function testMapExtendedTricky(~)
            lenVec=1:200;
            nTries=length(lenVec);
            for iTry=1:nTries
                curLength=lenVec(iTry);
                key1=repmat('-',1,curLength);
                key2=[key1,'-'];
                check();
            end
            for iTry=1:nTries
                curLength=lenVec(iTry);
                keyPref=repmat('-',1,curLength);
                key1=[keyPref,'a',keyPref];
                key2=[keyPref,'b',keyPref];
                check();
            end
            function SRes=check()
                import mxberry.core.cont.MapExtended;
                mp=MapExtended({key1,key2},{1,2});
                SRes=mp.toStruct();
            end
        end
        function testMapExtendedSimple(self)
            key1='regTube_static_sp[x_1,x_2]_st5, lsGoodDirVec=[0;1],sTime=5_g1';
            key2='regTube_static_sp[x_1,x_2]_st5, lsGoodDirVec=[1;0],sTime=5_g1';
            check();
            %
            key1='---------------------------a----------------';
            key2='---------------------------b----------------';
            check();
            %
            key1='a';
            key2='b';
            SRes=check();
            SExp=struct('a',1,'b',2);
            %
            self.verifyEqual(true,isequal(SRes,SExp));
            %
            key1=sprintf(['Diameters for ',...
                '\nlsGoodDirVec=[0;0;0;0;1;0;0;0],sTime=4']);
            key2=sprintf(['Ellipsoid matrix traces for ',...
                '\nlsGoodDirVec=[0;0;0;0;1;0;0;0],sTime=4']);
            check();
            %
            key1='reachTube_dynamicalonggoodcurve_sp[x_1,x_3]_st4, lsGoodDirVec=[0;0;0;0;1;0;0;0],sTime=4_g1';
            key2='reachTube_dynamicalonggoodcurve_sp[x_1,x_3]_st4, lsGoodDirVec=[0;0;0.70711;0.70711;0;0;0;0],sTime=4_g1';
            check();
            %
            function SRes=check()
                import mxberry.core.cont.MapExtended;
                mp=MapExtended({key1,key2},{1,2});
                SRes=mp.toStruct();
            end
        end
        %
        function self=test_MapExtended(self)
            self.aux_testMapExtended('a','b','c','d','e');
        end
        %
        function self=test_MapExtended_ArbKey(self)
            self.aux_testMapExtended('a a','b b','c c','d d','e e');
        end
        %
        %
        function self=test_MapExtended_LongKey(self)
            self.aux_testMapExtended(repmat('a',1,300),...
                repmat('a',1,301),'c c','d d','e e');
        end
    end
    methods
        function self=aux_testMapExtended(self,aKey,bKey,cKey,dKey,eKey)
            import mxberry.core.cont.MapExtended;
            mp=MapExtended();
            mp(aKey)=1;
            mp(bKey)=2;
            mp(cKey)=MapExtended({dKey,eKey},{1,2});
            SRes=mp.toStruct();
            %
            key2FieldName=@MapExtended.key2FieldName;
            aVarKey=key2FieldName(aKey);
            bVarKey=key2FieldName(bKey);
            cVarKey=key2FieldName(cKey);
            dVarKey=key2FieldName(dKey);
            eVarKey=key2FieldName(eKey);
            %
            SExp=struct(aVarKey,1,bVarKey,2,cVarKey,...
                struct(dVarKey,1,eVarKey,2));
            %
            self.verifyEqual(true,isequal(SRes,SExp));
            mp2=mp.getCopy();
            checkIfEqual(true);
            mp(aKey)=2;
            checkIfEqual(false);
            %
            mp=MapExtended();
            mp2=mp.getCopy();
            checkIfEqual(true);
            mp(aKey)=2;
            checkIfEqual(false);
            
            function checkIfEqual(isPos)
                isPosExp=isequal(mp,mp2);
                [isPosAct,reportStr]=mp.isEqual(mp2);
                self.verifyEqual(isPosAct,isPosExp);
                self.verifyEqual(isPos,isPosAct,reportStr);
                mp3=mp.getCopy();
                isOk=isequal(mp,mp3);
                self.verifyTrue(isOk);
                [isOk,reportStr]=mp.isEqual(mp3);
                self.verifyTrue(isOk,reportStr);
                %
                if mxberry.core.isunique([mp.keys,mp2.keys])
                    mpA=mp.getUnionWith(mp2);
                    mpB=mp2.getUnionWith(mp);
                    [isOk,reportStr]=mpA.isEqual(mpB);
                    self.verifyTrue(isOk,reportStr);
                end
            end
        end
    end
end