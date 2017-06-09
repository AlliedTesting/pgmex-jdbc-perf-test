% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef mlunit_test_string < matlab.unittest.TestCase
    properties
    end
    
    methods
        function self = mlunit_test_string(varargin)
            self = self@matlab.unittest.TestCase(varargin{:});
        end
        %
    end
    methods (Test)
        %
        function test_shortcapstr(self)
            check('one2oneContr','o2oC');
            check('plainIV','pIV');
            check('one2oneContr_plainIV','o2oC_pIV');
            check('vertical spread','vs');
            %
            function check(inpStr,expStr)
                import mxberry.core.string.shortcapstr;
                resStr=shortcapstr(inpStr);
                self.verifyEqual(resStr,expStr);
            end
        end
        function self=test_splitpart(self)
            inpStr='aaa..bbb..';
            try
                mxberry.core.string.splitpart(inpStr,'..',4);
                self.verifyEqual(true,false);
            catch meObj
                self.verifyEqual(~isempty(strfind(meObj.identifier,':wrongInput')),true);
            end
            %
            resStr=mxberry.core.string.splitpart(inpStr,'..',3);
            self.verifyEqual('',resStr);
            %
            self.verifyEqual(mxberry.core.string.splitpart(inpStr,'..',2),'bbb');
            self.verifyEqual(mxberry.core.string.splitpart(inpStr,'..','first'),'aaa');
            inpStr='aaa';
            self.verifyEqual(mxberry.core.string.splitpart(inpStr,'..','first'),'aaa');
            self.verifyEqual(mxberry.core.string.splitpart(inpStr,'..','last'),'aaa');
        end
        function self=test_catwithsep(self)
            outStr=mxberry.core.string.catwithsep({'aaa','bbb'},'__');
            self.verifyEqual(outStr,'aaa__bbb');
        end
        function self=test_catcellstrwithsep(self)
            outCVec=mxberry.core.string.catcellstrwithsep(...
                {'aa','bb';'aaa','bbb';'a','b'},'-');
            self.verifyEqual(true,...
                isequal(outCVec,{'aa-bb';'aaa-bbb';'a-b'}));
        end
        function test_sepcellstrbysep(self)
            inpCMat={'aa','bb';'aaa','bbb';'a','b'};
            sepStr='-';
            check();
            sepStr='  ';
            check();
            sepStr='-+';
            check();
            %
            function check()
                outCVec=mxberry.core.string.catcellstrwithsep(...
                    inpCMat,sepStr);
                %
                resCMat=mxberry.core.string.sepcellstrbysep(outCVec,sepStr);
                self.verifyEqual(true,isequal(resCMat,inpCMat));
            end
        end
    end
end