% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
function outArray=repmat(inpArray,varargin)
if nargin==2&&isempty(varargin{1})
    outArray=mxberry.core.type.createarray(class(inpArray),[0 0]);
else
    outArray=repmat(inpArray,varargin{:});
end
