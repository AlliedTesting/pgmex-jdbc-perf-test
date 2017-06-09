function [methodName,className]=getcallernameext(indStack)
% GETCALLERNAME determines function/script name or method name of caller
% together with class name in the case it is method of class for element
% of stack given by its index (this index is 1 for immediate caller of this
% function)
%
% Usage: methodName=getcallername() OR
%        [methodName,className]=getcallername()
%        methodName=getcallername(indStack) OR
%        [methodName,className]=getcallername(indStack)
%
% input:
%   optional:
%     indStack: double [1,1] - index of function/script or method in the
%         stack (this index is 1 for immediate caller of this function); by
%         default equals to 1 (i.e. immediate caller of this function)
% output:
%   regular:
%     methodName: char - name of function/script or method
%     className: char - empty if it is not a method of some class,
%        otherwise name of the corresponding class
%
% Note: 1) In the case a caller is a method of some class, className
%          contains also info on packages, otherwise info on packages is
%          included into methodName. Thus, for example, for method
%          PCAForecast of equivolent.forecast.pca.PCAForecast class we
%          would have:
%            methodName='PCAForecast';
%            className='equivolent.forecast.pca.PCAForecast';
%          If we have function mxberry.core.num2cell, then we would have
%            methodName='mxberry.core.num2cell';
%            className='';
%          The last is true also for scripts.
%       2) In the case a caller is a subfunction of some method or function
%          methodName contains also the whole path to this subfunction, for
%          instance, for subfunction subfunc of function
%          package.subpackage.func we would have:
%            methodName='package.subpackage.func/subfunc';
%            className='';
%          Analogous situation is for scripts and methods of classes.
%
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
%

StFunc=dbstack('-completenames');
if nargin==0
    indStack=1;
else
    if isequal(numel(StFunc),indStack)
        methodName='COMMAND_LINE';
        className='';
        return;
    end
    isnWrong=numel(indStack)==1&&isreal(indStack);
    if isnWrong
        isnWrong=floor(indStack)==indStack&&indStack>=0&&...
            indStack<=numel(StFunc)-1;
    end
    if ~isnWrong
        mxberry.core.throwerror('wrongInput','indStack is incorrect');
    end
end
[methodName,className]=mxberry.core.parsestackelem(StFunc(indStack+1));