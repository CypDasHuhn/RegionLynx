#include <jni.h>
// #include "../kotlin/main/dev_cypdashuhn_reglynx_JNI.h"   // include the Zig header to see add()
#include "main.h"

JNIEXPORT jint JNICALL Java_dev_cypdashuhn_reglynx_JNI_add(JNIEnv* env, jobject obj, jint a, jint b) {
    return add(a, b);
}
