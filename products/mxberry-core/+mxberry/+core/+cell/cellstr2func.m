function fHandle = cellstr2func(inpCMat,inpArgNameList)
% CELLSTR2EXPRESSION creates Matlab expression based on cell matrix of
% expressions corresponding to the individual elements of the matrix
%
% Input:
%   regular:
%       inpCMat: cell[nRows,nCols] of char[1,] - input matrix of
%           expressiosn
%       inpArgNameList: cell[1,nArgs] of char[1,]/char[1,] - names of input
%           arguments for the resulting function
% Output:
%   fHandle: function_handle[1,1] - resulting expression for the matrix
%
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
%
import mxberry.core.cell.cellstr2expression;
import mxberry.core.check.checkcellofstr;
import mxberry.core.string.catwithsep;
inpArgNameList=checkcellofstr(inpArgNameList);
funcPrefix=['@(',catwithsep(inpArgNameList,','),')'];
expStr=cellstr2expression(inpCMat,true);
fHandle=str2func([funcPrefix,'(',expStr,')']);