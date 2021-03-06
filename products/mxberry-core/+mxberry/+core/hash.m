function hashVec=hash(inpArr,methodName)
% OBJECTHASH counts the hash of input object/array
%
% Usage: hashVec=objecthash(inpArr)
%
% Input:
%   regular:
%       inpArr: any[] - input array of practically arbitrary type
%       methodName: char[1,] - hash calculation method - one of the
%           following methods:'MD2','MD5','SHA-1','SHA-256','SHA-384',
%           'SHA-512'
%
% Output:
%   hashVec: char[1,] -  hash of the input object.
%
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$
%
if nargin<2
    methodName='SHA-1';
end
switch (class(inpArr))
    case 'struct'
        hashVec=structhash(inpArr,methodName);
    case 'cell'
        hashVec=cellhash(inpArr,methodName);
    otherwise
        if ~isempty(inpArr)
            hashVec=hashinner(inpArr,methodName);
        else
            hashVec=hashinner('valueisemptynohash',methodName);
        end
end
end
%
function hashVec=structhash(structB,methodName)
fieldNames=fieldnames(structB);
hashMat=mxberry.core.hash(...
    [{'itisastruct';num2str(size(structB))};fieldNames],methodName);
%
hashMat=[hashMat;cellhash(struct2cell(structB),methodName)];
hashVec=mxberry.core.hash(hashMat,methodName);
end
%
function hashVec=cellhash(cellB,methodName)
import mxberry.core.hash;
%
hashCell=cellfun(@(x)hash(x,methodName),cellB,'UniformOutput',false);
hashCell=reshape(hashCell,[],1);
hashMat=cell2mat(hashCell);
hashMat=[hash(['itisacell' num2str(size(cellB))]);hashMat];
hashVec=hash(hashMat,methodName);
end

function h = hashinner(inpArr,meth)
% HASH - Convert an input variable into a message digest using any of
%        several common hash algorithms
%
% USAGE: h = hash(inpArr,'meth')
%
% inpArr  = input variable, of any of the following classes:
%        char, uint8, logical, double, single, int8, uint8,
%        int16, uint16, int32, uint32, int64, uint64
% h    = hash digest output, in hexadecimal notation
% meth = hash algorithm, which is one of the following:
%        MD2, MD5, SHA-1, SHA-256, SHA-384, or SHA-512
%
% Note:
%       (1) If the input is a string or uint8 variable, it is hashed
%            as usual for a byte stream. Other classes are converted into
%            their byte-stream values. In other words, the hash of the
%            following will be identical:
%                     'abc'
%                     uint8('abc')
%                     char([97 98 99])
%            The hash of the follwing will be different from the above,
%            because class "double" uses eight byte elements:
%                     double('abc')
%                     [97 98 99]
%            You can avoid this issue by making sure that your inputs
%            are strings or uint8 arrays.
%        (2) The name of the hash algorithm may be specified in lowercase
%            and/or without the hyphen, if desired. For example,
%            h=hash('my text to hash','sha256');
%        (3) Carefully tested, but no warranty. Use at your own risk.
%        (4) Michael Kleder, Nov 2005
%
% Example:
%
%     algs={'MD2','MD5','SHA-1','SHA-256','SHA-384','SHA-512'};
%     for n=1:6
%         h=mxberry.core.hash('my sample text',algs{n});
%         disp([algs{n} ' (' num2str(length(h)*4) ' bits):'])
%         disp(h)
%     end
%% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2015 Moscow State University,
%            Faculty of Computational Mathematics and Computer Science,
%            System Analysis Department$

inpVec=inpArr(:);
% convert strings and logicals into uint8 format
if ischar(inpVec) || islogical(inpVec)
    byteVec=uint8(inpVec);
else % convert everything else into uint8 format without loss of data
    if isnumeric(inpVec)&&isreal(inpVec)
        byteVec=typecast(inpVec,'uint8');
    else
        byteVec=getByteStreamFromArray(inpArr);
    end
end

% verify hash method, with some syntactical forgiveness:
meth=upper(meth);
switch meth
    case 'SHA1'
        meth='SHA-1';
    case 'SHA256'
        meth='SHA-256';
    case 'SHA384'
        meth='SHA-384';
    case 'SHA512'
        meth='SHA-512';
    otherwise
end
algs={'MD2','MD5','SHA-1','SHA-256','SHA-384','SHA-512'};
if isempty(strcmp(meth,algs))
    mxberry.core.throwerror('wrongInput',['Hash algorithm must be ' ...
        'MD2, MD5, SHA-1, SHA-256, SHA-384, or SHA-512']);
end
% create hash
x=java.security.MessageDigest.getInstance(meth);
x.update(byteVec);
h=typecast(x.digest,'uint8');
h=dec2hex(h)';
if(size(h,1))==1 % remote possibility: all hash bytes < 128, so pad:
    h=[repmat('0',[1 size(h,2)]);h];
end
h=lower(h(:)');
clear x
end
