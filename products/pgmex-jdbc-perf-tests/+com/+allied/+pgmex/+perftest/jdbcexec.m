function varargout = jdbcexec(commandStr, varargin)
persistent isnJarAdded;
if isempty(isnJarAdded)
    isnJarAdded = true;
end
if isnJarAdded
    pathStr = [...
        fileparts(mfilename('fullpath')) filesep...
        'postgresql-9.4.1212.jre7.jar'];
    if ~ismember(pathStr,javaclasspath)
        javaaddpath(pathStr);
    end
    isnJarAdded = false;
end
if nargin == 0
    varargout = {};
    return;
end
if strcmpi(commandStr,'connect')
    connStr = varargin{1};
    serverStr = getConnElement('host',connStr);
    portStr = getConnElement('port',connStr);
    if ~isempty(portStr)
        serverStr = [serverStr ':' portStr];
    end
    varargout{1} = database(...
        getConnElement('dbname',connStr),...
        getConnElement('user',connStr),...
        getConnElement('password',connStr),'Vendor','PostgreSQL',...
        'Server',serverStr);
    return;
elseif strcmpi(commandStr,'finish')
    close(varargin{1});
    return;
elseif strcmpi(commandStr,'status')
    varargout{1}=~isconnection(varargin{1});
    return;
end
switch lower(commandStr)
    case {'exec','pqexec'}
        setdbprefs('DataReturnFormat','cellarray');
        varargout{1} = fetch(exec(varargin{:}));
    %case 'paramexec'
    case 'clear'
        close(varargin{1});
    case 'ntuples'
        varargout{1} = rows(varargin{1});
    case 'nfields'
        varargout{1} = cols(varargin{1});
    case 'fname'
        colNameCVec = columnnames(varargin{1}, true);
        varargout{1} = colNameCVec{varargin{2}+1};
    case 'fnumber'
        colNameCVec = columnnames(varargin{1}, true);
        colInd = find(strcmp(colNameCVec, varargin{2}), 1);
        if isempty(colInd)
            colInd = -1;
        end
        varargout{1} = colInd;
    case 'fsize'
        varargout{1} = width(varargin{1}, varargin{2}+1);
    case 'binarytuples'
        varargout{1} = true;
    case 'getvalue'
        curVal = varargin{1}.Data{varargin{2}+1,varargin{3}+1};
        if isjava(curVal)
            if ismethod(curVal,'getString')
                curVal=getString(curVal);
            elseif ismethod(curVal,'doubleValue')
                curVal=doubleValue(curVal);
            elseif ismethod(curVal,'toString')
                curVal=toString(curVal);
            end
        end
        varargout{1} = curVal;
    otherwise
        mxberry.core.throwerror('wrongInput',...
            'command %s can not be performed', commandStr);
end
end
function elemValStr=getConnElement(elemNameStr,connStr)
    patternStr=[elemNameStr '='];
    indElem=strfind(connStr,patternStr);
    if numel(indElem)>1
        mxberry.core.throwerror('wrongInput',...
            'connection string has wrong format');
    end
    if isempty(indElem)
        elemValStr='';
        return;
    end
    indStart=indElem+numel(patternStr);
    indEnd=find(connStr(indStart:end)==' ',1,'first');
    if isempty(indEnd)
        indEnd=numel(connStr);
    else
        indEnd=indStart+indEnd-2;
    end
    elemValStr=connStr(indStart:indEnd);
end