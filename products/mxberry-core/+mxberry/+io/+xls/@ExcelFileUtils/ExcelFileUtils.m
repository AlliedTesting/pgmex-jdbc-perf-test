% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef ExcelFileUtils
    methods (Static)
        function [isPos,activeXObj]=isExcelInstalled()
            try
                activeXObj = matlab.io.internal.getExcelInstance;
                isPos=true;
            catch
                isPos=false;
                activeXObj=[];
            end
        end
        [success,theMessage,fileName]=xlsOrCsvWrite(fileName,dataMat,...
            varargin)
    end
    
end

