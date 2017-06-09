%REFLECTIONHELPER - serves a single purpose: retrieving a name of
%                   currently constructed object
%
% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef ReflectionHelper<handle
    methods
        function self=ReflectionHelper(valBox)
            if ~isa(valBox,'mxberry.core.cont.ValueBox')
                mxberry.core.throwerror('wrongInput',...
                    'Input is expected to be a boxed value object');
            end
            valBox.setValue(metaclass(self));
        end
    end
end