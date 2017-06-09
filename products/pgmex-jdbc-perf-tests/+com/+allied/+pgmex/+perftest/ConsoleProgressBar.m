% $Author: Peter Gagarinov, PhD <pgagarinov@gmail.com> $
% $Copyright: 2015-2016 Peter Gagarinov, PhD
%             2012-2015 Moscow State University,
%            Faculty of Applied Mathematics and Computer Science,
%            System Analysis Department$
classdef ConsoleProgressBar < handle
    properties (Access=private)
        tStart
        tEnd
        nDotsShown
        nDots
        nInvDots
        invLengthPerDot
        tLast
        prefixStr
    end
    methods
        function processRangeInfo(self)
            import mxberry.core.throwerror;
            if self.tEnd<self.tStart
                throwerror('wrongInput',...
                    'it is expected that tEnd > tStart');
            end
            spanLength=(self.tEnd-self.tStart);
            self.invLengthPerDot=self.nDots./max(spanLength,1);
            self.tLast=self.tStart;
        end
    end
    methods
        function close(~)
        end
        function self=ConsoleProgressBar(nDots,prefixStr)
            import mxberry.core.throwerror;
            self.nDots=nDots;
            self.nDotsShown=0;
            %
            if nargin<4
                prefixStr='';
            else
                prefixStr=[prefixStr,':'];
            end
            self.prefixStr=prefixStr;
        end
        function setMin(self,tStart)
            self.tStart=tStart;
            self.processRangeInfo();
        end
        function setMax(self,tEnd)
            self.tEnd=tEnd;
            self.processRangeInfo();
        end
        function start(self)
            fprintf([self.prefixStr,'[',repmat(' ',1,self.nDots),']']);
        end
        function reset(self)
            self.progressInternal(self.tStart);
        end
        function progress(self,tCur,isIncreasedCheck)
            import mxberry.core.throwerror;
            if nargin<3
                isIncreasedCheck=true;
            end
            if isempty(self.tStart)||isempty(self.tEnd)
                throwerror('wrongInput',['both setMax and setMin',...
                    'should have been called prior to calling ',...
                    '"progress"']);
            end
            %
            if isIncreasedCheck
                if tCur<self.tLast
                    throwerror('wrongInput','t is expected to be increasing');
                end
            end
            self.progressInternal(tCur);
        end
        function updateStatusMsg(~,~)
        end
        function finish(self)
            nToRemove=1+(self.nDots-self.nDotsShown);
            strToPrint=[repmat(sprintf('\b'),1,nToRemove),...
                repmat('.',1,self.nDots-self.nDotsShown),']\n'];
            fprintf(strToPrint);
        end
    end
    methods (Access=private)
        function progressInternal(self,tCur)
            iCurDot=fix((tCur-self.tStart)*self.invLengthPerDot);
            if iCurDot~=self.nDotsShown
                nToRemove=1+(self.nDots-self.nDotsShown);
                if iCurDot>self.nDotsShown
                    strToPrint=[repmat(sprintf('\b'),1,nToRemove),...
                        repmat('.',1,iCurDot-self.nDotsShown),...
                        repmat(' ',1,self.nDots-iCurDot),']'];
                    
                elseif iCurDot<self.nDotsShown
                    strToPrint=[repmat(sprintf('\b'),1,nToRemove),...
                        repmat('\b',1,self.nDotsShown-iCurDot),...
                        repmat(' ',1,self.nDots-iCurDot),']'];
                end
                fprintf(strToPrint);
                self.nDotsShown=iCurDot;
            end
            self.tLast=tCur;
        end
    end
end