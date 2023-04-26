@echo off

set BUILD_TYPE=debug
if "%1" == "-release" set BUILD_TYPE=release


if "%BUILD_TYPE%" == "debug" (
    echo Building debug...
    odin build .\src -debug -collection:windows=src\windows
) else (
    echo Building release...
    odin build .\src -o:speed -collection:windows=src\windows 
)

echo Done.