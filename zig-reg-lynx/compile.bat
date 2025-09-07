@echo off
set "JAVA_HOME=C:\Program Files\Java\jdk-21"
echo JAVA_HOME is %JAVA_HOME%

set JNI_INCLUDES=-I"%JAVA_HOME%\include" -I"%JAVA_HOME%\include\win32"

set OUTPUT=reglynx.dll

:: Step 1: build the Zig library (produces main.dll + main.h)
zig build-lib src\main.zig -O ReleaseSafe -target x86_64-windows-gnu -femit-h

:: Step 2: compile the JNI wrapper and link against main.dll
zig cc -shared -target x86_64-windows-gnu %JNI_INCLUDES% src\jni_wrapper.c main.lib -o %OUTPUT%