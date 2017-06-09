% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
function shortName=shortcapstr(longName)
isSpaceVec=isspace(longName);
longName(isSpaceVec)='_';
isTakenVec=isstrprop(longName,'upper');
isUscrVec=longName=='_';
isDigitVec=isstrprop(longName,'digit');
isTakenVec=(isTakenVec|isDigitVec|[false,isDigitVec(1:end-1)]|isUscrVec|...
    [false,isUscrVec(1:end-1)])&~isSpaceVec;
isTakenVec(1)=true;
shortName=longName(isTakenVec);