% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef mlunit_test_common < matlab.unittest.TestCase
    methods
        function self = mlunit_test_common(varargin)
            self = self@matlab.unittest.TestCase(varargin{:});
        end
    end
    methods (Test)
        function test_xlswrite(self)
            N_MAX_XLS_ROWS=65536;
            N_MAX_XLS_COLS=256;
            %
            s=warning('off',...
                'MXBERRY:IO:XLS:XLSWRITE:resultFileTypeChange');
            isXLSX=false;
            %
            checkMaster();
            isXLSX=true;
            checkMaster();
            %
            function checkMaster()
                check(cell(0,0));
                check(cell(N_MAX_XLS_ROWS+1,1));
                check(cell(1,N_MAX_XLS_COLS+1));
                check(repmat({'alpha'},100,100));
                check(zeros(100,100));
                %
                warning(s);
                check(cell(1,1));
            end
            %
            function check(dataCell)
                import mxberry.test.TmpDataManager;
                import mxberry.io.xls.ExcelFileUtils;
                import mxberry.core.MExceptionUtils;
                %
                if ~ispc()
                    return;
                end
                %
                dirName=TmpDataManager.getDirByCallerKey();
                if isXLSX
                    fileExt='xlsx';
                else
                    fileExt='xls';
                end
                %
                filePath=[dirName,filesep,'tmp.',fileExt];
                %
                isExcelInstalled=ExcelFileUtils.isExcelInstalled();
                %
                isEmpty=numel(dataCell)==0;
                isTooBig=(size(dataCell,1)>N_MAX_XLS_ROWS)||...
                    (size(dataCell,2)>N_MAX_XLS_COLS);
                %
                self.assertEqual(false,...
                    mxberry.io.isfile(filePath));
                [isSuccess,SStatus,resFilePath]=...
                    ExcelFileUtils.xlsOrCsvWrite(...
                    filePath,dataCell);
                %
                if isfield(SStatus,'exceptionObject')
                    diagnosticMsg=MExceptionUtils.me2HyperString(...
                        SStatus.exceptionObject);
                else
                    diagnosticMsg=SStatus.message;
                end
                self.assertTrue(isSuccess,diagnosticMsg);
                %
                if isExcelInstalled&&~isEmpty&&(~isTooBig||isXLSX)
                    isOk=mxberry.io.isfile(filePath);
                    self.assertEqual(true,isOk);
                    %
                    self.assertEqual(true,...
                        strcmp(resFilePath,filePath));
                else
                    self.assertEqual(true,...
                        strcmp(strrep(resFilePath,...
                        'csv',fileExt),filePath));
                    self.assertEqual(true,...
                        mxberry.io.isfile(resFilePath));
                end
            end
        end
    end
end