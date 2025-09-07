#!/usr/bin/env bash
set -e

# Define JDK path (adjust to your system)
JAVA_HOME="/c/Program Files/Java/jdk-21"

# Echo to confirm the variable
echo "JAVA_HOME is set to: $JAVA_HOME"

# Set JNI include flags
JNI_INCLUDES="-I\"$JAVA_HOME/include\" -I\"$JAVA_HOME/include/win32\""

# Compile Zig library (static)
zig build-lib src/main.zig -static -O ReleaseSafe -target x86_64-windows-gnu -femit-h

# Compile JNI wrapper into a DLL, linking the Zig library
zig cc -shared -target x86_64-windows-gnu $JNI_INCLUDES src/jni_wrapper.c main.lib -o jni_wrapper.dll

# Confirm output
file jni_wrapper.dll
