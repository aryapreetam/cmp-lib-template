@file:OptIn(ExperimentalWasmDsl::class)

import org.jetbrains.kotlin.gradle.ExperimentalWasmDsl

plugins {
  alias(libs.plugins.multiplatform)
  alias(libs.plugins.android.library)
  alias(libs.plugins.maven.publish)
  alias(libs.plugins.compose)
  alias(libs.plugins.compose.compiler)
  alias(libs.plugins.dokka)
}

kotlin {
  jvmToolchain(17)

  //androidTarget { publishLibraryVariants("release") }
  androidLibrary {
    namespace = "io.github.aryapreetam.fiblib"
    compileSdk = 35
    minSdk = 23
    withHostTest {  }
    androidResources {
      enable = true
    }
  }
  jvm()
  wasmJs { browser() }
  iosX64()
  iosArm64()
  iosSimulatorArm64()

  sourceSets {
    commonMain.dependencies {
      implementation(libs.compose.runtime)
      implementation(libs.compose.ui)
      implementation(libs.compose.foundation)
      // GUARDRAIL: Do NOT introduce host-specific dependencies (such as compose.desktop.currentOs)
      // here or in any published target. Doing so leaks host-specific Gradle dependency metadata
      // into the POM file published to Maven Central, breaking builds for consumers on other platforms.
      // Use platform-neutral/agnostic dependencies instead.
    }

    commonTest.dependencies {
      implementation(kotlin("test"))
    }

  }

  //https://kotlinlang.org/docs/native-objc-interop.html#export-of-kdoc-comments-to-generated-objective-c-headers
  targets.withType<org.jetbrains.kotlin.gradle.plugin.mpp.KotlinNativeTarget> {
    compilations["main"].compileTaskProvider.configure {
      compilerOptions {
        freeCompilerArgs.add("-Xexport-kdoc")
      }
    }
  }

}

//android {
//  namespace = "io.github.aryapreetam.fiblib"
//  compileSdk = 35
//
//  defaultConfig {
//    minSdk = 21
//  }
//}

dependencies {
  dokkaPlugin(libs.android.documentation.plugin)
}

//Publishing your Kotlin Multiplatform library to Maven Central
//https://www.jetbrains.com/help/kotlin-multiplatform-dev/multiplatform-publish-libraries.html
mavenPublishing {
  publishToMavenCentral()
  coordinates(
    project.group.toString(),
    findProperty("libArtifactId")?.toString() ?: "fiblib",
    project.version.toString()
  )

  pom {
    name = "Fibonacci Library"
    description = "Compose Multiplatform library for fibonacci numbers"
    url = "https://aryapreetam.github.io/cmp-lib-template" //todo

    licenses {
      license {
        name = "MIT"
        url = "https://opensource.org/licenses/MIT"
      }
    }

    developers {
      developer {
        id = "aryapreetam" //todo
        name = "Preetam Bhosle" //todo
      }
    }

    scm {
      url = "https://github.com/aryapreetam/cmp-lib-template" //todo
    }
  }
  // Sign publications if either local keyId or CI signingInMemoryKey is available
  if (project.hasProperty("signing.keyId") || project.hasProperty("signingInMemoryKey")) {
    signAllPublications()
  }
}
