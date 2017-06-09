function valueMat=createarraybytypesizeinfo(STypeSizeInfoInp,varargin)
% CREATEARRAYBYTYPESIZEINFO generates an array based on TYPESIZEINFO
% structure
%
% Input:
%   regular:
%       STypeSizeInfo: struct[1,1]
%   properties:
%       'createIsNull' logical [1,2] with the first elemnt switching
%       creation of isNull on and off and the second one responsible for
%          choosing a value of is-null indicator
%
% Output
%   valueMat []
%
% Example:
%   valueMat=createarraybytypesizeinfo(STypeSizeInfoInp,'createIsNull',[true false])
%
% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
valueMat=mxberry.core.type.createarraybytypesizeinfo(...
    STypeSizeInfoInp,varargin{:});