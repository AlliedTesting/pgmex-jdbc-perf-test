% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef TestHandleType<handle
    properties (Access=protected)
        value
    end
    %
    methods
        function disp(self)
            fprintf('CurValue (size: %s, value: %s) \n',...
                mat2str(size(self)),...
                mat2str(reshape([self.value],size(self))));
        end
        function setValue(self,value)
            if numel(self)~=1
                mxberry.core.throwerror('wrongInput',...
                    'method is not supported for a vectorial objects');
            end
            if numel(value)~=1
                mxberry.core.throwerror('wrongInput',...
                    'input value should be scalar');
            end
            self.value=value;
        end
        function value=getValue(self)
            value=self.value;
        end
        function self=TestHandleType(value)
            if nargin==1
                if numel(value)==1
                    if isnumeric(value)
                        self.value=value;
                    elseif isa(value,'mxberry.core.type.test.TestHandleType')
                        self.value=value.value;
                    else
                        mxberry.core.throwerror('wrongInput',...
                            'unsupported way to create an object');
                    end
                else
                    mxberry.core.throwerror('wrongInput',...
                        'vectorial input is not supported');
                end
            elseif nargin==0
                self.value=0;
            end
        end
        
    end
    
end
