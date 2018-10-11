classdef ATestCompareWithJDBC < matlab.unittest.TestCase
    properties (GetAccess=private,Constant,Hidden)
        % list of functions used for insert
        INSERT_METHOD_CVEC = {'datainsert','fastinsert','batchParamExec'};
        % RGB colors on plots for each function used for insert
        INSERT_METHOD_RGB_COLORS_CVEC = {[1 0 0],[0 1 0],[0 0 1]};
        % list of functions used for retrieve
        RETRIEVE_METHOD_CVEC = {'fetch','getf'};
        % RGB colors on plots for each function used for retrieve
        RETRIEVE_METHOD_RGB_COLORS_CVEC = {[1 0 0],[0 0 1]};
        % function translating number of bytes into string displayed on
        % plots
        DATA_SIZE_OUT_FUNC=@(x)[num2str(round(x/1024^2)) 'Mb'];
        % mapping between Matlab and Java types (used in input test data)
        TYPE_MAP_CMAT={...
            'int4','java.lang.Integer';...
            'int2','java.lang.Integer';...
            'int8','java.lang.Long';...
            'float4','java.lang.Float';...
            'float8','java.lang.Double';...
            'bool','java.lang.Boolean'};
        % mapping between modes and function executing commands for each
        % mode
        MODE_MAP_CMAT={...
            'jdbc',@(varargin)com.allied.pgmex.perftest.jdbcexec(...
            varargin{:});...
            'pgmex',@(varargin)com.allied.pgmex.pgmexec(varargin{:})};
        % mapping between all functions and indices of modes from
        % MODE_MAP_CMAT
        ALL_FUNC_MAP_CMAT={...
            'datainsert',1;...
            'fastinsert',1;...
            'fetch',1;...
            'batchparamexec',2;...
            'putf',2;...
            'getf',2};
        % name of file with initial input data for tests
        DATA_FILE_NAME=[fileparts(mfilename('fullpath')) filesep...
            'input' filesep 'data.mat'];
        % maximal number of tuples saved in prepared files with input test
        % data, if Inf, all the tuples from the file determined by
        % DATA_FILE_NAME are taken as input test data, othewise not more
        % than this amount is to be taken
        MAX_N_TUPLES_FOR_INPUT_TEST_DATA=5000;
        % default array size for array tests
        DEFAULT_ARRAY_SIZE_VEC=[1 2];
    end
    properties (SetAccess=private,GetAccess=protected)
        dbConn=0;
        confRepoMgr=[];
        connInfoStr='';
        dbName='';
        nTuplesVec
        nTrialsPerSample=3;
        maxExecTimeInSecs=180;
        pathToSaveTestData='';
        raiseExceptionIfError=true;
        saveFiguresInTests=false;
        singleExpRunFuncName='';
        indDBMode=[];
        dbExecFunc=[];
        filterInsertFuncNameCVec=cell(1,0);
        filterRetrieveFuncNameCVec=cell(1,0);
    end
    methods (TestClassSetup)
        function self = set_up(self)
            self.confRepoMgr=feval(['com.allied.pgmex.perftest.'...
                'configuration.ConfStorage.getConfRepoMgr']);
            genConnInfoStr=...
                self.confRepoMgr.getParam('database.connectionString');
            self.maxExecTimeInSecs=self.confRepoMgr.getParam(...
                'performanceTestingParams.maxExecTimeInSecs');
            self.pathToSaveTestData=self.confRepoMgr.getParam(...
                'performanceTestingParams.pathToSaveTestData');
            self.saveFiguresInTests=self.confRepoMgr.getParam(...
                'performanceTestingParams.saveFiguresInTests');
            if ~isempty(self.pathToSaveTestData)
                if self.pathToSaveTestData(end)~=filesep
                    self.pathToSaveTestData=[...
                        self.pathToSaveTestData filesep];
                end
            end
            self.raiseExceptionIfError=self.confRepoMgr.getParam(...
                'performanceTestingParams.raiseExceptionIfError');
            curSingleExpRunFuncName=self.confRepoMgr.getParam(...
                'performanceTestingParams.singleExpRunFuncName');
            testModeName=self.confRepoMgr.getParam(...
                'performanceTestingParams.testModeName');
            if strcmpi(testModeName,'jdbc')
                self.indDBMode=find(strcmp(...
                    self.MODE_MAP_CMAT(:,1),'jdbc'),1);
            else
                self.indDBMode=find(strcmp(...
                    self.MODE_MAP_CMAT(:,1),'pgmex'),1);
            end
            self.dbExecFunc=self.MODE_MAP_CMAT{self.indDBMode,2};
            %
            samplesMeshModeName=self.confRepoMgr.getParam(...
                'performanceTestingParams.samplesMeshModeName');
            SSamplesMeshModeProps=self.confRepoMgr.getParam(...
                'performanceTestingParams.samplesMeshModeProps');
            if ~isfield(SSamplesMeshModeProps,samplesMeshModeName)
                mxberry.core.throwerror('wrongConf',...
                    'No properties are given for sampleMeshModeName=%s',...
                    sampleMeshModeName);
            end
            SSamplesMeshModeProps=...
                SSamplesMeshModeProps.(samplesMeshModeName);
            switch lower(samplesMeshModeName)
                case 'uniform'
                    nTuplesSamples=SSamplesMeshModeProps.nTuplesSamples;
                    nMinTuples=SSamplesMeshModeProps.minNumOfTuples;
                    nMaxTuples=SSamplesMeshModeProps.maxNumOfTuples;
                    if isnan(nMaxTuples)
                        SData=load(self.DATA_FILE_NAME);
                        nMaxTuples=numel(SData.outCVec{1}.valueVec);
                    end
                    if isnan(nMinTuples)
                        nMinTuples=ceil(nMaxTuples/...
                            nTuplesSamples);
                    else
                        nMinTuples=min(nMinTuples,nMaxTuples);
                    end
                    nDeltaTuples=nMaxTuples-nMinTuples;
                    if nTuplesSamples==1||nDeltaTuples==0
                        self.nTuplesVec=nMaxTuples;
                    else
                        nTuplesStep=ceil(...
                            nDeltaTuples/(nTuplesSamples-1));
                        self.nTuplesVec=...
                            nMinTuples+(0:nTuplesSamples-1).'*...
                            nTuplesStep;
                    end
                case 'manual'
                    self.nTuplesVec=SSamplesMeshModeProps.nTuplesVec(:);
                otherwise
                    mxberry.core.throwerror('wrongConf',...
                        'Mode samplesMeshModeName is unknown: %s',...
                        samplesMeshModeName);
            end
            self.nTrialsPerSample=self.confRepoMgr.getParam(...
                'performanceTestingParams.nTrialsPerSample');
            %%
            self.dbConn=feval(self.dbExecFunc,'connect',genConnInfoStr);
            curDBName=lower(['demo_',computer('arch'),'_',...
                datestr(now,'yyyymmdd_HHMMSS'),'_',...
                regexprep(mxberry.system.getpidhost(),'\W','_')]);
            feval(self.dbExecFunc,'exec',...
                self.dbConn,sprintf('CREATE DATABASE %s',curDBName));
            feval(self.dbExecFunc,'finish',self.dbConn);
            self.dbConn=0;
            self.dbName=curDBName;
            curConnInfoStr=genConnInfoStr;
            patternStr='dbname=';
            indDBName=strfind(curConnInfoStr,patternStr);
            self.verifyEqual(1,numel(indDBName));
            indDBNameStart=indDBName+numel(patternStr);
            indDBNameEnd=find(curConnInfoStr(indDBNameStart:end)==' ',...
                1,'first');
            if isempty(indDBNameEnd)
                indDBNameEnd=numel(curConnInfoStr);
            else
                indDBNameEnd=indDBNameStart+indDBNameEnd-2;
            end
            curConnInfoStr=horzcat(...
                curConnInfoStr(1:indDBNameStart-1),...
                self.dbName,...
                curConnInfoStr(indDBNameEnd+1:end));
            self.dbConn=feval(self.dbExecFunc,'connect',curConnInfoStr);
            self.connInfoStr=curConnInfoStr;
            %%
            packageMDObj=...
                meta.package.fromName('com.allied.pgmex.perftest');
            packageFuncNameCVec={packageMDObj.FunctionList.Name};
            if ~any(strcmp(packageFuncNameCVec,curSingleExpRunFuncName))
                mxberry.core.throwerror('wrongConf',[...
                    'com.allied.pgmex.perftest.%s '...
                    'for experiment running is not found'],...
                    curSingleExpRunFuncName);
            end
            self.singleExpRunFuncName=['com.allied.pgmex.perftest.'...
                curSingleExpRunFuncName];
        end
    end
    methods (TestClassTeardown)
        function self = tear_down(self)
            if self.dbConn~=0
                feval(self.dbExecFunc,'finish',self.dbConn);
                self.dbConn=0;
            end
            if ~isempty(self.dbName)&&~isempty(self.confRepoMgr)
                self.dbConn=feval(self.dbExecFunc,'connect',...
                    self.confRepoMgr.getParam(...
                    'database.connectionString'));
                feval(self.dbExecFunc,'exec',self.dbConn,...
                    sprintf('DROP DATABASE IF EXISTS %s',self.dbName));
                feval(self.dbExecFunc,'finish',self.dbConn);
            end
        end
    end
    methods (TestMethodSetup, Abstract)
        method_set_up(self,testModeName)
    end
    methods
        function self = ATestCompareWithJDBC(varargin)
            self = self@matlab.unittest.TestCase(varargin{:});
        end
    end
    methods (Test)
        function self=compareInsertForNumScalars(self)
            self.compareInsertInternal(...
                self.filterInsertFuncNameList(...
                {'datainsert','batchParamExec','fastinsert'}),...
                false,true,true);
        end
        function self=compareInsertForScalarsInCell(self)
            self.compareInsertInternal(...
                self.filterInsertFuncNameList(...
                {'datainsert','batchParamExec'}),...
                false,false,false);
        end
        function self=compareInsertForArrays(self)
            self.compareInsertInternal(...
                self.filterInsertFuncNameList(...
                {'datainsert','batchParamExec'}),...
                true,false,false);
        end
        function self=compareRetrieveForNumScalarsAsNumeric(self)
            self.compareRetrieveInternal(...
                self.filterRetrieveFuncNameList(...
                {'fetch','getf'}),...
                false,true,true,'numeric');
        end
        function self=compareRetrieveForNumScalarsAsCellArray(self)
            self.compareRetrieveInternal(...
                self.filterRetrieveFuncNameList(...
                {'fetch','getf'}),...
                false,true,true,'cellarray');
        end
        function self=compareRetrieveForNumScalarsAsStruct(self)
            self.compareRetrieveInternal(...
                self.filterRetrieveFuncNameList(...
                {'fetch','getf'}),...
                false,true,true,'structure');
        end
        function self=compareRetrieveForScalarsInCellAsCellArray(self)
            self.compareRetrieveInternal(...
                self.filterRetrieveFuncNameList(...
                {'fetch','getf'}),...
                false,false,false,'cellarray');
        end
        function self=compareRetrieveForScalarsInCellAsStruct(self)
            self.compareRetrieveInternal(...
                self.filterRetrieveFuncNameList(...
                {'fetch','getf'}),...
                false,false,false,'structure');
        end
        function self=compareRetrieveForArraysAsCellArray(self)
            self.compareRetrieveInternal(...
                self.filterRetrieveFuncNameList(...
                {'fetch','getf'}),...
                true,false,false,'cellarray');
        end
        function self=compareRetrieveForArraysAsStruct(self)
            self.compareRetrieveInternal(...
                self.filterRetrieveFuncNameList(...
                {'fetch','getf'}),...
                true,false,false,'structure');
        end
    end
    methods (Access=protected)
        function setUpTestMode(self,testModeName)
            switch lower(testModeName)
                case 'pgmex'
                    self.filterInsertFuncNameCVec={'batchParamExec'};
                    self.filterRetrieveFuncNameCVec={'getf'};
                case 'jdbc'
                    self.filterInsertFuncNameCVec=...
                        {'datainsert','fastinsert'};
                    self.filterRetrieveFuncNameCVec={'fetch'};
                case 'all'
                    self.filterInsertFuncNameCVec=...
                        {'datainsert','fastinsert','batchParamExec'};
                    self.filterRetrieveFuncNameCVec={'fetch','getf'};
                otherwise
                    mxberry.core.throwerror('wrongParam',...
                        'Test mode is unknown: %s',testModeName);
            end
        end
    end
    methods (Access=private)
        function funcNameCVec=filterInsertFuncNameList(self,...
                funcNameCVec)
            funcNameCVec(~ismember(funcNameCVec,...
                self.filterInsertFuncNameCVec))=[];
        end
        function funcNameCVec=filterRetrieveFuncNameList(self,...
                funcNameCVec)
            funcNameCVec(~ismember(funcNameCVec,...
                self.filterRetrieveFuncNameCVec))=[];
        end
        function self=compareInsertInternal(self,...
                funcNameCVec,testArrays,testOnlyNumeric,tryToPassAsDouble)
            if isempty(funcNameCVec)
                return;
            end
            StFunc=dbstack('-completenames');
            className=mfilename('class');
            for indCaller=numel(StFunc):-1:2
                [testName,curClassName]=...
                    mxberry.core.parsestackelem(StFunc(indCaller));
                if strcmp(curClassName,className)
                    break;
                end
            end
            nSamples=numel(self.nTuplesVec);
            [isFuncVec,indFuncVec]=ismember(lower(funcNameCVec),...
                lower(self.INSERT_METHOD_CVEC));
            if ~all(isFuncVec)
                mxberry.core.throwerror('wrongInput',...
                    'Given insert methods are unknown: %s',...
                    mxberry.core.string.catwithsep(...
                    reshape(funcNameCVec(~isFuncVec),1,[]),', '));
            end
            funcNameCVec=self.INSERT_METHOD_CVEC(indFuncVec);
            rgbColorsCVec=self.INSERT_METHOD_RGB_COLORS_CVEC(indFuncVec);
            prepareInputTestDataFile(funcNameCVec,...
                'dataFileName',self.DATA_FILE_NAME,...
                'nMaxTuples',self.MAX_N_TUPLES_FOR_INPUT_TEST_DATA,...
                'testName',testName,...
                'arraySizeVec',self.DEFAULT_ARRAY_SIZE_VEC,...
                'testArrays',testArrays,...
                'testOnlyNumeric',testOnlyNumeric,...
                'tryToPassAsDouble',tryToPassAsDouble);
            %
            nFuncs=numel(funcNameCVec);
            nTrials=self.nTrialsPerSample;
            timeMat=nan(nSamples,nFuncs,nTrials);
            prepareInsertTimeMat=nan(nSamples,nFuncs,nTrials);
            selfInsertTimeMat=nan(nSamples,nFuncs,nTrials);
            prepareTimeMat=nan(nSamples,nFuncs,nTrials);
            initialTimeVec=nan(nSamples,1);
            dataSizeInBytesVec=nan(nSamples,1);
            isFuncVec=true(1,nFuncs);
            progressBarObj=...
                com.allied.pgmex.perftest.ConsoleProgressBar(100,'');
            progressBarObj.setMin(1);
            progressBarObj.setMax(nSamples);
            progressBarObj.reset();
            progressBarObj.start();
            for iSample=1:nSamples
                isCurFuncVec=isFuncVec;
                [curInsertTimeMat,isnErrorVec,...
                    curPrepareInsertTimeMat,curSelfInsertTimeMat,...
                    curPrepareTimeMat,...
                    initialTimeVec(iSample),...
                    dataSizeInBytesVec(iSample)]=...
                    testInsert(self.connInfoStr,...
                    funcNameCVec(isCurFuncVec),...
                    self.nTuplesVec(iSample),...
                    'nTrials',nTrials,...
                    'maxExecTimeInSecs',self.maxExecTimeInSecs,...
                    'raiseExceptionIfError',self.raiseExceptionIfError,...
                    'singleExpRunFuncName',self.singleExpRunFuncName,...
                    'testName',testName);
                timeMat(iSample,isCurFuncVec,:)=...
                    reshape(curInsertTimeMat,1,[],nTrials);
                prepareInsertTimeMat(iSample,isCurFuncVec,:)=...
                    reshape(curPrepareInsertTimeMat,1,[],nTrials);
                selfInsertTimeMat(iSample,isCurFuncVec,:)=...
                    reshape(curSelfInsertTimeMat,1,[],nTrials);
                prepareTimeMat(iSample,isCurFuncVec,:)=...
                    reshape(curPrepareTimeMat,1,[],nTrials);
                isCurFuncVec(isCurFuncVec)=...
                    isCurFuncVec(isCurFuncVec)&...
                    reshape(isnErrorVec,1,[]);
                isFuncVec=isCurFuncVec;
                if ~any(isFuncVec)
                    break;
                end
                progressBarObj.progress(iSample);
            end
            progressBarObj.finish();
            STestData=struct(...
                'javaMaxMemory',...
                {java.lang.Runtime.getRuntime.maxMemory},...
                'figName',{testName},...
                'nTuplesVec',{self.nTuplesVec},...
                'funcNameCVec',{funcNameCVec},...
                'rgbColorsCVec',{rgbColorsCVec},...
                'timeMat',{median(timeMat,3,'omitnan')},...
                'prepareTimeMat',{median(prepareInsertTimeMat,3,'omitnan')},...
                'selfTimeMat',{median(selfInsertTimeMat,3,'omitnan')},...
                'prepareDBTimeVec',{median(reshape(...
                prepareTimeMat,nSamples,[]),2,'omitnan')},...
                'prepareDataVec',{initialTimeVec},...
                'dataSizeInBytesVec',{dataSizeInBytesVec});
            save([self.pathToSaveTestData testName '_data.mat'],...
                'STestData');
            if self.saveFiguresInTests
                self.saveFigures(STestData);
            end
        end
        function self=compareRetrieveInternal(self,...
                funcNameCVec,testArrays,testOnlyNumeric,...
                tryToPassAsDouble,retrieveModeName)
            if isempty(funcNameCVec)
                return;
            end
            StFunc=dbstack('-completenames');
            className=mfilename('class');
            for indCaller=numel(StFunc):-1:2
                [testName,curClassName]=...
                    mxberry.core.parsestackelem(StFunc(indCaller));
                if strcmp(curClassName,className)
                    break;
                end
            end
            nSamples=numel(self.nTuplesVec);
            [isFuncVec,indFuncVec]=ismember(lower(funcNameCVec),...
                lower(self.RETRIEVE_METHOD_CVEC));
            if ~all(isFuncVec)
                mxberry.core.throwerror('wrongInput',...
                    'Given retrieve methods are unknown: %s',...
                    mxberry.core.string.catwithsep(...
                    reshape(funcNameCVec(~isFuncVec),1,[]),', '));
            end
            funcNameCVec=self.RETRIEVE_METHOD_CVEC(indFuncVec);
            rgbColorsCVec=self.RETRIEVE_METHOD_RGB_COLORS_CVEC(indFuncVec);
            prepareInputTestDataFile(funcNameCVec,...
                'dataFileName',self.DATA_FILE_NAME,...
                'nMaxTuples',self.MAX_N_TUPLES_FOR_INPUT_TEST_DATA,...
                'testName',testName,...
                'arraySizeVec',self.DEFAULT_ARRAY_SIZE_VEC,...
                'testArrays',testArrays,...
                'testOnlyNumeric',testOnlyNumeric,...
                'tryToPassAsDouble',tryToPassAsDouble);
            %% insert data into table
            schemaName='demo';
            tableName='demo.demo_table';
            allFuncMapCMat=eval([mfilename('class') '.ALL_FUNC_MAP_CMAT']);
            modeMapCMat=eval([mfilename('class') '.MODE_MAP_CMAT']);
            insertModeName=modeMapCMat{self.indDBMode,1};
            allInsertFuncNameCVec=allFuncMapCMat(...
                vertcat(allFuncMapCMat{:,2})==self.indDBMode,1);
            [isFuncVec,indFuncVec]=ismember(...
                lower(self.INSERT_METHOD_CVEC),...
                lower(allInsertFuncNameCVec));
            if ~any(isFuncVec)
                mxberry.core.throwerror('wrongObjState',...
                    'No insert methods for given mode: %s',insertModeName);
            end
            indInsertFunc=find(isFuncVec,1,'first');
            insertFuncName=allInsertFuncNameCVec{...
                indFuncVec(indInsertFunc)};
            curTableName=[tableName '_' testName '_' insertFuncName];
            nMaxTuples=max(self.nTuplesVec);
            try
                [~,~,~,~,~,~]=performInsert(testName,insertModeName,...
                    self.dbExecFunc,insertFuncName,self.connInfoStr,...
                    schemaName,curTableName,nMaxTuples,true);
            catch meObj
                messageStr=sprintf(...
                    'Exception for function %s, number of tuples %d',...
                    insertFuncName,nMaxTuples);
                meExtObj=MException(meObj.identifier,messageStr);
                meExtObj=addCause(meExtObj,meObj);
                warning(meObj.identifier,'\n%s\n',meObj.getReport());
                throw(meExtObj);
            end
            %% test retrieving
            nFuncs=numel(funcNameCVec);
            nTrials=self.nTrialsPerSample;
            timeMat=nan(nSamples,nFuncs,nTrials);
            convertResultsTimeMat=nan(nSamples,nFuncs,nTrials);
            selfRetrieveTimeMat=nan(nSamples,nFuncs,nTrials);
            prepareTimeMat=nan(nSamples,nFuncs,nTrials);
            initialTimeVec=nan(nSamples,1);
            dataSizeInBytesVec=nan(nSamples,1);
            isFuncVec=true(1,nFuncs);
            progressBarObj=...
                com.allied.pgmex.perftest.ConsoleProgressBar(100,'');
            progressBarObj.setMin(1);
            progressBarObj.setMax(nSamples);
            progressBarObj.reset();
            progressBarObj.start();
            for iSample=1:nSamples
                isCurFuncVec=isFuncVec;
                [curRetrieveTimeMat,isnErrorVec,...
                    curConvertResultsTimeMat,curSelfRetrieveTimeMat,...
                    curPrepareTimeMat,...
                    initialTimeVec(iSample),...
                    dataSizeInBytesVec(iSample)]=...
                    testRetrieve(self.connInfoStr,...
                    funcNameCVec(isCurFuncVec),...
                    self.nTuplesVec(iSample),...
                    'nTrials',nTrials,...
                    'maxExecTimeInSecs',self.maxExecTimeInSecs,...
                    'raiseExceptionIfError',self.raiseExceptionIfError,...
                    'singleExpRunFuncName',self.singleExpRunFuncName,...
                    'testName',testName,'tableName',curTableName,...
                    'retrieveModeName',retrieveModeName);
                timeMat(iSample,isCurFuncVec,:)=...
                    reshape(curRetrieveTimeMat,1,[],nTrials);
                convertResultsTimeMat(iSample,isCurFuncVec,:)=...
                    reshape(curConvertResultsTimeMat,1,[],nTrials);
                selfRetrieveTimeMat(iSample,isCurFuncVec,:)=...
                    reshape(curSelfRetrieveTimeMat,1,[],nTrials);
                prepareTimeMat(iSample,isCurFuncVec,:)=...
                    reshape(curPrepareTimeMat,1,[],nTrials);
                isCurFuncVec(isCurFuncVec)=...
                    isCurFuncVec(isCurFuncVec)&...
                    reshape(isnErrorVec,1,[]);
                isFuncVec=isCurFuncVec;
                if ~any(isFuncVec)
                    break;
                end
                progressBarObj.progress(iSample);
            end
            progressBarObj.finish();
            STestData=struct(...
                'javaMaxMemory',...
                {java.lang.Runtime.getRuntime.maxMemory},...
                'figName',{testName},...
                'nTuplesVec',{self.nTuplesVec},...
                'funcNameCVec',{funcNameCVec},...
                'rgbColorsCVec',{rgbColorsCVec},...
                'timeMat',{median(timeMat,3,'omitnan')},...
                'prepareTimeMat',{median(convertResultsTimeMat,3,'omitnan')},...
                'selfTimeMat',{median(selfRetrieveTimeMat,3,'omitnan')},...
                'prepareDBTimeVec',{median(reshape(...
                prepareTimeMat,nSamples,[]),2,'omitnan')},...
                'prepareDataVec',{initialTimeVec},...
                'dataSizeInBytesVec',{dataSizeInBytesVec});
            save([self.pathToSaveTestData testName '_data.mat'],...
                'STestData');
            if self.saveFiguresInTests
                self.saveFigures(STestData);
            end
        end
    end
    
    %% Static methods for plotting results
    
    methods (Static)
        function hFigVec=plot(varargin)
            [reg,~,filterFuncNameCVec,selfTimeMode,...
                xLimVec,yLimVec,legendLocation,isDataSizeOutput,...
                isFilterFuncNameList]=...
                mxberry.core.parseparext(varargin,{...
                'filterFuncNameList','selfTimeMode',...
                'xLimVec','yLimVec','legendLocation','outputDataSize';...
                {},'on',[],[],'northoutside',true;...
                'iscellofstring(x)','isstring(x)',...
                'isvector(x)&&numel(x)==2','isvector(x)&&numel(x)==2',...
                'isstring(x)','islogical(x)&&isscalar(x)'},...
                [0 Inf],'propRetMode','separate');
            if ~ismember(selfTimeMode,{'on','off','only'})
                mxberry.core.throwerror('wrongInput',[...
                    'selfTimeMode property must be equal either to '...
                    '''on'', ''off'' or ''only''']);
            end
            if numel(reg)==1
                if isstruct(reg{1})
                    STestData=reg{1};
                    if ~isfield(STestData,'javaMaxMemory')
                        STestData.javaMaxMemory=...
                            java.lang.Runtime.getRuntime.maxMemory;
                    end
                    if ~isfield(STestData,'selfTimeMat')
                        STestData.selfTimeMat=...
                            nan(size(STestData.timeMat));
                        selfTimeMode='off';
                    end
                    [~,indFieldVec]=ismember({'figName',...
                        'nTuplesVec','dataSizeInBytesVec',...
                        'funcNameCVec','rgbColorsCVec',...
                        'timeMat','selfTimeMat','javaMaxMemory'},...
                        fieldnames(STestData));
                    if any(indFieldVec==0)
                        mxberry.core.throwerror('wrongInput',[...
                            'STestData passed as input is incorrect, '...
                            'may be it is out-of-date, please '...
                            'recalculate the results']);
                    end
                    reg=struct2cell(STestData);
                    reg=reg(indFieldVec);
                end
            end
            if isFilterFuncNameList
                funcNameCVec=reg{4};
                isFuncVec=ismember(lower(funcNameCVec),...
                    lower(filterFuncNameCVec));
                if ~any(isFuncVec)
                    mxberry.core.throwerror('wrongInput',...
                        'filterFuncNameList property is wrong');
                end
                nFuncs=numel(funcNameCVec);
                if sum(isFuncVec)<nFuncs
                    isRegVec=cellfun('size',reg,2)==nFuncs;
                    reg(isRegVec)=cellfun(@(x)x(:,isFuncVec),...
                        reg(isRegVec),'UniformOutput',false);
                end
            end
            className=mfilename('class');
            hFigVec(1)=feval([className '.plotTrajInternal'],reg{:},...
                selfTimeMode,xLimVec,yLimVec,legendLocation,...
                isDataSizeOutput);
            hFigVec(2)=feval([className '.plotBarInternal'],reg{:},...
                selfTimeMode,xLimVec,yLimVec,legendLocation);
        end
        %%
        function saveFigures(varargin)
            import mxberry.core.throwerror;
            [reg,~,hFigVec,formatList,isHFigVec]=...
                mxberry.core.parseparext(varargin,{...
                'hFigVec','figureFormatList';...
                [],{'jpeg'};...
                'isvector(x)&&isa(x,''matlab.ui.Figure'')',...
                'iscellofstring(x)'},[0 Inf]);
            %
            confRepoMgr=feval(['com.allied.pgmex.perftest.'...
                'configuration.ConfStorage.getConfRepoMgr']);
            pathStr=confRepoMgr.getParam(...
                'performanceTestingParams.pathToSaveFigures');
            if isempty(pathStr)
                pathStr=pwd();
            end
            if pathStr(end)~=filesep
                pathStr=[pathStr filesep];
            end
            %
            knownFormatMapCMat={...
                'pdf',@savePDF;...
                'fig',@saveFIG};
            nFormats=numel(formatList);
            saveFuncList=cell(1,nFormats);
            [isFormatVec,indFormatVec]=...
                ismember(formatList,knownFormatMapCMat(:,1));
            if any(isFormatVec)
                indFormatVec=indFormatVec(isFormatVec);
                saveFuncList(isFormatVec)=...
                    knownFormatMapCMat(indFormatVec,2);
            end
            if ~all(isFormatVec)
                saveFuncList(~isFormatVec)={@saveOther};
            end
            if ~isHFigVec
                hFigVec=feval([mfilename('class') '.plot'],...
                    reg{:});
            end
            nFigs=numel(hFigVec);
            for iFig=1:nFigs
                hFig=hFigVec(iFig);
                set(hFig,'WindowStyle','normal','Visible','off');
                set(hFig,'OuterPosition',get(0,'ScreenSize'));
                set(hFig,'RendererMode','manual','Renderer','painters');
                set(hFig,'PaperPositionMode','manual',...
                    'PaperUnits','normalized',...
                    'PaperPosition',[0 0 1 1]);
                figName=get(hFig,'Name');
                shortFigFileName=mxberry.core.genfilename(figName);
                for iFormat=1:nFormats
                    formatName=formatList{iFormat};
                    figFileName=...
                        [pathStr shortFigFileName ...
                        '.' formatName];
                    feval(saveFuncList{iFormat},...
                        hFig,figFileName,formatName);
                    if ~exist(figFileName,'file')
                        throwerror('wrongOperation',...
                            'file %s was not created',figFileName);
                    end
                end
                if isHFigVec
                    set(hFig,'Visible','on');
                else
                    close(hFig);
                end
            end
            function savePDF(hFig,fileName,formatName)
                set(hFig,'PaperOrientation','landscape','PaperType','A4');
                print(hFig,fileName,['-d' formatName]);
            end
            function saveFIG(hFig,fileName,formatName)
                set(hFig,'PaperOrientation',...
                    'landscape','PaperType','A4','Visible','on');
                saveas(hFig,fileName,formatName);
                set(hFig,'Visible','off');
            end
            function saveOther(hFig,fullFileName,formatName)
                [resFolderName,fileName]=fileparts(fullFileName);
                com.allied.pgmex.perftest.savefigures(...
                    hFig,resFolderName,...
                    {formatName},{fileName})
            end
        end
    end
    methods (Access=private,Static,Hidden)
        function hFigure=plotTrajInternal(figName,...
                nTuplesVec,dataSizeInBytesVec,...
                funcNameCVec,funcRgbColorsCVec,timeMat,selfTimeMat,...
                javaMaxMemory,selfTimeMode,xLimVec,yLimVec,...
                legendLocation,isDataSizeOutput)
            dataSizeOutFunc=...
                eval([mfilename('class') '.DATA_SIZE_OUT_FUNC']);
            %
            hFigure=figure('Name',[figName '_traj'],'NumberTitle','off',...
                'ToolBar','figure','MenuBar','none',...
                'RendererMode','manual','Renderer','painters');
            %% plotting
            nFuncs=numel(funcNameCVec);
            nInterpTuplesVec=nTuplesVec(1):nTuplesVec(end);
            nPlotsPerFunc=1+strcmp(selfTimeMode,'on');
            interpTimeMat=nan(numel(nInterpTuplesVec),nFuncs,...
                nPlotsPerFunc);
            for iFunc=1:nFuncs
                indEnd=find(~isnan(timeMat(:,iFunc)),1,'last');
                if isempty(indEnd)
                    continue;
                end
                isInterpVec=nInterpTuplesVec<=nTuplesVec(indEnd);
                if indEnd>=2
                    if strcmp(selfTimeMode,'on')
                        allTimeMat=[...
                            timeMat(1:indEnd,iFunc)...
                            selfTimeMat(1:indEnd,iFunc)];
                    elseif strcmp(selfTimeMode,'off')
                        allTimeMat=timeMat(1:indEnd,iFunc);
                    else
                        allTimeMat=selfTimeMat(1:indEnd,iFunc);
                    end
                    interpTimeMat(isInterpVec,iFunc,:)=...
                        reshape(interp1(nTuplesVec(1:indEnd),...
                        allTimeMat,...
                        nInterpTuplesVec(isInterpVec),'spline'),[],1,...
                        nPlotsPerFunc);
                else
                    if ~strcmp(selfTimeMode,'only')
                        interpTimeMat(isInterpVec,iFunc,1)=...
                            timeMat(1,iFunc);
                    end
                    if ~strcmp(selfTimeMode,'off')
                        interpTimeMat(isInterpVec,iFunc,nPlotsPerFunc)=...
                            selfTimeMat(1,iFunc);
                    end
                end
            end
            fontSize=25;
            visibleState=get(hFigure,'visible');
            set(hFigure,'visible','off');
            hAxes=axes('Parent',hFigure);
            set(hAxes,'FontSize',fontSize);
            hold(hAxes,'on');
            if strcmp(selfTimeMode,'on')
                annotCVec={' (with overhead expenses)',' (pure)'};
            else
                annotCVec={''};
            end
            for iFunc=1:nFuncs
                for iPlot=1:nPlotsPerFunc
                    if iPlot==1&&~strcmp(selfTimeMode,'only')
                        inputCVec={};
                    else
                        inputCVec={':'};
                    end
                    hPlot=plot(hAxes,...
                        nInterpTuplesVec(:),...
                        interpTimeMat(:,iFunc,iPlot),inputCVec{:});
                    set(hPlot,'lineWidth',5);
                    set(hPlot,'color',funcRgbColorsCVec{iFunc});
                    set(hPlot,'DisplayName',...
                        [funcNameCVec{iFunc} annotCVec{iPlot}]);
                end
            end
            if isempty(xLimVec)
                if nInterpTuplesVec(1)<nInterpTuplesVec(end)
                    xlim([nInterpTuplesVec(1) nInterpTuplesVec(end)]);
                end
            else
                xlim(xLimVec);
            end
            if ~isempty(yLimVec)
                ylim(yLimVec);
            end
            ylabel(hAxes,'time (sec.)',...
                'FontSize',fontSize,...
                'Rotation',90);
            if isDataSizeOutput
                xlabel(hAxes,'num of tuples and data size',...
                    'FontSize',fontSize,...
                    'Rotation',0);
            else
                xlabel(hAxes,'num of tuples',...
                    'FontSize',fontSize,...
                    'Rotation',0);
            end
            modeMapCMat=eval([mfilename('class') '.MODE_MAP_CMAT']);
            allFuncMapCMat=eval([mfilename('class') '.ALL_FUNC_MAP_CMAT']);
            [isFuncVec,indFuncVec]=ismember(lower(funcNameCVec),...
                lower(allFuncMapCMat(:,1)));
            if ~all(isFuncVec)
                mxberry.core.throwerror('wrongInput',...
                    'Given insert methods are unknown: %s',...
                    mxberry.core.string.catwithsep(...
                    reshape(funcNameCVec(~isFuncVec),1,[]),', '));
            end
            isJDBC=any(vertcat(allFuncMapCMat{indFuncVec,2})==...
                find(strcmp(modeMapCMat(:,1),'jdbc'),1));
            if isJDBC
                hTitle=title(sprintf('Java Heap Memory Size = %s',...
                    feval(dataSizeOutFunc,javaMaxMemory)));
                set(hTitle,'FontWeight','normal');
            end
            hLegend=legend(hAxes,'show');
            set(hLegend,'Location',legendLocation);
            set(hLegend,'Color','none');
            set(hAxes,'XGrid','on');
            set(hAxes,'YGrid','on');
            set(hAxes,'FontSize',fontSize,'XTickLabelRotation',45);
            set(hFigure,'Visible',visibleState);
            indEnd=find(~isnan(dataSizeInBytesVec),1,'last');
            if isempty(indEnd)
                indEnd=0;
            end
            SUserData=struct(...
                'hAxes',{hAxes},...
                'dataSizeOutFunc',{dataSizeOutFunc},...
                'nTuplesVec',{nTuplesVec(1:indEnd)},...
                'dataSizeInBytesVec',{dataSizeInBytesVec(1:indEnd)});
            if ~isDataSizeOutput
                SUserData=rmfield(SUserData,{...
                    'dataSizeOutFunc','dataSizeInBytesVec'});
            end
            set(hFigure,'UserData',SUserData);
            set(hFigure,'SizeChangedFcn',@resizeTrajFigure);
            resizeTrajFigure(hFigure);
            set(hAxes,'Units','normalized','OuterPosition',[0 0 1 1]);
        end
        function hFigure=plotBarInternal(figName,...
                ~,~,funcNameCVec,funcRgbColorsCVec,timeMat,selfTimeMat,...
                ~,selfTimeMode,~,~,~)
            %
            hFigure=figure('Name',[figName '_bar'],'NumberTitle','off',...
                'ToolBar','figure','MenuBar','none',...
                'RendererMode','manual','Renderer','painters');
            %% plotting
            nFuncs=numel(funcNameCVec);
            indEndVec=nan(1,nFuncs);
            for iFunc=1:nFuncs
                indEnd=find(~isnan(timeMat(:,iFunc)),1,'last');
                if ~isempty(indEnd)
                    indEndVec(iFunc)=indEnd;
                end
            end
            indEnd=max(indEndVec);
            if isnan(indEnd)
                indBaseFunc=1;
            else
                indBaseFunc=find(indEndVec==indEnd,1,'first');
            end
            nPlotsPerFunc=1+strcmp(selfTimeMode,'on');
            if strcmp(selfTimeMode,'on')
                timeMat=cat(3,timeMat,selfTimeMat);
            elseif strcmp(selfTimeMode,'only')
                timeMat=selfTimeMat;
            end
            scaledTimeMat=timeMat./...
                repmat(timeMat(:,indBaseFunc,:),1,nFuncs,1);
            fontSize=25;
            if strcmp(selfTimeMode,'on')
                annotCVec={'(with overhead expenses)','(pure)'};
            end
            for iPlot=1:nPlotsPerFunc
                timeVec=mean(scaledTimeMat(:,:,iPlot),1,'omitnan');
                timeVec=timeVec/max(timeVec)*100;
                barDataMat=nan(nFuncs,nFuncs);
                barDataMat(sub2ind(size(barDataMat),...
                    1:nFuncs,1:nFuncs))=timeVec;
                hBarVec=bar((1:nFuncs)+nFuncs*(iPlot-1),...
                    barDataMat,'stacked');
                hAxes=get(hBarVec(1),'Parent');
                if iPlot==1&&nPlotsPerFunc>1
                    hold(hAxes,'on');
                end
                if iPlot==1&&~strcmp(selfTimeMode,'only')
                    inputCVec={};
                else
                    inputCVec={'LineStyle',':'};
                end
                for iFunc=1:nFuncs
                    set(hBarVec(iFunc),'FaceColor',...
                        funcRgbColorsCVec{iFunc},'EdgeColor',...
                        funcRgbColorsCVec{iFunc},inputCVec{:},...
                        'LineWidth',5);
                end
                if strcmp(selfTimeMode,'on')
                    hText=text(0,0,annotCVec{iPlot},...
                        'HorizontalAlignment','center',...
                        'VerticalAlignment','top',...
                        'FontSize',fontSize);
                    posVec=get(get(hAxes,'XLabel'),'Position');
                    set(hText,'Position',[nFuncs*(iPlot-1)+(nFuncs+1)/2 ...
                        posVec(2:end)]);
                end
            end
            set(hAxes,'XTick',(1:nFuncs*nPlotsPerFunc).');
            set(hAxes,'XTickLabel',repmat(...
                funcNameCVec(:),nPlotsPerFunc,1));
            ylabel(hAxes,'time (% from maximal)');
            set(hAxes,'FontSize',fontSize);
            set(hAxes,'Units','normalized',...
                'OuterPosition',[0 0 1 1]);
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Testing functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function prepareInputTestDataFile(varargin)
% PREPAREINPUTTESTDATAFILE builds files with input test data for given
% test and given list of functions to be tested

% parse input arguments
[reg,~,dataFileName,testName,nMaxTuples,arraySizeVec,...
    testArrays,testOnlyNumeric,tryToPassAsDouble]=...
    mxberry.core.parseparext(varargin,[{...
    'dataFileName'; [fileparts(mfilename('fullpath')) filesep...
            'data.mat']; 'isstring(x)'},{...
    'testName'; ''; 'isstring(x)'},{...
    'nMaxTuples'; Inf; 'isscalar(x)&&isnumeric(x)&&isreal(x)'},{...
    'arraySizeVec'; [1 2]; 'isvector(x)&&isnumeric(x)&&isreal(x)'},{...
    'testArrays'; false; 'isscalar(x)&&islogical(x)'},{...
    'testOnlyNumeric'; false; 'isscalar(x)&&islogical(x)'},{...
    'tryToPassAsDouble'; true; 'isscalar(x)&&islogical(x)'}],[1 1],...
    'regCheckList',{'iscellofstring(x)'},...
    'propRetMode','separate'); %#ok<ASGLU>
funcNameCVec=reg{1};
% initial actions
if isempty(funcNameCVec)
    return;
end
allFuncMapCMat=eval([mfilename('class') '.ALL_FUNC_MAP_CMAT']);
[isFuncVec,indFuncVec]=ismember(lower(funcNameCVec),...
    lower(allFuncMapCMat(:,1)));
if ~all(isFuncVec)
    mxberry.core.throwerror('wrongInput',...
        'Given insert methods are unknown: %s',...
        mxberry.core.string.catwithsep(...
        reshape(funcNameCVec(~isFuncVec),1,[]),', '));
end
modeMapCMat=eval([mfilename('class') '.MODE_MAP_CMAT']);
modeNameCVec=modeMapCMat(unique(vertcat(allFuncMapCMat{indFuncVec,2})),1);
nModes=numel(modeNameCVec);
% mapping between all fields and Matlab types in initial data file
fieldMapCMat={...
    't_data','date';...
    'inst_id','int4';...
    'price_low','float4';...
    'price_open','float4';...
    'price_close','float4';...
    'price_close_ini','float4';...
    'price_high','float4';...
    'price_close_opt','float4';...
    'volume','int8';...
    'calc_date','date'};
allTypeMapCMat=eval([mfilename('class') '.TYPE_MAP_CMAT']);
typeMapCMat=repmat({''},size(fieldMapCMat,1),2);
[isFieldTypeVec,indFieldTypeVec]=...
    ismember(fieldMapCMat(:,2),allTypeMapCMat(:,1));
if any(isFieldTypeVec)
    indFieldTypeVec=indFieldTypeVec(isFieldTypeVec);
    typeMapCMat(isFieldTypeVec,:)=fliplr(...
        allTypeMapCMat(indFieldTypeVec,:));
end
% load initial data
SData=load(dataFileName);
dataCMat=cellfun(@(x)num2cell(x.valueVec),SData.outCVec,...
    'UniformOutput',false);
% exclude fields represented in one of modes by non-numerics (for example,
% dates, times and timestamps represented for JDBC as strings)
if testOnlyNumeric
    isnFieldTypeVec=~isFieldTypeVec;
    if any(isnFieldTypeVec)
        fieldMapCMat(isnFieldTypeVec,:)=[];
        dataCMat(:,isnFieldTypeVec)=[];
        typeMapCMat(isnFieldTypeVec,:)=[];
    end
end
allFieldMapCMat=fieldMapCMat;
allDataCMat=horzcat(dataCMat{:});
if size(allDataCMat,1)>nMaxTuples
    allDataCMat=allDataCMat(1:nMaxTuples,:);
end
%
for iMode=1:nModes
    modeName=modeNameCVec{iMode};
    fieldMapCMat=allFieldMapCMat;
    dataCMat=allDataCMat;
    isJDBC=strcmp(modeName,'jdbc');
    isPgmex=strcmp(modeName,'pgmex');
    if isJDBC
        isDateFieldVec=strcmp(fieldMapCMat(:,2),'date');
        if any(isDateFieldVec)
            dataCMat(:,isDateFieldVec)=...
                cellfun(@(x)datestr(x,29),dataCMat(:,isDateFieldVec),...
                'UniformOutput',false);
            typeMapCMat(isDateFieldVec,1)={''};
        end
    end
    if testArrays
        isArrayFieldVec=~cellfun('isempty',typeMapCMat(:,1));
        fieldMapCMat(isArrayFieldVec,2)=...
            strcat(fieldMapCMat(isArrayFieldVec,2),'[]');
        arraySizeVec=reshape(arraySizeVec,1,[]);
        dataCMat(:,isArrayFieldVec)=...
            cellfun(@(x)repmat(x,arraySizeVec),...
            dataCMat(:,isArrayFieldVec),'UniformOutput',false);
    end
    if isJDBC
        fieldMapCMat=[fieldMapCMat typeMapCMat]; %#ok<AGROW,NASGU>
    end
    if isPgmex
        if testArrays&&arraySizeVec(1)~=1
            dataCMat(:,isArrayFieldVec)=cellfun(@(x){x},...
                dataCMat(:,isArrayFieldVec),'UniformOutput',false);
        end
        dataCVec=cellfun(@(x)vertcat(x{:}),...
            num2cell(dataCMat,1),'UniformOutput',false); %#ok<NASGU>
        saveFieldNameCVec={...
            'fieldMapCMat','dataCMat','dataCVec',...
            'testArrays','testOnlyNumeric','tryToPassAsDouble'};
    else
        saveFieldNameCVec={...
            'fieldMapCMat','dataCMat',...
            'testArrays','testOnlyNumeric','tryToPassAsDouble'};
    end
    save([fileparts(mfilename('fullpath')) filesep 'input' filesep...
        'data_' testName '_' modeName '.mat'],saveFieldNameCVec{:},'-v6');
end
end
%
function [insertTimeMat,isnErrorVec,...
    prepareInsertTimeMat,selfInsertTimeMat,...
    prepareTimeMat,initialTime,dataSizeInBytes]=testInsert(varargin)
% TESTINSERT tests different insert functions for different number of
% tuples

tStart=tic;
[reg,~,nTrials,maxExecTimeInSecs,raiseExceptionIfError,...
    singleExpRunFuncName,testName]=...
    mxberry.core.parseparext(varargin,[{...
    'nTrials'; 1; 'isscalar(x)&&isnumeric(x)&&isreal(x)'},{...
    'maxExecTimeInSecs'; Inf; 'isscalar(x)&&isnumeric(x)&&isreal(x)'},{...
    'raiseExceptionIfError'; true; 'isscalar(x)&&islogical(x)'},{...
    'singleExpRunFuncName';...
    'com.allied.pgmex.perftest.runsingleexperiment';'isstring(x)'},{...
    'testName'; ''; 'isstring(x)'}],[2 3],...
    'regCheckList',{'isstring(x)','iscellofstring(x)',...
    'isscalar(x)&&isnumeric(x)&&isreal(x)'},...
    'propRetMode','separate');
connInfoStr=reg{1};
funcNameCVec=reg{2};
if numel(reg)>=3
    nMaxTuples=reg{3};
else
    nMaxTuples=Inf;
end
%% initial actions
allFuncMapCMat=eval([mfilename('class') '.ALL_FUNC_MAP_CMAT']);
[isFuncVec,indFuncVec]=ismember(lower(funcNameCVec),...
    lower(allFuncMapCMat(:,1)));
if ~all(isFuncVec)
    mxberry.core.throwerror('wrongInput',...
        'Given insert methods are unknown: %s',...
        mxberry.core.string.catwithsep(...
        reshape(funcNameCVec(~isFuncVec),1,[]),', '));
end
funcNameCVec=allFuncMapCMat(indFuncVec,1);
modeIndVec=vertcat(allFuncMapCMat{indFuncVec,2});
nFuncs=numel(modeIndVec);
insertTimeMat=nan(nFuncs,nTrials);
prepareInsertTimeMat=nan(nFuncs,nTrials);
selfInsertTimeMat=nan(nFuncs,nTrials);
prepareTimeMat=nan(nFuncs,nTrials);
isnErrorVec=true(nFuncs,1);
dataSizeInBytesVec=nan(nFuncs,1);
schemaName='demo';
tableName='demo.demo_table';
%% measuring time for inserting
initialTime=toc(tStart);
modeMapCMat=eval([mfilename('class') '.MODE_MAP_CMAT']);
for iFunc=1:nFuncs
    funcName=funcNameCVec{iFunc};
    iMode=modeIndVec(iFunc);
    modeName=modeMapCMat{iMode,1};
    execFunc=modeMapCMat{iMode,2};
    curTableName=[tableName '_' testName '_' funcName];
    for iTrial=1:nTrials
        try
            [insertTime,isnError,dataSizeInBytes,...
                prepareInsertTime,selfInsertTime,prepareTime]=...
                feval(singleExpRunFuncName,@performInsert,...
                {testName},{modeName},{execFunc},{funcName},...
                {connInfoStr},{schemaName},{curTableName},...
                {nMaxTuples},{raiseExceptionIfError});
        catch meObj
            messageStr=sprintf(...
                'Exception for function %s, number of tuples %d',...
                funcName,nMaxTuples);
            meExtObj=MException(meObj.identifier,messageStr);
            meExtObj=addCause(meExtObj,meObj);
            if raiseExceptionIfError
                warning(meObj.identifier,'\n%s\n',meObj.getReport());
                throw(meExtObj);
            else
                insertTime={NaN};
                isnError={false};
                dataSizeInBytes={NaN};
                prepareInsertTime={NaN};
                selfInsertTime={NaN};
                prepareTime={NaN};
                warning(meExtObj.identifier,'\n%s\n%s\n',...
                    meExtObj.getReport(),meObj.getReport());
            end
        end
        insertTimeMat(iFunc,iTrial)=insertTime{:};
        isnErrorVec(iFunc)=isnError{:};
        dataSizeInBytesVec(iFunc)=dataSizeInBytes{:};
        prepareInsertTimeMat(iFunc,iTrial)=prepareInsertTime{:};
        selfInsertTimeMat(iFunc,iTrial)=selfInsertTime{:};
        prepareTimeMat(iFunc,iTrial)=prepareTime{:};
        if ~isnErrorVec(iFunc)||...
                insertTimeMat(iFunc,iTrial)>maxExecTimeInSecs
            break;
        end
    end
end
% in JDBC data size may be greater than necessary due, for instance, to the
% way of representation of dates, times and timestamps as strings, so we
% take here the mininum of sizes along all modes
dataSizeInBytes=min(dataSizeInBytesVec); 
end
%
function [insertTime,isnError,dataSizeInBytes,...
    prepareInsertTime,selfInsertTime,prepareTime]=...
    performInsert(testName,modeName,execFunc,funcName,...
    connInfoStr,schemaName,tableName,...
    nTuples,raiseExceptionIfError)
% PERFORMINSERT prepares database by creating of the corresponding table
% and immediately inserts data created in advance for given mode and test

insertTime=NaN;
isnError=true;
prepareInsertTime=NaN;
selfInsertTime=NaN;
%
tStart=tic;
usePutf=strcmp(funcName,'putf');
% load input test data
SInputTestData=load([...
    fileparts(mfilename('fullpath')) filesep 'input' filesep...
    'data_' testName '_' modeName '.mat']);
% get some necessary fields from SInputTestData
fieldMapCMat=SInputTestData.fieldMapCMat;
testArrays=SInputTestData.testArrays;
% adjust number of tuples to one given as input
dataCMat=SInputTestData.dataCMat;
nCurTuples=size(dataCMat,1);
if strcmp(modeName,'pgmex')&&~usePutf
    dataCVec=SInputTestData.dataCVec;
    if nCurTuples>nTuples
        dataCVec=cellfun(@(x)x(1:nTuples,:),dataCVec,...
            'UniformOutput',false);
    elseif nCurTuples<nTuples&&isfinite(nTuples)
        nReplicates=ceil(nTuples/nCurTuples);
        dataCVec=cellfun(@(x)replicateTuples(x,nReplicates,nTuples),...
            dataCVec,'UniformOutput',false);
    end
    dataSizeInBytes=ceil(...
        getfield(whos('dataCMat'),'bytes')/nCurTuples)*nTuples;
    clear dataCMat;
    SInputTestData=rmfield(SInputTestData,{'dataCVec','dataCMat'});
    nFields=numel(dataCVec);
else
    if nCurTuples>nTuples
        dataCMat=dataCMat(1:nTuples,:);
    elseif nCurTuples<nTuples&&isfinite(nTuples)
        dataCMat=replicateTuples(dataCMat,...
            ceil(nTuples/nCurTuples),nTuples);
    end
    dataSizeInBytes=getfield(whos('dataCMat'),'bytes');
    if strcmp(modeName,'pgmex')
        SInputTestData=rmfield(SInputTestData,{'dataCVec','dataCMat'});
    else
        SInputTestData=rmfield(SInputTestData,{'dataCMat'});
    end
    nFields=size(dataCMat,2);
end
%
dbConn=feval(execFunc,'connect',connInfoStr);
feval(execFunc,'exec',dbConn,[...
    'CREATE SCHEMA IF NOT EXISTS ' schemaName]);
feval(execFunc,'exec',dbConn,[...
    'DROP TABLE IF EXISTS ' tableName]);
feval(execFunc,'exec',dbConn,[...
    'CREATE TABLE IF NOT EXISTS ' tableName ' ('...
    mxberry.core.string.catwithsep(...
    mxberry.core.string.catcellstrwithsep(...
    fieldMapCMat(:,1:2),' '),',') ')']);
%
fieldSpecStr=...
    mxberry.core.string.catwithsep(strcat('%',fieldMapCMat(:,2)),' ');
placeHolderStr=...
    mxberry.core.string.catwithsep(strcat('$',...
    cellfun(@num2str,num2cell(1:nFields),'UniformOutput',false)),', ');
insertQueryStr=[...
    'INSERT INTO ' tableName ' values ('...
    placeHolderStr ')'];
%
prepareTime=toc(tStart);
tStart=tic;
try
    switch modeName
        case 'jdbc'
            tPrepareStart=tic;
            if testArrays
                indArrayFieldVec=...
                    find(~cellfun('isempty',fieldMapCMat(:,3)));
                nArrayFields=numel(indArrayFieldVec);
                for iArrayField=1:nArrayFields
                    iField=indArrayFieldVec(iArrayField);
                    curJavaType=fieldMapCMat{iField,3};
                    for iTuple=1:nTuples
                        curMat=dataCMat{iTuple,iField};
                        sizeVec=size(curMat);
                        inpCVec=num2cell(sizeVec);
                        curArrObj=javaArray(curJavaType,inpCVec{:});
                        nElems=numel(curMat);
                        for iElem=1:nElems
                            [inpCVec{:}]=ind2sub(sizeVec,iElem);
                            curArrObj(inpCVec{:})=feval(curJavaType,...
                                curMat(iElem));
                        end
                        dataCMat{iTuple,iField}=curArrObj;
                    end
                end
                isJavaMat=cellfun(@isjava,dataCMat);
                if any(isJavaMat(:))
                    [~,indFieldVec]=find(isJavaMat);
                    dataCMat(isJavaMat)=cellfun(...
                        @(x,y)dbConn.Handle.createArrayOf(x,y),...
                        reshape(fieldMapCMat(indFieldVec,4),[],1),...
                        reshape(dataCMat(isJavaMat),[],1),...
                        'UniformOutput',false);
                end
            else
                if SInputTestData.tryToPassAsDouble&&...
                        SInputTestData.testOnlyNumeric
                    dataCMat=cellfun(@(x)double(vertcat(x{:})),...
                        num2cell(dataCMat,1),'UniformOutput',false);
                    dataCMat=horzcat(dataCMat{:});
                end
            end
            prepareInsertTime=toc(tPrepareStart);
            tSelfInsertStart=tic;
            feval(funcName,dbConn,tableName,...
                reshape(fieldMapCMat(:,1),1,[]),dataCMat);
            selfInsertTime=toc(tSelfInsertStart);
        case 'pgmex'
            selfInsertTime=0;
            tSelfInsertStart=tic;
            feval(execFunc,'exec',dbConn,'begin');
            selfInsertTime=selfInsertTime+toc(tSelfInsertStart);
            if usePutf
                nTuples=size(dataCMat,1);
                tPrepareStart=tic;
                paramObj=feval(execFunc,'paramCreate',dbConn);
                prepareInsertTime=toc(tPrepareStart);
                for iTuple=1:nTuples
                    if iTuple>1
                        tPrepareStart=tic;
                        feval(execFunc,'paramReset',paramObj);
                        prepareInsertTime=...
                            prepareInsertTime+toc(tPrepareStart);
                    end
                    tSelfInsertStart=tic;
                    feval(execFunc,'putf',paramObj,fieldSpecStr,...
                        dataCMat{iTuple,:});
                    feval(execFunc,'paramExec',dbConn,...
                        paramObj,insertQueryStr);
                    selfInsertTime=selfInsertTime+...
                        toc(tSelfInsertStart);
                end
                tPrepareStart=tic;
                feval(execFunc,'paramClear',paramObj);
                prepareInsertTime=...
                    prepareInsertTime+toc(tPrepareStart);
                tSelfInsertStart=tic;
            else
                tPrepareStart=tic;
                inputCVec=[fieldMapCMat(:,1) num2cell(dataCVec(:))].';
                SData=struct(inputCVec{:});
                prepareInsertTime=toc(tPrepareStart);
                tSelfInsertStart=tic;
                feval(execFunc,'batchParamExec',...
                    dbConn,insertQueryStr,fieldSpecStr,SData);
            end
            feval(execFunc,'exec',dbConn,'commit');
            selfInsertTime=selfInsertTime+toc(tSelfInsertStart);
        otherwise
            mxberry.core.throwerror('wrongParams',...
                'Unknown mode: %s',modeName);
    end
    insertTime=toc(tStart);
    feval(execFunc,'finish',dbConn);
catch meObj
    isnError=false;
    messageStr=sprintf(...
        'Exception for function %s, number of tuples %d',...
        funcName,nTuples);
    meExtObj=MException(meObj.identifier,messageStr);
    meExtObj=addCause(meExtObj,meObj);
    if raiseExceptionIfError
        fprintf('\n%s\n',meObj.getReport());
        throw(meExtObj);
    else
        fprintf('\n%s\n',meExtObj.getReport(),meObj.getReport());
        fileId=fopen([mfilename('class') '_' tableName '_'...
            num2str(nTuples) '_'...
            'error_' datestr(now,'yyyymmdd_HHMMSS') '_'...
            regexprep(mxberry.system.getpidhost(),'\W','_')...
            '.log'],'w');
        fprintf(fileId,'%s\n%s',meExtObj.getReport(),meObj.getReport());
        fclose(fileId);
    end
end
end
%
function [retrieveTimeMat,isnErrorVec,...
    convertResultsTimeMat, selfRetrieveTimeMat,...
    prepareTimeMat,initialTime,dataSizeInBytes]=testRetrieve(varargin)
% TESTRETRIEVE tests different retrieve functions for different number of
% tuples

tStart=tic;
[reg,~,nTrials,maxExecTimeInSecs,raiseExceptionIfError,...
    singleExpRunFuncName,testName,tableName,retrieveModeName]=...
    mxberry.core.parseparext(varargin,[{...
    'nTrials'; 1; 'isscalar(x)&&isnumeric(x)&&isreal(x)'},{...
    'maxExecTimeInSecs'; Inf; 'isscalar(x)&&isnumeric(x)&&isreal(x)'},{...
    'raiseExceptionIfError'; true; 'isscalar(x)&&islogical(x)'},{...
    'singleExpRunFuncName';...
    'com.allied.pgmex.perftest.runsingleexperiment';'isstring(x)'},{...
    'testName'; ''; 'isstring(x)'},{...
    'tableName'; ''; 'isstring(x)'},{...
    'retrieveModeName'; 'cellarray'; 'isstring(x)'}],[2 3],...
    'regCheckList',{'isstring(x)','iscellofstring(x)',...
    'isscalar(x)&&isnumeric(x)&&isreal(x)'},...
    'propRetMode','separate');
connInfoStr=reg{1};
funcNameCVec=reg{2};
if numel(reg)>=3
    nMaxTuples=reg{3};
else
    nMaxTuples=Inf;
end
%% initial actions
allFuncMapCMat=eval([mfilename('class') '.ALL_FUNC_MAP_CMAT']);
[isFuncVec,indFuncVec]=ismember(lower(funcNameCVec),...
    lower(allFuncMapCMat(:,1)));
if ~all(isFuncVec)
    mxberry.core.throwerror('wrongInput',...
        'Given retrieve methods are unknown: %s',...
        mxberry.core.string.catwithsep(...
        reshape(funcNameCVec(~isFuncVec),1,[]),', '));
end
funcNameCVec=allFuncMapCMat(indFuncVec,1);
modeIndVec=vertcat(allFuncMapCMat{indFuncVec,2});
nFuncs=numel(modeIndVec);
retrieveTimeMat=nan(nFuncs,nTrials);
convertResultsTimeMat=nan(nFuncs,nTrials);
selfRetrieveTimeMat=nan(nFuncs,nTrials);
prepareTimeMat=nan(nFuncs,nTrials);
isnErrorVec=true(nFuncs,1);
dataSizeInBytesVec=nan(nFuncs,1);
%% measuring time for inserting
initialTime=toc(tStart);
modeMapCMat=eval([mfilename('class') '.MODE_MAP_CMAT']);
for iFunc=1:nFuncs
    funcName=funcNameCVec{iFunc};
    iMode=modeIndVec(iFunc);
    modeName=modeMapCMat{iMode,1};
    execFunc=modeMapCMat{iMode,2};
    for iTrial=1:nTrials
        try
            [retrieveTime,isnError,dataSizeInBytes,...
                convertResultsTime,selfRetrieveTime,prepareTime]=...
                feval(singleExpRunFuncName,@performRetrieve,...
                {testName},{modeName},{execFunc},{funcName},...
                {connInfoStr},{tableName},...
                {nMaxTuples},{raiseExceptionIfError},...
                {retrieveModeName});
        catch meObj
            messageStr=sprintf(...
                'Exception for function %s, number of tuples %d',...
                funcName,nMaxTuples);
            meExtObj=MException(meObj.identifier,messageStr);
            meExtObj=addCause(meExtObj,meObj);
            if raiseExceptionIfError
                warning(meObj.identifier,'\n%s\n',meObj.getReport());
                throw(meExtObj);
            else
                retrieveTime={NaN};
                isnError={false};
                dataSizeInBytes={NaN};
                convertResultsTime={NaN};
                selfRetrieveTime={NaN};
                prepareTime={NaN};
                warning(meExtObj.identifier,'\n%s\n%s\n',...
                    meExtObj.getReport(),meObj.getReport());
            end
        end
        retrieveTimeMat(iFunc,iTrial)=retrieveTime{:};
        isnErrorVec(iFunc)=isnError{:};
        dataSizeInBytesVec(iFunc)=dataSizeInBytes{:};
        convertResultsTimeMat(iFunc,iTrial)=convertResultsTime{:};
        selfRetrieveTimeMat(iFunc,iTrial)=selfRetrieveTime{:};
        prepareTimeMat(iFunc,iTrial)=prepareTime{:};
        if ~isnErrorVec(iFunc)||...
                retrieveTimeMat(iFunc,iTrial)>maxExecTimeInSecs
            break;
        end
    end
end
% in JDBC data size may be greater than necessary due, for instance, to the
% way of representation of dates, times and timestamps as strings, so we
% take here the mininum of sizes along all modes
dataSizeInBytes=min(dataSizeInBytesVec); 
end
%
function [retrieveTime,isnError,dataSizeInBytes,...
    convertResultsTime,selfRetrieveTime,prepareTime]=...
    performRetrieve(testName,modeName,execFunc,funcName,...
    connInfoStr,tableName,...
    nTuples,raiseExceptionIfError,retrieveModeName)
% PERFORMRETRIEVE retrieves data inserted in advance from database for
% given mode and test

retrieveTime=NaN;
isnError=true;
convertResultsTime=NaN;
selfRetrieveTime=NaN;
dataSizeInBytes=Inf;
%
tStart=tic();
% load parameters of test data
SInputTestData=load([...
    fileparts(mfilename('fullpath')) filesep 'input' filesep...
    'data_' testName '_' modeName '.mat']);
if isfield(SInputTestData,'dataCVec')
    nFields=numel(SInputTestData.dataCVec);
    SInputTestData=rmfield(SInputTestData,{'dataCVec','dataCMat'});
else
    nFields=size(SInputTestData.dataCMat,2);
    SInputTestData=rmfield(SInputTestData,{'dataCMat'});
end
isJDBC=strcmp(modeName,'jdbc');
% get some necessary fields from SInputTestData
fieldMapCMat=SInputTestData.fieldMapCMat;
testArrays=SInputTestData.testArrays;
if isJDBC&&testArrays
    isArrayFieldVec=~cellfun('isempty',fieldMapCMat(:,3));
end
isRetrieveAsStruct=strcmp(retrieveModeName,'structure');
%
dbConn=feval(execFunc,'connect',connInfoStr);
%
fieldSpecStr=...
    mxberry.core.string.catwithsep(strcat('%',fieldMapCMat(:,2)),' ');
indFieldCVec=num2cell(0:nFields-1);
%
if isJDBC
    prevDRF=setdbprefs('DataReturnFormat');
    setdbprefs('DataReturnFormat',retrieveModeName);
    isNullSet=~strcmp(retrieveModeName,'cellarray');
    if isNullSet
        prevNNR=setdbprefs('NullNumberRead');
        setdbprefs('NullNumberRead','NaN');
    end
end
%
prepareTime=toc(tStart);
pgArrayClassName='org.postgresql.jdbc.PgArray';
pgArrayClassNameLen=numel(pgArrayClassName);
tStart=tic;
try
    tSelfRetrieveStart=tic();
    res=feval(execFunc,'exec',dbConn,[...
        'SELECT * FROM ' tableName ' LIMIT ' num2str(nTuples)]);
    clearRes=true;
    switch modeName
        case 'jdbc'
            if isobject(res)||isjava(res)
                dataCMat=res.Data;
            else
                dataCMat=res;
                clearRes=false;
            end
            selfRetrieveTime=toc(tSelfRetrieveStart);
            tConvertResultsStart=tic();
            if isRetrieveAsStruct
                dataCMat=struct2cell(dataCMat);
            end
            if testArrays
                for iField=1:nFields
                    if isArrayFieldVec(iField)
                        if isRetrieveAsStruct
                            fieldValVec=dataCMat{iField};
                        else
                            fieldValVec=dataCMat(:,iField);
                        end
                        isCell=iscell(fieldValVec);
                        nElems=numel(fieldValVec);
                        resFieldValCVec=cell(nElems,1);
                        for iElem=1:nElems
                            if isCell
                                curVec=fieldValVec{iElem};
                            else
                                curVec=fieldValVec(iElem);
                                while ~strncmp(class(curVec),...
                                        pgArrayClassName,...
                                        pgArrayClassNameLen)
                                    curVec=curVec(1);
                                end
                            end
                            curVec=cell(curVec.getArray());
                            curVec=reshape(vertcat(curVec{:}),...
                                size(curVec));
                            resFieldValCVec{iElem}=curVec;
                        end
                        if isRetrieveAsStruct
                            dataCMat{iField}=resFieldValCVec;
                        else
                            dataCMat(:,iField)=resFieldValCVec;
                        end
                    end
                end
            end
            convertResultsTime=toc(tConvertResultsStart);
        case 'pgmex'
            outCVec=cell(1,nFields);
            [outCVec{:}]=feval(execFunc,'getf',res,fieldSpecStr,...
                indFieldCVec{:});
            selfRetrieveTime=toc(tSelfRetrieveStart);
            tConvertResultsStart=tic();
            outCVec=cellfun(@(x)x.valueVec,outCVec,'UniformOutput',false);
            switch retrieveModeName
                case 'numeric'
                    isnDoubleVec=~cellfun('isclass',outCVec,'double');
                    if any(isnDoubleVec)
                        outCVec(isnDoubleVec)=cellfun(@double,...
                            outCVec(isnDoubleVec),'UniformOutput',false);
                    end
                    dataCMat=horzcat(outCVec{:}); %#ok<NASGU>
                case 'cellarray'
                    isnCellVec=~cellfun('isclass',outCVec,'cell');
                    if any(isnCellVec)
                        outCVec(isnCellVec)=cellfun(@num2cell,...
                            outCVec(isnCellVec),'UniformOutput',false);
                    end
                    dataCMat=horzcat(outCVec{:}); %#ok<NASGU>
                case 'structure'
                    dataCMat=outCVec(:); %#ok<NASGU>
                otherwise
                    mxberry.core.throwerror('wrongParams',...
                        'Unknown retrieve mode: %s',retrieveModeName);
            end
            convertResultsTime=toc(tConvertResultsStart);
        otherwise
            mxberry.core.throwerror('wrongParams',...
                'Unknown mode: %s',modeName);
    end
    if clearRes
        feval(execFunc,'clear',res);
    end
    retrieveTime=toc(tStart);
    feval(execFunc,'finish',dbConn);
    dataSizeInBytes=getfield(whos('dataCMat'),'bytes');
    if isJDBC
        setdbprefs('DataReturnFormat',prevDRF);
        if isNullSet
            setdbprefs('NullNumberRead',prevNNR);
        end
    end
catch meObj
    if isJDBC
        setdbprefs('DataReturnFormat',prevDRF);
        if isNullSet
            setdbprefs('NullNumberRead',prevNNR);
        end
    end
    isnError=false;
    messageStr=sprintf(...
        'Exception for function %s, number of tuples %d',...
        funcName,nTuples);
    meExtObj=MException(meObj.identifier,messageStr);
    meExtObj=addCause(meExtObj,meObj);
    if raiseExceptionIfError
        fprintf('\n%s\n',meObj.getReport());
        throw(meExtObj);
    else
        fprintf('\n%s\n',meExtObj.getReport(),meObj.getReport());
        fileId=fopen([mfilename('class') '_' tableName '_'...
            num2str(nTuples) '_'...
            'error_' datestr(now,'yyyymmdd_HHMMSS') '_'...
            regexprep(mxberry.system.getpidhost(),'\W','_')...
            '.log'],'w');
        fprintf(fileId,'%s\n%s',meExtObj.getReport(),meObj.getReport());
        fclose(fileId);
    end
end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Auxiliary functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outMat=replicateTuples(inpMat,nReplicates,nOutTuples)
outMat=repmat(inpMat,nReplicates,1);
sizeVec=size(outMat);
sizeVec(1)=nOutTuples;
outMat=reshape(outMat(1:nOutTuples,:),sizeVec);
end
%
function resizeTrajFigure(hObject,~,~)
STestData=get(hObject,'UserData');
hAxes=STestData.hAxes;
nTuplesVec=STestData.nTuplesVec;
tickVec=get(hAxes,'XTick');
isDataSizeOutput=isfield(STestData,'dataSizeInBytesVec');
if isDataSizeOutput
    dataSizeOutFunc=STestData.dataSizeOutFunc;
    dataSizeInBytesVec=STestData.dataSizeInBytesVec;
    indEnd=find(~isnan(dataSizeInBytesVec),1,'last');
    if isempty(indEnd)
        curDataSizeVec=nan(numel(tickVec),1);
    else
        if indEnd>=2
            curDataSizeVec=interp1(nTuplesVec(1:indEnd),...
                dataSizeInBytesVec(1:indEnd),...
                tickVec,'linear','extrap');
        else
            [~,indNearest]=min(abs(tickVec-nTuplesVec(1)));
            scaleVec=tickVec/tickVec(indNearest);
            curDataSizeVec=dataSizeInBytesVec(1)*scaleVec;
        end
    end
    tickLabelCVec=arrayfun(...
        @(x,y)[num2str(x) '\newline' feval(dataSizeOutFunc,y)],...
        tickVec(:),curDataSizeVec(:),...
        'UniformOutput',false);
else
    tickLabelCVec=arrayfun(@num2str,tickVec(:),'UniformOutput',false);
end
set(hAxes,'XTickLabel',tickLabelCVec);
end