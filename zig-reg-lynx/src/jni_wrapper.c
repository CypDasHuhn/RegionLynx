#include <jni.h>
#include "main.h"   // include the Zig header to see add()

JNIEXPORT jint JNICALL Java_dev_cypdashuhn_reglynx_JNI_add(JNIEnv* env, jobject obj, jint a, jint b) {
    return add(a, b);
}
