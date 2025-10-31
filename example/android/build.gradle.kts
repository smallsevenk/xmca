allprojects {
    repositories {
        maven {
            url = uri("http://nexus.test.sharexm.cn/repository/xmai/")
            setAllowInsecureProtocol(true)
            credentials {
                username = "xmai"                    // 账号
                password = "C9beGFAFOxNnQQIo"         // 密码
            }
        }
        google()
        mavenCentral()
        maven { url = uri("https://jitpack.io") }  // 必须添加此行
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
