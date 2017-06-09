function outStr=showcell(inpCArr,varargin)
% SHOWCELL generates a string representation of cell array or displays it
% in a console
%
%   Input:
%       regular:
%           inpCArr: cell[] - cell array of arbitrary dimension
%       properties:
%           nSpaces: numeric[1,1]  - column spacing.
%               Default is 4.
%           nDigits: numeric[1,1] - maximum number of significant digits
%               in the output string,specified as a positive integer.
%               Default is 5.
%           printVarName: logical[1,1] - if true (default),variable name is
%               printed when no output arguments is requested
%           varName: char[1,] - variable name to print,by default it is
%               determined automatically
%           showClass: logical[1,1] - if true, a class of numeric values is
%               displayed in the format used by the built-in 'mat2str'
%               function
%           asExpression: logical[1,1] - if true, the output string is
%               displayed as Matlab expression.
%           nMaxShownArrayElems: double[1,1] - maximum number of scalar
%               array elements show "as is"; if an array has more elements or
%               more than 1 dimension its content is not shown, only type
%               and size information
%
%
% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%       Faculty of Computational Mathematics and Computer Science,
%       System Analysis Department$
%
import mxberry.core.throwerror;
if ~iscell(inpCArr)
    throwerror('wrongInput','This is not a cell array');
end
%
[~,~,nSpaces,nDigits,isVarNamePrinted,varName,isClassShown,...
    isAsExpression,nMaxShownArrayElems,...
    ~,isNDigitsSpec,~,isVarNameSpec]=...
    mxberry.core.parseparext(varargin,...
    {'nSpaces','nDigits','printVarName','varName','showClass',...
    'asExpression','nMaxShownArrayElems';...
    4,15,false,[],false,false,10;...
    'isnumeric(x)&&isscalar(x)','isnumeric(x)&&isscalar(x)',...
    'islogical(x)&&isscalar(x)','isstring(x)',...
    'islogical(x)&&isscalar(x)','islogical(x)&&isscalar(x)',...
    'isnumeric(x)&&isscalar(x)&&(fix(x)==x)&&(x>=0)'},0);
%
if isNDigitsSpec
    fNumPrint=@(x)numArr2str(x,isAsExpression,isClassShown,nDigits);
else
    fNumPrint=@(x)numArr2str(x,isAsExpression,isClassShown);
end
fCharPrint=@(x)charArr2str(x,isAsExpression);
fCellPrint=@(x)mxberry.core.cell.showcell(x,varargin{:});
%
if ~isVarNameSpec&&isVarNamePrinted
    varName=inputname(1);
    if isempty(varName)
        varName='ans';
    end
end
%
sizeVec=size(inpCArr);
areAllFirstDimsZeros=max(sizeVec)==0;
areAnyFirstDimsZeros=min(sizeVec)==0;
%
nRestDims=ndims(inpCArr) - 2;
%
if nRestDims==0&&areAllFirstDimsZeros
    if isAsExpression
        lineStrList={'cell.empty(0,0)'};
    else
        lineStrList={'{}'};
    end
else
    if isAsExpression
        if areAnyFirstDimsZeros
            lineStrList={getEmptyStr(inpCArr)};
        else
            lineStrList=showCellInternal(inpCArr,nSpaces,fNumPrint,...
                fCharPrint,fCellPrint,...
                true,nMaxShownArrayElems);
        end
    else
        if areAnyFirstDimsZeros
            dimList=arrayfun(@(x)sprintf('%d',x),sizeVec,...
                'UniformOutput',false);
            lineStrList={sprintf('Empty cell array: %s\n',...
                mxberry.core.string.catwithsep(dimList,'-by-'))};
        else
            if (nRestDims>0)
                indDimVecList=cell(nRestDims,1);
                %
                nHigherDimElems=prod(sizeVec(3:end));
                %
                [indDimVecList{:}]=ind2sub(sizeVec(3:end),...
                    transpose(1:nHigherDimElems));
                indMat=horzcat(indDimVecList{:});
                indElemVecList=mat2cell(indMat,...
                    ones(1,nHigherDimElems),nRestDims);
                %
                isElemNumPrinted=true;
            else
                nHigherDimElems=1;
                isElemNumPrinted=false;
            end
            %
            listOflineStrList=cell(1,nHigherDimElems);
            for iHigherDimElem=1:nHigherDimElems
                curPartCMat=inpCArr(:,:,iHigherDimElem);
                %
                lineStrList=showCellInternal(curPartCMat,nSpaces,fNumPrint,...
                    fCharPrint,fCellPrint,false,nMaxShownArrayElems);
                if isElemNumPrinted
                    elemNumStr=['(:,:',sprintf(',%d',...
                        indElemVecList{iHigherDimElem}),')'];
                    nSymbols=numel(elemNumStr);
                    blankStubStr=repmat(' ',1,nSymbols);
                    linePrefixList=cell(size(lineStrList));
                    linePrefixList{1}=elemNumStr;
                    if numel(linePrefixList)>1
                        linePrefixList{2:end}=blankStubStr;
                    end
                    lineStrList=strcat(linePrefixList,lineStrList);
                end
                listOflineStrList{iHigherDimElem}=lineStrList;
            end
            %
            lineStrList=vertcat(listOflineStrList{:});
        end
    end
end
if isVarNamePrinted
    linePrefix=sprintf('%s=\n',varName);
    lineStrList=vertcat(linePrefix,lineStrList);
end
if nargout==0
    fprintf('%s\n',lineStrList{:});
else
    outStr=mxberry.core.string.catwithsep(lineStrList,sprintf('\n'));
end
%%

function lineStrList=showCellInternal(inpCMat,nSpaces,fNumPrint,...
    fCharPrint,fCellPrint,isAsExpression,nMaxShownArrayElems)
inpCVec=inpCMat(:);
isCellVec=cellfun('isclass',inpCVec,'cell');
isLogicalVec=cellfun('isclass',inpCVec,'logical');
isCharVec=cellfun('isclass',inpCVec,'char');
[~,isNumericVec]=mxberry.core.iscellnumeric(inpCVec);
%
if isAsExpression
    isSpecialEmptyVec=isCharVec|isCellVec|isNumericVec;
    isEmptyVec=cellfun('isempty',inpCVec)&...
        (cellfun(@(x)any(size(x)>0),inpCVec)&isSpecialEmptyVec|...
        ~isSpecialEmptyVec);
else
    isEmptyVec=false(size(inpCVec));
end
%%
isLessElemVec=cellfun(@(x)(numel(x)<=nMaxShownArrayElems),inpCVec);
isExprNumVec=(isNumericVec|isLogicalVec)&isLessElemVec&~isEmptyVec;
%%
isCharVec=isCharVec&isLessElemVec&~isEmptyVec;
isCellVec=isCellVec&isLessElemVec&~isEmptyVec;
%%
isOtherVec=~(isEmptyVec|isExprNumVec|isCharVec|isCellVec);
%
%%  Deal with empty elements
inpCVec(isEmptyVec)=cellfun(@getEmptyStr,inpCVec(isEmptyVec),...
    'UniformOutput',false);
%
%% Deal with cell elements
inpCVec(isCellVec)=cellfun(fCellPrint,inpCVec(isCellVec),...
    'UniformOutput',false);
%%  Deal with numeric elements
inpCVec(isExprNumVec)=cellfun(fNumPrint,...
    inpCVec(isExprNumVec),'UniformOutput',false);
%%  Deal with string elements
%  Put single quotes around the strings
inpCVec(isCharVec)=cellfun(fCharPrint,inpCVec(isCharVec),...
    'UniformOutput',false);
%%  Deal with elements other than string or numeric
% --------------------------------------------------------------------------
indOtherVec=find(isOtherVec);
nOtherElems=numel(indOtherVec);
%
for iObj=1:nOtherElems
    indOther=indOtherVec(iObj);
    valueObj=inpCVec{indOther};
    valSizeVec=size(valueObj);
    valNDims=ndims(valueObj);
    className=class(valueObj);
    %
    %%  Display size and class information
    %
    isEnum=isenum(valueObj);
    isScalar=isscalar(valueObj);
    if isEnum&&isScalar
        inpCVec{indOther}=sprintf('%s',char(valueObj));
    else
        highDimFormat='%d-D %s';
        lowDimFormat='%dx%d %s';
        %
        if valNDims==2
            inpCVec{indOther}=sprintf(lowDimFormat,valSizeVec(1),...
                valSizeVec(2),className);
        else
            inpCVec{indOther}=sprintf(highDimFormat,valNDims,className);
        end
    end
end
%% Reconstruct the original size
inpCMat=reshape(inpCVec,size(inpCMat));
%% Transform a cell array of strings into a cell vector of line strings
if isAsExpression
    lineStrList={mxberry.core.cell.cellstr2expression(inpCMat,false,true)};
else
    lineStrList=mxberry.core.cell.cell2tablestr([],inpCMat,' ',...
        'minSepCount',nSpaces,'UniformOutput',false);
end
%%

function resStr=other2str(inpVal)
    valSizeVec=size(inpVal);
    valNDims=ndims(inpVal);
    className=class(inpVal);
    %
    %%  Display size and class information
    %
    isEnum=isenum(inpVal);
    isScalar=isscalar(inpVal);
    if isEnum&&isScalar
        resStr=sprintf('%s',char(inpVal));
    else
        highDimFormat='%d-D %s';
        lowDimFormat='%dx%d %s';
        %
        if valNDims==2
            resStr=sprintf(lowDimFormat,valSizeVec(1),...
                valSizeVec(2),className);
        else
            resStr=sprintf(highDimFormat,valNDims,className);
        end
    end    
function resStr=numArr2str(inpVal,~,isClassShown,varargin)
origSizeVec=size(inpVal);
if max(origSizeVec)==0
    if isClassShown
        resStr=[class(inpVal),'([])'];
    else
        resStr='[]';
    end
else
    if isClassShown
        inpArgList={'class'};
    else
        inpArgList={};
    end
    isReshaped=~ismatrix(inpVal);
    if isReshaped
        inpVal=inpVal(:,:);
    end
    resStr=mat2str(inpVal,varargin{:},inpArgList{:});
    if isReshaped
        resStr=['reshape(',resStr,',',mat2str(origSizeVec),')'];
    end
end
function inpVal=charArr2str(inpVal,isAsExpression)
origSizeVec=size(inpVal);    
if max(origSizeVec)==0
    inpVal='''''';        
else
    isReshaped=~isrow(inpVal);
    if isAsExpression
        if isReshaped
            inpVal=inpVal(:).';
        end    
        inpVal=['''',strrep(inpVal,'''',''''''),''''];
        if isReshaped
            inpVal=['reshape(',inpVal,',',mat2str(origSizeVec),')'];
        end
    else
        if isReshaped
            inpVal=other2str(inpVal);
        else
            inpVal=['''',inpVal,''''];
        end
    end
end
%%

function resStr=getEmptyStr(x)
sizeVec=size(x);
resStr=[class(x),'.empty(',sprintf('%d,',sizeVec(1:end-1)),...
    sprintf('%d',sizeVec(end)),')'];