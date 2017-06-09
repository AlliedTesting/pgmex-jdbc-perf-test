function varargout=runsingleexperiment(funcHandle,varargin)
varargout=cell(1,nargout);
if nargin>0
    inputCVec=cellfun(@(x)x{:},varargin,'UniformOutput',false);
else
    inputCVec={};
end
if nargout>0
    [varargout{:}]=feval(funcHandle,inputCVec{:});
    varargout=cellfun(@(x){x},varargout,'UniformOutput',false);
else
    feval(funcHandle,inputCVec{:});
end
end