% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef TestValueType
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
        function self=TestValueType(value)
            if nargin==1
                if numel(value)==1
                    if isnumeric(value)
                        self.value=value;
                    elseif isa(value,'mxberry.core.type.test.TestValueType')
                        self=value;
                    else
                        mxberry.core.throwerror('wrongInput',...
                            'unsupported way to create an object');
                    end
                else
                    mxberry.core.throwerror('wrongInput',...
                        'vectorial type is not supported');
                end
            elseif nargin==0
                self.value=0;
            end
        end
        
    end
    
end
