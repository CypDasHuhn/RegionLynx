package dev.cypdashuhn.reglynx

object JNI {
    init {
        System.loadLibrary("reglynx")
    }

    private external fun add(a: Int, b: Int): Int

    fun callAdd(a: Int, b: Int): Int {
        return add(a, b)
    }
}

fun main() {
    println(JNI.callAdd(1, 2))
}