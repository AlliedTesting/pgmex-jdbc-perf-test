function SInput=patch_004_switch2mlunitext_runner(~,SInput)
SInput=rmfield(SInput,'emailNotification');
SRep=SInput.reporting;
SInput=rmfield(SInput,'reporting');
SInput.reporting.JUnitXMLReport.isEnabled=SRep.antXMLReport.isEnabled;
SInput.reporting.JUnitXMLReport.dirNameByTheFollowingFile=SRep.antXMLReport.dirNameByTheFollowingFile;
SInput.reporting.JUnitXMLReport.dirNameSuffix=SRep.antXMLReport.dirNameSuffix;