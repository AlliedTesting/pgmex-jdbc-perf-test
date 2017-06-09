function csvwrite(fileName,inpCMat,varargin)
% CSVWRITE writes a specified cell matrix into a comma-separated file
% specified by name. All columns of the matrix are expected to be of the
% same type. As of the moment only 'char' and all numeric types are
% supported
%
% Input:
%   regular:
%       fileName: char[1,] - name of the destination file
%       dataCMat: cell[nRows,nCols] - cell array containing numberic and
%          character data
%
%   properties:
%       delimiter: char[1,] - delimiter used for separating columns
%           Default: ','
%       columnNameList: cell[1,] of char[1,] - list of column names
%       numFormat: char[1,] - numbers display format string for
%           built-in sprintf function
%           Default: %10.10g
%
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
import mxberry.core.checkvar;
import mxberry.core.checkmultvar;
import mxberry.core.throwerror;
%
checkvar(fileName,'isstring(x)');
checkvar(inpCMat,'ismatrix(x)&&(iscell(x)||isnumeric(x))');
%
[~,~,delimStr,columnNameList,numFormatStr,~,isColumnNameListSpec]=...
    mxberry.core.parseparext(varargin,...
    {'delimiter','columnNameList','numFormat';...
    ',',[],'%10.10g';...
    'isscalar(x)&&ischar(x)','iscellofstring(x)&&isrow(x)',...
    'isstring(x)'},0);
if isColumnNameListSpec
    checkmultvar('numel(x1)==size(x2,2)',2,columnNameList,inpCMat);
end
%
[fid,messageStr] = fopen(fileName,'w');
if fid<0
    mxberry.core.throwerror('failedToOpenFile',...
        ['cannot create file %s for writing, reason:',messageStr],...
        datName);
end
%
%% We assume that values in each column has
nCols=size(inpCMat,2);
try
    if nCols>0
        if isnumeric(inpCMat)
            inpCMat=num2cell(inpCMat);
        end
        if isColumnNameListSpec
            fprintf(fid,['"%s"',repmat(',"%s"',1,nCols-1),'\n'],...
                columnNameList{:});
        end
        %
        isCharVec=cellfun('isclass',inpCMat(1,:),'char');
        isNumericVec=cellfun(@isnumeric,inpCMat(1,:));
        %
        if ~all(isCharVec|isNumericVec)
            isBadVec=~(isCharVec|isNumericVec);
            throwerror('wrongInput:wrongDataType',...
                ['only char and numeric types are supported, ',...
                'columns %s have unsupported type'],mat2str(find(isBadVec)));
        end
        %
        isCharMat=cellfun('isclass',inpCMat(:,isCharVec),'char');
        checkTypeOfAllRows(isCharMat,'char')
        %
        isNumericMat=cellfun(@isnumeric,inpCMat(:,isNumericVec));
        checkTypeOfAllRows(isNumericMat,'numeric')
        %
        formatStrList=cell(1,nCols);
        formatStrList(isCharVec)={'"%s"'};
        formatStrList(isNumericVec)={numFormatStr};
        %
        formatStr=[mxberry.core.string.catwithsep(formatStrList,delimStr),...
            '\n'];
        %
        inpCMat=inpCMat.';
        fprintf(fid,formatStr,inpCMat{:});
    end
    fclose(fid);
catch meObj
    fclose(fid);
    rethrow(meObj);
end
end
function checkTypeOfAllRows(isNeededTypeMat,typeName)
isColOfNeededType=all(isNeededTypeMat,1);
if ~all(isColOfNeededType)
    indCharColVec=find(isCharVec);
    throwerror('wrongInput:differentTypesOfRows',...
        'not all rows in columns %s have %s type',...
        mat2str(indCharColVec(~isColOfNeededType)),typeName);
end
end