function SInput=patch_003_fix_loggingprops(~,SInput)
SInput.logging.log4jSettings=strrep(SInput.logging.log4jSettings,'pgmextypes.','com.allied.pgmex.');
end