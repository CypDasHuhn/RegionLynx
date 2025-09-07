plugins {
    kotlin("jvm") version "2.1.20"
    id("io.github.fletchmckee.ktjni") version "0.1.0"
}
// If no `outputDir` is specified, it defaults to the following location:
// {projectDir}/build/generated/ktjni/{sourceType}/{sourceSet}
ktjni {
    outputDir = file("./zig-reg-lynx")
}

group = "dev.cypdashuhn.reglynx"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
    maven {
        url = uri("https://central.sonatype.com/repository/maven-snapshots/") // Snapshot versions
    }
}

dependencies {
    testImplementation(kotlin("test"))
}

tasks.test {
    useJUnitPlatform()
}
kotlin {
    jvmToolchain(21)
}

tasks.withType<JavaExec> {
    // Set the folder where your JNI DLLs live
    systemProperty("java.library.path", "C:\\Users\\c.lenoir\\source\\repos\\RegionLynx\\zig-reg-lynx")
}
