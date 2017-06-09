function [SData, SMetaData] = xmlparse(inpXmlString, attSwitch, SData,...
    level)
% XMLPARSE parses XML string str and returns matlab variable/structure.
% This is a non-validating parser!
%
% Input:
%   regular:
%       inpXmlString: char[1,] -  xml string, possibly loaded from a file
%       via "xmlload"
%
%   optional:
%       attSwitch: char[1,]  'on'- reads attributes, 'off'- ignores 
%           attributes
%       SData: any/struct[] -  Variable which gets extended 
%           or whose  substructure parameters get overridden by entries in
%           the string.
%
% Output:
%
%   SData: any/struct[1,1] - matlab variable or structure
%   SMetaData structure with meta data stored in the root tag
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
import mxberry.core.check.checkgen;
%
if nargin<4
    level=0;
    if nargin<3
        SData = struct([]); 
        if nargin<2
            attSwitch='on';
        else
            checkgen(attSwitch,@(x)ismember(x,{'on','off'}));
        end
    end
end
%
if isempty(inpXmlString)
    return
end
% define variables
%
if level==0
    SMetaData=struct();
end
%---------------------------
% remove all <! execute and comment entries from str by blanking out
execpos = getFindStr('<!--',inpXmlString);
if ~isempty(execpos)
    allclose = getFindStr('-->',inpXmlString);
    for x=1:length(execpos)
        xstart   = execpos(x);
        idxclose = find(allclose > xstart);
        xend     = allclose(idxclose(1));
        inpXmlString(xstart:(xend+2)) = blanks(xend-xstart+3);
    end
end
%
indParOpenedVec = find(inpXmlString=='<'&[inpXmlString(2:end)~='/',true]);
%
indParClosedVec = sort( [getFindStr(inpXmlString, '</'), ...
    getFindStr(inpXmlString, '/>'), ...
    getFindStr(inpXmlString, '-->'), ...
    getFindStr(inpXmlString, '?>')] );

%
if numel(indParOpenedVec) ~= numel(indParClosedVec)
    throwerror('wrongInput:badFile',['XML parse error: Number of ',...
        'element start and end tags does not match.']);
end
%
nParOpened = length(indParOpenedVec);
parOpenCloseCountVec=[-ones(nParOpened,1);ones(nParOpened,1)];
[indParOpenedSortedVec,indParForwardSortedVec]=sort([indParOpenedVec,indParClosedVec]);
parIndexMat=[indParOpenedSortedVec.',parOpenCloseCountVec(indParForwardSortedVec)];
%
iElem=1;
nParentheses = 0;
itemCount=0;
while iElem<=size(parIndexMat,1)
    itemCount=itemCount+1;
    indEntryStart = parIndexMat(iElem,1);
    nParentheses = nParentheses + parIndexMat(iElem,2);
    while nParentheses ~= 0
        iElem = iElem+1;
        nParentheses = nParentheses + parIndexMat(iElem,2);
    end
    indEntryEnd = parIndexMat(iElem,1);
    tmp = inpXmlString(indEntryStart+1:indEntryEnd-1);
    %
    typeStr = '';
    indexStr=[];
    %
    headsep = getFindStr(tmp,'>');
    if isempty(headsep)
        % deal with "/>" empty elements by using the whole tmp string
        headsep = length(tmp);
    end
    
    namesep = min([getFindStr(tmp,' '), getFindStr(tmp,'>')]);
    if isempty(namesep)
        tagStr = tmp;
    else
        tagStr = tmp(1:namesep-1);
    end
    
    header  = tmp(namesep+1:headsep);
    content = tmp(headsep+1:end);
    
    % make sure that we have size [0 0] and not [1 0]
    if isempty(content)
        content = '';
    end
    
    % parse header for attributes
    att_lst = header;
    %
    tokens=regexp([' ' att_lst],'\s([^=]*)="([^"]*)"','tokens');
    %
    isSizeSpecified=false;
    if strcmp(attSwitch, 'on')
        for k=1:1:length(tokens)
            switch(tokens{k}{1})
                case 'idx'
                    indexStr = str2double(tokens{k}{2});
                case 'size'
                    sizeVec = str2num(tokens{k}{2}); %#ok<ST2NM>
                    isSizeSpecified=true;
                case 'type'
                    typeStr = tokens{k}{2};
                otherwise
                    if level==0
                        SMetaData.(tokens{k}{1})=tokens{k}{2};
                    end
            end
        end
    end
    if ~isSizeSpecified
        if strcmpi(typeStr,'struct')
            sizeVec=[1 1];
        else
            sizeVec=[0 0];
        end
    end
    nElems=prod(sizeVec);
    %
    isnEmpty=~all(sizeVec==0);
    % special names
    switch (tagStr(1))
        case {'?', '!'}
            % ignore entity declarations and processing instructions
            % Note: we also ignore the <?xml ...> entry with version number.
            iElem=iElem+1;
            continue;
    end
    if isempty(typeStr)
        typeStr = 'char';
    end
    % remove namespace from NAME
    indEntry = getFindStr(tagStr,':');
    if ~isempty(indEntry)
        tagStr = tagStr(indEntry+1:end);
    end
    
    % remove namespace from TYPE
    indEntry = find(typeStr==':');
    if ~isempty(indEntry)
        typeStr = typeStr(indEntry+1:end);
    end
    
    % make sure TYPE is valid
    if isempty(tagStr) || isempty(typeStr)
        throwerror('wrongInput','NAME or TYPE is empty!')
    end
    
    % check if type is correct
    if strcmp(typeStr, 'char') && any(content=='<')
        if strcmp(attSwitch, 'on')
            typeStr = 'struct';
        else
            typeStr = 'parent';
        end
    end
    
    % check if index is correct
    if indexStr==0
        indexStr = [];
    end
    
    if ~isempty(SData) && isfield(SData, tagStr) && isempty(indexStr)
        cont_list = {SData.(tagStr)};
        found = 0;
        % this loop makes sure that the current entry is inserted
        % after the last non-empty entry in the content vector cont_list
        for cc=length(cont_list):-1:1
            if ~isempty(cont_list{cc})
                found=1;
                break
            end
        end
        if ~found
            indexStr = max(cc-1,1);
        else
            indexStr = cc+1;
        end
    end
    
    if isempty(indexStr) && ~isempty(SData) && strcmp(tagStr, 'item')
        % make sure that when we have a character array the IDX of the
        % new vector is set to 2 and not to the end+1 index of the string.
        if isa(SData, 'char')
            indexStr = 2;
        else
            indexStr = length(SData)+1;
        end
    end
    
    if isempty(indexStr)
            indexStr = 1;
    end
    
    % switch board which decides how to convert contents according to TYPE
    switch lower(typeStr)
        
        % ========================
        case '?xml'
            %do nothing
        case '!--'
            % comment, just ignore
            iElem = iElem+1;
            continue
            
            % ========================
        case {'logical', 'boolean'}
            c = logical(str2num(content)); %#ok<ST2NM>
            if isnEmpty
                c = reshape(c, sizeVec);
            end
            
            % ========================
        case {'char', 'string'}
            c = charFuncReSubstitute(content);
            if isempty(c) && (length(c) ~= nElems)
                % this is a string containing only spaces
                c = blanks(nElems);
            end
            %
            if isnEmpty
                c = reshape(c, sizeVec);
            end
            
            % ========================
        case {'struct' , 'parent'}
            c = xmlparse(content, attSwitch, struct(), level+1);
            
            if ~(nElems==1)
                c = reshape(c, sizeVec);
            end
            
            if isfield(c, 'item') && strcmp(typeStr, 'struct')
                c = {c.item};
            end
            
            % ========================
        case 'cell'
            tmp_c = xmlparse(content, attSwitch, {}, level+1);
            
            if isnEmpty
                tmp_c = reshape(tmp_c, sizeVec);
            end
            
            if ~isempty(tmp_c)
                if isfield(tmp_c, 'item')
                    c = {tmp_c.item};
                else
                    % otherwise leave as is.
                    c = tmp_c;
                end
            else
                c = {};
            end
            % ========================
            % NUMERIC TYPE
        otherwise
            %c = feval(TYPE,str2num(content));
            c = feval(typeStr,sscanf(content,'%f').');
            if isnEmpty
                c = reshape(c, sizeVec);
            end
    end
    
    % now c contains the content variable
    
    if isempty(SData) && indexStr==1 && level==0
        if strcmp(tagStr, 'item')
            % s = '<item>aaa</item>'
            SData = {};
            SData(indexStr) = {c}; %#ok<AGROW>
        else
            % s = '<root>aaa</root>'
            SData = c;
        end
        
    elseif isempty(SData) && indexStr==1 && level>0
        if strcmp(tagStr, 'item')
            % s = '<root><item>bbb</item></root>'
            % s = '<root><item idx="1">a</item><item idx="2">b</item></root>'
            SData = {};
            SData(indexStr) = {c}; %#ok<AGROW>
        else
            % s = '<root><a>bbb</a></root>'
            %X = setfield(X, {IDX}, NAME, c);
            SData(indexStr).(tagStr)=c;
        end
        
    elseif isempty(SData) && indexStr>1 && level==0
        % s = '<root idx="4">hello</root>'
        % s = '<item idx="4">hello</item>'
        SData = {};
        SData(indexStr) = {c}; %#ok<AGROW>
        
    elseif isempty(SData) && indexStr>1 && level>0
        % s = '<root><ch idx="4">aaaa</ch></root>'
        % s = '<item><ch idx="4">aaaa</ch></item>'
        if strcmp(tagStr, 'item')
            SData = {};
            SData(indexStr) = {c}; %#ok<AGROW>
        else
            %X = setfield(X, {IDX}, NAME, c);
            SData(indexStr).(tagStr)=c;
        end
        
    elseif ~isempty(SData) && indexStr==1 && level==0
        % s = '<item idx="3">aaa</item><item idx="1">bbb</item>'
        if strcmp(tagStr, 'item')
            SData(indexStr) = {c};
        else
            if ~(nargin<3)
                % Example: a.b = 111; d = xmlparse(str, '', a);
                % this only works if both are structs and X is not empty
                if isempty(SData) || ~(isa(SData, 'struct') && isa(c, 'struct'))
                    SData = c;
                else
                    % transfer all fields from c to X
                    N = fieldnames(c);
                    for n=1:length(N)
                        %X = setfield(X, {IDX}, N{n}, c.(N{n}));
                        SData(indexStr).(N{n})=c.(N{n});
                    end
                end
            else
                % s = '<root idx="3">aaa</root><root idx="1">bbb</root>'
                % s = '<root>aaa</root><root>bbb</root>'
                % s = '<a><b>444</b></a><a><b>555</b></a>'
                throwerror('wrongInput',...
                    ['XML string cannot have two ''root'' ',...
                    'entries at root level! \n',...
                    'Possible solution: Use ''item'' tags instead.']);
            end
        end
        
    elseif ~isempty(SData) && indexStr==1 && level>0
        
        if strcmp(tagStr, 'item')
            % s = '<root><item idx="2">bbb</item><item idx="1">ccc</item></root>'
            SData(indexStr) = {c};
        else
            % s = '<root><a idx="2">bbb</a><a idx="1">ccc</a></root>'
            %X = setfield(X, {IDX}, NAME, c);
            %idxCell=num2cell(IDX);
            SData(indexStr).(tagStr)=c;
        end
        % BUT:
        % s = '<root><a idx="2"><b>ccc</b></a><a idx="1">ccc</a></root>'
        % fails because struct a has different content!
        
    elseif ~isempty(SData) && indexStr>1 && level==0
        
        % s = '<item idx="1">a</item><item idx="2">b</item>'
        % s = '<item idx="1">a</item><item idx="2">b</item><item idx="3">c</item>'
        if isa(SData,'char')
            % s = '<item idx="1">a</item><item idx="2">b</item>'
            SData = {SData};
            %else (if not char) we would have eg the third entry as X
            %s = '<item idx="1">a</item><item idx="2">b</item><item idx="3">c</item>'
            %and do not need to take action
        end
        SData(indexStr) = {c};
        
    elseif ~isempty(SData) && indexStr>1 && level>0
        
        % s = '<root><item idx="1">a</item><item idx="2">b</item><item idx="3">c</item></root>'
        if strcmp(tagStr, 'item')
            if isa(SData,'char')
                % s = '<root><item idx="1">a</item><item idx="2">b</item></root>'
                SData = {SData};
            end
            SData(indexStr) = {c};
        else
            % s = '<root><a>bbb</a><a>ccc</a></root>'
            %X = setfield(X, {IDX}, NAME, c);
            SData(indexStr).(tagStr)=c;
        end
        
    else
        
        disp('This case cannot be processed:')
        disp(['isempty(X) = ', num2str(isempty(SData))])
        disp(['class(X)   = ', class(SData)])
        disp(['class(c)   = ', class(c)])
        disp(['IDX        = ', num2str(indexStr)])
        disp(['LEVEL      = ', num2str(level)])
        disp('Please contact the author m.molinari@soton.ac.uk!');
    end
    
    clear c;
    iElem = iElem+1;
    
end


function inpStr = charFuncReSubstitute(inpStr)
%
inpStr=strrep(inpStr,'&amp;','&');
inpStr=strrep(inpStr,'&lt;','<');
inpStr=strrep(inpStr,'&gt;','>');
inpStr=strrep(inpStr,'&apos;','''');
inpStr=strrep(inpStr,'&quot;','"');
%


function indVec = getFindStr(longStr, shortStr)
% find positions of occurences of string str in longstr
if size(longStr,2) < size(shortStr,2)
    indVec=[];
else
    indVec = strfind(longStr,shortStr);
end