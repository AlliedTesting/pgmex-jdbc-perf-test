% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef SuiteSecBasic < matlab.unittest.TestCase
    methods
        function self = SuiteSecBasic(varargin)
            self = self@matlab.unittest.TestCase(varargin{:});
        end
    end
    methods (Test)
        %
        function testMapAutoKey(self)
            c=mxberry.core.cont.MapAutoKey(...
                'directPrefix','EE','autoPrefix','ZZZ');
            %
            c.putDirect('a',2);
            c.putDirect('b',3);
            c.putDirect('cc',4);
            c.putAuto(333);
            c.putAuto(33);
            keyList=c.keys;
            valueList=c.values;
            self.verifyTrue(isequal(keyList,...
                {'EEa','EEb','EEcc','ZZZ1','ZZZ2'}));
            self.verifyTrue(isequal(valueList,{2,3,4,333,33}));
            self.verifyTrue(isequal(333,c.get('ZZZ1')));
            self.verifyTrue(isequal(3,c.get('EEb')));
            c.remove({'EEb','ZZZ1'});
            keyList=c.keys;
            valueList=c.values;
            %
            self.verifyTrue(isequal(keyList,...
                {'EEa','EEcc','ZZZ2'}));
            self.verifyTrue(isequal(valueList,{2,4,33}));
        end
    end
end