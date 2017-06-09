% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef CompareRedirectAppliance<handle
    methods
        function varargout=unique(self,varargin)
            self.verifyTrue(false,['tested functions should not ',...
                'call ''unique'' function']);
            varargout={};
        end
        function varargout=ismember(self,varargin)
            self.verifyTrue(false,['tested functions should not ',...
                'call ''ismember'' function']);
            varargout={};
        end
    end
    %
end