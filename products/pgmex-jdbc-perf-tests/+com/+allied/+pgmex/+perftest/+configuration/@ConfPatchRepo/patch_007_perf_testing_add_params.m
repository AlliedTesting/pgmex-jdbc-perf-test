function SInput=patch_007_perf_testing_add_params(~,SInput)
SInput.performanceTestingParams.singleExpRunFuncName='runsingleexperiment';
SInput.performanceTestingParams.testModeName='all'; % may be 'all', 'pgmex' or 'jdbc'
