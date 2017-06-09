% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef HandleObjectClonerAdv<mxberry.core.obj.test.HandleObjectCloner
    properties
        beta
    end
    %
    methods
        function self=HandleObjectClonerAdv(beta,varargin)
            self=self@mxberry.core.obj.test.HandleObjectCloner(varargin{:});
            if nargin>0
                self.beta=beta;
            end
        end
    end
    %
    methods
        function setCompMode(self,compMode)
            switch compMode
                case 'blob'
                    self.setComparisonMode(...
                        mxberry.core.obj.ObjectComparisonMode.Blob);
                case 'user'
                    self.setComparisonMode(...
                        mxberry.core.obj.ObjectComparisonMode.UserDefined);
            end
        end
        function self=disp(self)
            S.alpha=arrayfun(@(x)x.alpha,self);
            S.beta=arrayfun(@(x)x.beta,self);
            mxberry.core.struct.strucdisp(S);
        end
    end
    %
    methods (Static)
        function objVec=create(alphaVec,betaVec)
            nObj=numel(alphaVec);
            for iObj=nObj:-1:1
                alpha=alphaVec(iObj);
                beta=betaVec(iObj);
                objVec(iObj)=...
                    mxberry.core.obj.test.HandleObjectClonerAdv(beta,alpha);
            end
        end
    end
end