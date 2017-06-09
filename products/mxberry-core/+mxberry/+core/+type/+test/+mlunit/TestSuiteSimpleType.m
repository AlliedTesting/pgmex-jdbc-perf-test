% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef TestSuiteSimpleType < mxberry.unittest.TestCase
    properties
    end
    
    methods
        function self = TestSuiteSimpleType(varargin)
            self = self@mxberry.unittest.TestCase(varargin{:});
        end
    end
    methods (Test)
        function test_checkcelloffunc(self)
            checkP({@(x)x,@(x)x});
            checkP(@(x)x);
            checkN({@(x)x,@(x)x}.');
            checkN({});
            checkPE({});
            function checkPE(inpArg)
                expArg=inpArg;
                res=mxberry.core.check.checkcelloffunc(inpArg,true);
                self.verifyEqual(true,isequal(res,expArg));
            end
            function checkN(varargin)
                self.runAndCheckError(...
                    'mxberry.core.check.checkcelloffunc(varargin{:})',...
                    ':wrongInput');
            end
            function checkP(inpArg)
                res=mxberry.core.check.checkcelloffunc(inpArg);
                self.verifyEqual(true,iscell(res));
            end
        end
        function test_checkcellofstrorfunc(self)
            fHandle=@mxberry.core.check.lib.iscellofstrorfunc;
            checkP({@(x)x,'isstring(x)'});
            checkP({@(x)x,@(x)x});
            checkP({'isstring(x)','isstring(x)'});
            checkP({'isstring(x)','isstring(x)'}.');
            checkP({@(x)x,'isstring(x)'}.');
            checkP({@(x)x,@(x)x}.');
            checkN({@(x)x,@(x)x,1});
            checkN({'isstring(x)','isstring(x)',2});
            checkN({'isstring(x)','isstring(x)'.'});
            function checkP(inpArray)
                self.verifyEqual(true,fHandle(inpArray));
            end
            function checkN(inpArray)
                self.verifyEqual(false,fHandle(inpArray));
            end
            
        end
        function self=test_checkcellofstr(self)
            checkP({'a','b'});
            checkP('a',{'a'});
            checkP('aa',{'aa'});
            checkP({'aa','bb'});
            checkN('aaa'.');
            checkN({'aaa','aa'.'});
            checkN({'aaa','aa'}.');
            checkN({});
            checkPE({},true);
            checkPE({},[true true]);
            checkPE({'a','beta'},[true true]);
            checkN({},false);
            checkN({'a','b'}.',[true true]);
            checkN({'a','b'}.',[false true]);
            %
            function checkPE(inpArg,varargin)
                expArg=inpArg;
                res=mxberry.core.check.checkcellofstr(inpArg,varargin{:});
                self.verifyEqual(true,isequal(res,expArg));
            end
            function checkN(varargin)
                self.runAndCheckError(...
                    'mxberry.core.check.checkcellofstr(varargin{:})',...
                    ':wrongInput');
            end
            function checkP(inpArg,expArg)
                if nargin==1
                    expArg=inpArg;
                end
                res=mxberry.core.check.checkcellofstr(inpArg);
                self.verifyEqual(true,isequal(res,expArg));
            end
            
        end
        function self=test_checkgenext(self)
            import mxberry.core.check.lib.*;
            a='sdfadf';
            b='asd';
            %
            checkP(@isstring,1,a,'alpha');
            checkP(@isstring,1,a);
            checkP('numel(x1)==numel(x2)',2,a,a);
            checkP('numel(x1)==numel(x2)',2,a,a,'alpha');
            checkP('numel(x1)==numel(x2)',2,a,a,'alpha','beta');
            
            checkN('numel(x1)==numel(x2)',2,[],a,a,'alpha','beta','gamma');
            checkN('numel(x1)==numel(x2)',2,'Alpha,Beta',a,b,'Alpha','Beta');
            checkN('numel(x1)==numel(x2)',2,'Alpha,b',a,b,'Alpha');
            %
            function checkN(typeSpec,nPlaceHolders,expMsg,a,b,varargin)
                if isempty(expMsg)
                    runArgList={};
                else
                    runArgList={expMsg};
                end
                import mxberry.core.check.lib.*;
                try
                    mxberry.core.check.checkgenext(...
                        typeSpec,nPlaceHolders,a,b,varargin{:});
                catch meObj %#ok<NASGU>
                    self.runAndCheckError(...
                        'rethrow(meObj)',...
                        ':wrongInput',runArgList{:});
                end
                fHandle=typeSpec2Handle(typeSpec,nPlaceHolders);
                try
                    mxberry.core.check.checkgenext(...
                        fHandle,nPlaceHolders,a,b,varargin{:});
                catch meObj %#ok<NASGU>
                    self.runAndCheckError(...
                        'rethrow(meObj)',':wrongInput',runArgList{:});
                end
            end
            %
            function checkP(typeSpec,nPlaceHolders,varargin)
                import mxberry.core.throwerror;
                mxberry.core.check.checkgenext(typeSpec,...
                    nPlaceHolders,varargin{:});
                fHandle=typeSpec2Handle(typeSpec,nPlaceHolders);
                mxberry.core.check.checkgenext(fHandle,...
                    nPlaceHolders,varargin{:});
            end
            %
            function fHandle=typeSpec2Handle(typeSpec,nPlaceHolders)
                import mxberry.core.check.lib.*;
                if ischar(typeSpec)
                    switch nPlaceHolders
                        case 1
                            fHandle=eval(['@(x1)(',typeSpec,')']);
                        case 2
                            fHandle=eval(['@(x1,x2)(',typeSpec,')']);
                        case 3
                            fHandle=eval(['@(x1,x2,x3)(',typeSpec,')']);
                        otherwise
                            throwerror('wrongInput',...
                                'unsupported number of arguments');
                    end
                else
                    fHandle=typeSpec;
                end
            end
        end
        function self=test_check(self)
            import mxberry.core.check.lib.*;
            a='sdfadf';
            mxberry.core.check.checkgen(a,@isstring);
            mxberry.core.check.checkgen(a,@isstring,'aa');
            a=1;
            checkN(a,@isstring);
            checkN(a,@iscelloffunc);
            %
            checkP(a,@(x)(isstring(x)||isrow(x)));
            %
            checkP(a,@(x)(isstring(x)||isrow(x)||isabrakadabra(x)));
            %
            a=1;
            checkN(a,@(x)(isstring(x)&&isvec(x)));
            checkN(a,@(x)(isstring(x)&&isabrakadabra(x)));
            %
            a=true;
            checkP(a,'islogical(x)&&isscalar(x)');
            a=struct();
            checkP(a,'isstruct(x)&&isscalar(x)');
            %
            a={'a','b'};
            checkP(a,@(x)(iscellofstring(x)));
            a={'a','b';'d','e'};
            checkP(a,@(x)(iscellofstring(x)));
            a={'a','b'};
            checkP(a,@(x)(iscellofstring(x)));
            a={'a','b';'d','e'};
            checkP(a,@(x)(iscellofstring(x)));
            a={'a','b';'d','esd'.'};
            checkN(a,@(x)(iscellofstring(x)));
            %
            a={@(x)1,@(x)2};
            checkP(a,@(x)(iscelloffunc(x)));
            a={@(x)1,'@(x)2'};
            checkN(a,@(x)(iscelloffunc(x)));
            %
            function checkN(x,typeSpec,varargin) %#ok<INUSL>
                import mxberry.core.check.lib.*;
                self.runAndCheckError(...
                    ['mxberry.core.check.checkgen(x,',...
                    'typeSpec,varargin{:})'],...
                    ':wrongInput');
                if ischar(typeSpec)
                    fHandle=eval(['@(x)(',typeSpec,')']); %#ok<NASGU>
                else
                    fHandle=typeSpec; %#ok<NASGU>
                end
                self.runAndCheckError(...
                    ['mxberry.core.check.checkgen(x,',...
                    'fHandle,varargin{:})'],...
                    ':wrongInput');
                
            end
            function checkP(x,typeSpec,varargin)
                import mxberry.core.check.lib.*;
                mxberry.core.check.checkgen(x,typeSpec,varargin{:});
                if ischar(typeSpec)
                    fHandle=eval(['@(x)(',typeSpec,')']);
                else
                    fHandle=typeSpec;
                end
                mxberry.core.check.checkgen(x,fHandle,varargin{:});
            end
            
        end
    end
end