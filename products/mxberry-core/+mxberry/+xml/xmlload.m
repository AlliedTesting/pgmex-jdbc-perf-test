function [SData,SMetaData] = xmlload(fileName)
% XMLLOAD loads XML file and converts it into Matlab structure or variable.
%
% Input:
%   regular:
%       file: char[1,] -  filename of xml file written with xmlsave
%
% Output:
%   SData: any/struct[1,1] - variable of arbitrary type/structure
%       loaded from xml file
%   SMetaData: struct[1,1] - structure containing a meta-infromation loaded
%       from the specified file at the root level
%
%
% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
import mxberry.xml.*;
import mxberry.core.throwerror;
[~,~,extStr]=fileparts(fileName);
if isempty(extStr)
    fileName = strcat(fileName, '.xml');
elseif ~isequal(lower(extStr),'.xml')
    mxberry.core.throwerror('wrongInput',...
        'fileName should point to an xml file');
end
%
%-----------------------------------------------
% check existence of file
if ~mxberry.io.isfile(fileName)
    throwerror('wrongInput:fileDoesntExist','Could not find %s',fileName);
end
%-----------------------------------------------
%Use java parser as a temporary tool to check that xml is well-formed
try
    %calling built-in xml read function
    xmlread(fileName);
catch meObj
    newMeObj=throwerror('wrongInput:notWellFormedFile',...
        'xml is not well formed');
    newMeObj=newMeObj.addCause(meObj);
    throw(newMeObj);
end
%-----------------------------------------------
[fid,errMsgStr] = fopen(fileName, 'r');
if fid==-1
    throwerror('wrongInput:couldNotOpen',...
        'Could not open file %s for reading, reason: %s',fileName,...
        errMsgStr);
end

% parse file content into blocks
contentStr = fread(fid,'*char').'; % read in whole file
fclose( fid );

if numel(contentStr)<3
    throwerror('wrongInput:notValidFile',...
        '%s does not seem to be a valid xml file.',...
        fileName);
end
%-----------------------------------------------
% parse content, identify blocks
[SData,SMetaData] = mxberry.xml.xmlparse(contentStr);