function xmlsave( fileName, SData, varargin)
% XMLSAVE saves structure or variable(s) to a file using XML format
%
% Input:
%   regular:
%       fileName: char[1,] -     filename
%       SData: any[]/struct[], -   Matlab variable or structure to store
%           in file.
%
%   optional:
%       attSwitch: char[1,]  - optional, 'on' stores XML type attributes (default),
%                'off' doesn't store XML type attributes
%       SMetaData: struct[1,1] - structure containing a meta information
%           to be stored in the  resulting xml file, empty by default
%
%   properties:
%       isTsInserted: logical[1,1] when false, timestamp is not recorded
%          into resulting xml file, true by default
%
% Output:
%   none:
%
%
% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
%
import mxberry.xml.*;
import mxberry.core.throwerror;
import mxberry.core.check.checkgen;
import mxberry.core.check.lib.isstring;
%
checkgen(fileName,'isstring(x)');
if nargin<2
    throwerror('wrongInput','SData is an obligatory input argument');
end
%
[reg,~,isTsInserted]=mxberry.core.parseparext(varargin,...
    {'insertTimestamp';true;'islogical(x)&isscalar(x)'},[0 2],...
    'regDefList',{'on',struct()},...
    'regCheckList',...
    {@(x)isstring(x)&&ismember(x,{'on','off','forceon'}),...
    @(x)isstruct(x)&&isscalar(x)&&all(structfun(@ischar,x))});
%
attSwitch=reg{1};
SMetaData=reg{2};
%
if isempty(strfind(lower(fileName),'.xml'))
    fileName = strcat(fileName, '.xml');
end
%
[fid,errMsg] = fopen(fileName, 'w');
if fid==-1
    throwerror('wrongInput:badFile',...
        'Failed to open file %s for writing: %s',fileName,errMsg);
end
%
fprintf(fid, '<?xml version="1.0"?>\n');
%
if isTsInserted
    fprintf(fid, sprintf('<!-- written on %s -->\n', datestr(now)));
end
%
try
    fprintf(fid, '%s', xmlformat(SData, attSwitch,'root',0,SMetaData));
    fclose(fid);
catch meObj
    fclose(fid);
    rethrow(meObj);
end