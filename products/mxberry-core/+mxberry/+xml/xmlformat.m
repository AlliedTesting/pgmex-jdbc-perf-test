function resXmlString = xmlformat(SData,attSwitch,name,level,SMetaData)
% XMLFORMAT formats the variable V into a name-based tag XML string xstr
%
% Input:
%   regular:
%      SData: any[]/struct[] - Matlab variable or structure.
%            The data types we can deal with are:
%              char,numeric,complex,struct,sparse,cell,logical/boolean
%            Not handled are data types:
%              function_handle,single,intxx,uintxx,java objects
%
%   optional:
%       attSwitch: char[1,]-   optional,'on'- writes attributes,
%           'off'- writes "plain" XML
%       name: char[1,] - optional,give root element a specific name,
%           eg. 'books'
%       level: double[1,1] -  internal,increases tab padding at
%           beginning of xstr
%       SMetaData: struct[1,1] - structure with meta information for
%           a root tag
%
% Output:
%   xstr: char[1,] - string,containing XML description of variable V
%
%
% $Author: Peter Gagarinov,PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov,PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
%
import mxberry.xml.*;
import mxberry.core.throwerror;
%
NL_SYMBOL = sprintf('\n');
SPRINTF_SPEC_NUMERIC='%0.16g ';
%
%
if nargin<1
    throwerror('wrongInput','SData is an obligatory input argument');
end
if nargin<2
    attSwitch = 'on';
else
    attSwitch=lower(attSwitch);
end
isForceAtt=strcmpi(attSwitch,'forceon');
isAtt=isForceAtt||strcmpi(attSwitch,'on');
%
if nargin<3 || isempty(name)
    name = 'root';
end
%
if nargin<4 || isempty(level)
    level = 0;
end
%
if nargin<5
    SMetaData=struct();
end
%
resXmlString = '';
if level==0
    paddingStr=char.empty(1,0);
else
    paddingStr(1,level)=' ';
    paddingStr(:)=sprintf('\t');
end
%
SAttributes.name = name;
SAttributes.type = getClass(SData);
%
if level==0
    fieldNameList=fieldnames(SMetaData);
    %
    attribList=strcat({' '},fieldNameList,'=',...
        cellfun(@(x)sprintf('"%s"',SMetaData.(x)),fieldNameList,...
        'UniformOutput',false));
    attributesStr=[attribList{:}];
    %
    if isAtt
        attributesStr = [attributesStr,' type="',SAttributes.type,'" '];
        if getIsNotRow(SData)
            sizeVec=size(SData);
            SAttributes.size = mynum2str(sizeVec);
            attributesStr=[attributesStr,...
                'size="',SAttributes.size,'"'];
        end
    end
    resXmlString = [resXmlString,'<',name,attributesStr];
end
%
if isempty(SData)
    resXmlString = [resXmlString,'/> ',NL_SYMBOL];
    return
end

nextLevel=level+1;
%
switch lower(SAttributes.type)
    
    case {'char','string'}
        %
        contentStr=charFuncSubstitute(SData(:).');
        resXmlString = [resXmlString,'>',contentStr,'</',name,'>',...
            NL_SYMBOL];
        %
    case 'struct'
        %
        resXmlString = [resXmlString,'>',NL_SYMBOL];
        fieldNameList = fieldnames(SData);
        nFields=numel(fieldNameList);
        nElem=numel(SData);
        %
        for iElem = 1:nElem
            for iField = 1:nFields
                %
                fieldName=fieldNameList{iField};
                SChild.content = SData(iElem).(fieldName);
                SChild.attributes = '';
                %
                if isAtt
                    SChild.att.idx = iElem;
                    SChild.att.type = getClass(SChild.content);
                    %
                    SChild.attributes = [' type="',SChild.att.type,'" '];
                    if nElem>1
                        SChild.attributes = [' idx="',...
                            sprintf('%d',iElem),'"',SChild.attributes];
                    end
                    if getIsNotRow(SChild.content)
                        sizeVec=size(SChild.content);
                        SChild.att.size = deblank(sprintf('%d ',sizeVec));
                        SChild.attributes=[SChild.attributes,...
                            'size="',SChild.att.size,'"'];
                    end
                end
                %
                resXmlString = [resXmlString,paddingStr,'<',...
                    fieldName,SChild.attributes];
                %
                str =xmlformat(SChild.content,attSwitch,fieldName,...
                    nextLevel);
                %
                resXmlString = [resXmlString,str];
            end
        end
        resXmlString = [resXmlString,paddingStr(1:end-1),'</',...
            name,'>',NL_SYMBOL];
        %
    case 'cell'
        resXmlString = [resXmlString,'>',NL_SYMBOL];
        nElem=numel(SData);
        for iElem=1:nElem
            SChild.content = SData{iElem};
            %
            resXmlString = [resXmlString,paddingStr,'<item']; %#ok<*AGROW>
            if isAtt
                SChild.att.idx = iElem;
                SChild.att.type = getClass(SChild.content);
                SChild.attributes = [' type="',SChild.att.type,'" '];
                %
                if getIsNotRow(SChild.content)
                    SChild.att.size = mynum2str(size(SChild.content));
                    SChild.attributes=[SChild.attributes,'size="',...
                        SChild.att.size,'"'];
                end
                resXmlString = [resXmlString,SChild.attributes];
            end
            % write content
            resXmlString = [resXmlString,xmlformat(SChild.content,...
                attSwitch,'item',nextLevel)];
        end
        resXmlString = [resXmlString,paddingStr(1:end-1),...
            '</',name,'>',NL_SYMBOL];
    otherwise
        try
            contentStr = sprintf(SPRINTF_SPEC_NUMERIC,SData(:));
        catch meObj
            newObj=mxberry.core.throwerror('wrongInput:wrongType',...
                'type %s is not supported',SAttributes.type);
            newObj=addCause(newObj,meObj);
            throw(newObj);
        end
        resXmlString = [resXmlString,'>',contentStr(1:end-1),...
            '</',name,'>',NL_SYMBOL];
end
    function className = getClass(inpVal)
        if isnumeric(inpVal)
            if ~isreal(inpVal)||issparse(inpVal)
                mxberry.core.throwerror('wrongInput:wrongType',...
                    'complex or sparse values are not supported');
            end
            %
        end
        className=class(inpVal);
    end
    function isPositive=getIsNotRow(inpArray)
        isPositive=isForceAtt||isempty(inpArray)||~isrow(inpArray);
    end
    function s=mynum2str(aVec)
        s=sprintf('%d ',aVec);
        s=s(1:end-1);
    end
end
%
function content=charFuncSubstitute(content)
content=strrep(content,'&','&amp;');
content=strrep(content,'<','&lt;');
content=strrep(content,'>','&gt;');
content=strrep(content,'''','&apos;');
content=strrep(content,'"','&quot;');
end