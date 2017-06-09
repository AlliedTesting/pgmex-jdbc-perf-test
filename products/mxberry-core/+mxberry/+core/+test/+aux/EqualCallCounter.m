% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef EqualCallCounter<mxberry.core.obj.StaticPropStorage
    methods (Static)
        function [propVal,isThere]=getProp(propName,varargin)
            branchName=mfilename('class');
            [propVal,isThere]=mxberry.core.obj.StaticPropStorage.getPropInternal(...
                branchName,propName,varargin{:});
        end
        function setProp(propName,propVal)
            branchName=mfilename('class');
            mxberry.core.obj.StaticPropStorage.setPropInternal(...
                branchName,propName,propVal);
        end
        function flush()
            branchName=mfilename('class');
            mxberry.core.obj.StaticPropStorage.flushInternal(branchName);
        end
        function val=getEqCounter()
            import mxberry.core.test.aux.EqualCallCounter;
            [val,isThere]=EqualCallCounter.getProp('isEqCallCount',true);
            if ~isThere
                val=0;
            end
        end
        function setEqCounter(val)
            mxberry.core.test.aux.EqualCallCounter.setProp(...
                'isEqCallCount',val);
        end
        function incEqCounter(valInc)
            import mxberry.core.test.aux.EqualCallCounter;
            val=EqualCallCounter.getEqCounter();
            val=val+valInc;
            EqualCallCounter.setEqCounter(val);
        end
        %
        function checkNCallsEquality(fList)
            nFunc=numel(fList);
            callNumVec=nan(1,nFunc);
            for iFunc=1:nFunc
                callNumVec(iFunc)=getNCalls(fList{iFunc});
            end
            checkEqCalls(callNumVec(1:end-1),callNumVec(2:end));
        end
        %
        function checkNotSortableCalls(objVec)
            import mxberry.core.test.aux.EqualCallCounter;
            EqualCallCounter.checkNCallsEquality({...
                @()mxberry.core.ismemberjoint({objVec},{objVec(2:end)}),...
                @()ismember(objVec,objVec(2:end))});
            EqualCallCounter.checkNCallsEquality({...
                @()mxberry.core.ismemberjoint({objVec},{objVec}),...
                @()ismember(objVec,objVec)});
            EqualCallCounter.checkNCallsEquality({...
                @()unique(objVec),...
                @()mxberry.core.uniquejoint({objVec})});
        end
        %
        function checkCalls(objVec,isBuiltInsChecked)
            import mxberry.core.test.aux.EqualCallCounter;
            if nargin<2
                isBuiltInsChecked=true;
            end
            nRels=numel(objVec);
            %
            check(@()(isequal(objVec(1),objVec(2))),1);
            check(@()(isequaln(objVec(1),objVec(2))),1);
            check(@()(isequaln(objVec(1),objVec(2))),1);
            %
            nSortCalls=getNCalls(@()sort(objVec));
            sortedObjVec=sort(objVec);
            nDoubleSortCalls=getNCalls(@()sort([sortedObjVec,sortedObjVec]));
            doubleSortedObjVec=sort([sortedObjVec,sortedObjVec]);
            nHandleComparisons=sum(eq(doubleSortedObjVec(1:end-1),...
                doubleSortedObjVec(2:end),'asHandle',true));
            fUniqCplx=@(x)(x-1+nSortCalls);
            fIsMembCplx=@(x)(2*fUniqCplx(x)+2*x-1-nHandleComparisons+nDoubleSortCalls);
            %
            nCallsForBuiltInUniq=fUniqCplx(nRels);
            if ismethod(objVec,'sort')
                nCallsForUniqJoint=nCallsForBuiltInUniq;
            else
                nCallsForUniqJoint=nRels*(nRels-1)*0.5;
            end
            %
            if isBuiltInsChecked
                check(@()unique(objVec),nCallsForBuiltInUniq);
            end
            check(@()mxberry.core.uniquejoint({objVec}),nCallsForUniqJoint);
            %
            nEqCallsForBuiltInIsMember=fIsMembCplx(nRels);
            if isBuiltInsChecked
                check(@()ismember(objVec,objVec),nEqCallsForBuiltInIsMember);
            end
            check(@()mxberry.core.ismemberjoint({objVec},{objVec}),...
                nEqCallsForBuiltInIsMember);
            check(@()mxberry.core.ismember(objVec,objVec),...
                nEqCallsForBuiltInIsMember);
            %
            function check(fHandle,nExpCalls)
                nCalls=getNCalls(fHandle);
                checkEqCalls(nExpCalls,nCalls);
            end
        end
        function nCalls=getNCalls(fHandle)
            nCalls=getNCalls(fHandle);
        end
    end
end
function checkEqCalls(nExpCallVec,nCallVec)
isOk=isequal(nExpCallVec,nCallVec);
if ~isOk
    mxberry.core.throwerror('wrongState',...
        sprintf('Expected %s calls, Called %s times',...
        mat2str(nExpCallVec),mat2str(nCallVec)));
end
end
function nCalls=getNCalls(fHandle)
mxberry.core.test.aux.EqualCallCounter.setEqCounter(0);
%
feval(fHandle);
%
nCalls=mxberry.core.test.aux.EqualCallCounter.getEqCounter();

end
