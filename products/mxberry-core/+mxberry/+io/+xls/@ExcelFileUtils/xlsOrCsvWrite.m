function [isSuccess,SStatus,fileName]=xlsOrCsvWrite(fileName,dataMat,...
    varargin)
% XLSWRITE is an improved version of built-in xlswrite function. It uses a
% custom csvwrite function instead of dlmwrite to write data in csv format
% when Excel is not available. Additionally it returns a resulting file
% name argument as the third output parameter
%
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
%
import mxberry.core.throwerror;
import mxberry.log.log4j.Log4jConfigurator;
logger=Log4jConfigurator.getLogger();
%
N_MAX_XLS_ROWS=65536;
N_MAX_XLS_COLS=256;
%
[~,~,fileExt]=fileparts(fileName);
isXLSX=strcmpi(fileExt,'.xlsx');
%
isDataEmpty=isempty(dataMat);

isTooManyRows=~isXLSX&&(size(dataMat,1)>N_MAX_XLS_ROWS);
isTooManyCols=~isXLSX&&(size(dataMat,2)>N_MAX_XLS_COLS);
%
if isDataEmpty||isTooManyRows||isTooManyCols
    isWriteCSV=true;
    if isDataEmpty
        warnStr='data is empty';
    elseif isTooManyRows
        warnStr='too many rows';
    else
        warnStr='too many columns';
    end
    logger.warn(sprintf(['Result will be written to ',...
        'csv file, reason: %s'],warnStr));
else
    isExcelInstalled=mxberry.io.xls.ExcelFileUtils.isExcelInstalled();
    if ~isExcelInstalled
        logger.warn(['Cannot get access to Excel ActiveX ',...
            'server, using CSV format']);
        % write data as CSV file, that is, comma delimited.
        isWriteCSV=true;
    else
        isWriteCSV=false;
    end
end
%
if isWriteCSV
    fileName = regexprep(fileName,'(\.xls[^.]*+)$','.csv');
    try
        mxberry.core.cell.csvwrite(fileName,dataMat);
        isSuccess = true;
        SStatus.message='';
        SStatus.identifier='';
        %
    catch exception
        exceptionNew = throwerror('cantExportData',...
            'An error occurred on data export in CSV format.');
        exceptionNew = exceptionNew.addCause(exception);
        if nargout == 0
            % Throw error.
            throw(exceptionNew);
        else
            isSuccess = false;
            SStatus.message = exceptionNew.getReport;
            SStatus.identifier = exceptionNew.identifier;
            SStatus.exceptionObject=exceptionNew;
        end
    end
else
    [isSuccess,SStatus]=xlswrite(fileName,dataMat,varargin{:});
end