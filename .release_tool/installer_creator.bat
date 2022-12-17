@echo off

cd ".release_tool\Inno Setup 6\"
.\ISCC.exe
.\iscc "..\installer_creator.iss"