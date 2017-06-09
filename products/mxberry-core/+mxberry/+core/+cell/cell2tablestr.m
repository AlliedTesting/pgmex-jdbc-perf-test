function tableStr=cell2tablestr(titleList,dataCell,colSepSeq,varargin)
% CELL2TABLESTR - converts a cell array into a table-like char array (or a
% cell array of strings representing table rows).
%
% Usage: tableStr=cell2tablestr(titles,dataCell,sepSymbol,varargin)
%
% Input:
%   regular:
%       titleList: cell[1,nCols]- cell array of column titles
%       dataCell: cell[nRows,nCols] - data cell array
%       colSepSeq: char[1,] - a string used for separating neighboring
%          columns
%
%   properties:
%       isMatlabSyntax: logical[1,1] - forms result according to Matlab
%          syntax(default=0);
%       UniformOutput: logical[1,1] - if true, output is char array, if
%          false - output is cell array; by default true;
%       minSepCount: double[1] - minimal number of separation used for
%           separating neighboring columns
%       numPrecision: double[1,1] - number of digits used for displaying
%          numeric values
%
% Output:
%   tableStr: char[nRows,nCols] or cell[nLines,1] of char[1,] - output character
%       array or cell array of lines
%
%
% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
%
import mxberry.core.throwerror;
import mxberry.core.parseparext;
[~,~,isMatlabSyntax,isUniformOutput,minSepCount,numPrecision]=...
    parseparext(varargin,...
    {'isMatlabSyntax','uniformOutput','minSepCount','numPrecision';...
    false,true,1,3;...
    @(x)islogical(x)&&isscalar(x),@(x)islogical(x)&&isscalar(x),...
    @(x)isscalar(x)&&isnumeric(x)&&(x>0)&&(fix(x)==x),...
    @(x)isscalar(x)&&isnumeric(x)&&(x>0)&&(fix(x)==x)},0);
%
[nRows,nCols] = size(dataCell);
%
nRowsRes=nRows;
if ~isempty(titleList)
    nRowsRes=nRowsRes+1;
    dataCell=[titleList;dataCell];
end
%
%% process data cell
dataCell=cellfun(@cellformatter,dataCell,'UniformOutput',false);
%
%% insert separators
resCell=cell(nRowsRes,1);
for iCol=1:(nCols-1)
    dataColCell=dataCell(:,iCol);
    lenColCell=cellfun(@length,dataColCell,'UniformOutput',false);
    lenColVec=cell2mat(lenColCell);
    maxLength=max(lenColVec(:))+minSepCount;
    sepCell=cellfun(@(x)(repmat(colSepSeq,1,maxLength-x)),lenColCell,...
        'UniformOutput',false);
    resCell=strcat(resCell,strcat(dataCell(:,iCol),sepCell));
end
if nRowsRes==0
    nRowsRes=1;
end
if nCols>0
    resCell=strcat(resCell,dataCell(:,end));
else
    resCell=repmat({''},[nRowsRes,1]);
end
%
if isMatlabSyntax
    resCell=cellfun(@horzcat,repmat({'{'},[nRowsRes,1]),resCell,...
        'UniformOutput',false);
    resCell=cellfun(@horzcat,resCell,repmat({'}'},[nRowsRes,1]),...
        'UniformOutput',false);
end
%
%% convert to char array if necessary
%
if isUniformOutput
    tableStr=char(resCell);
else
    tableStr=resCell;
end
    function outCont=cellformatter(inpCont)
        switch class(inpCont)
            case {'double','single'}
                outCont=num2str(inpCont,numPrecision);
            case 'logical'
                outCont=num2str(inpCont);
            case 'struct'
                outCont='<structure>';
            otherwise
                if isnumeric(inpCont)
                    outCont=num2str(inpCont);
                else
                    outCont=inpCont;
                end
        end
    end
end