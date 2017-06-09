set locDir=%~dp0
rmdir /s /q "%locDir%..\..\..\..\docs"
xcopy /f /y "%locDir%README.md" "%locDir%..\..\..\..\README.md"
python %locDir%prep4doxymat.py %locDir%..\.. %locDir%..\..\..\..\TTD\mxberry-core-doxygen-prep %locDir%..\..\..\..\TTD\mxberry-core-doxygen-garbage
for /f %%i in ('cd') do set curDir=%%i
cd %locDir%
doxygen
echo "">%locDir%..\..\..\..\docs\.nojekyll
cd %curDir%