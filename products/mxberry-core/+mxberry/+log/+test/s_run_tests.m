%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
curLoc=fileparts(mfilename('fullpath'));
testFileName=[curLoc,filesep,'test_file.txt'];
obj=mxberry.log.EmailLogger(...
    'emailAttachmentNameList',{testFileName},...
    'emailAttachmentZippedNameList',{[testFileName '.zip']},...
    'subjectSuffix','for trunk_iv_database_1_29 on blue1',...
    'loggerName','IVMetricsCalculator');
obj.sendMessage('calculation started','calculation started');
obj.sendMessage('calculation started');