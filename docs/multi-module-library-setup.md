# 🔀 Transitioning to a Multi-Module Library Structure

By default, this template produces a lightweight, single-module KMP library (`:lib`). This is ideal for most utility and UI libraries. However, if your library grows in complexity—for example, if you want a core engine with optional feature modules or client/server components (similar to systems like [Parikshan](https://github.com/aryapreetam/parikshan))—you can expand it into a multi-module structure by following these steps:

### 1. Create the New Submodule Directory
Under your library's root directory, create a new folder (e.g., `lib-core/`) with standard KMP sources:
```
├── lib/
├── lib-core/                        # New submodule
│   ├── src/commonMain/kotlin/
│   └── build.gradle.kts
```

### 2. Register the Submodule in `settings.gradle.kts`
Open the root `settings.gradle.kts` file and include the new project:
```kotlin
include(":lib")
include(":lib-core") // Register your new library module
```

### 3. Wire Dependencies Between Submodules
If your main `:lib` module depends on `:lib-core`, declare it inside `lib/build.gradle.kts` under `commonMain`:
```kotlin
kotlin {
    sourceSets {
        commonMain.dependencies {
            api(project(":lib-core")) // Use api() to expose lib-core's types to consumers
        }
    }
}
```

### 4. Configure Maven Publication for Submodules
Ensure that `lib-core` applies the publishing plugin and is assigned coordinates. In `lib-core/build.gradle.kts`:
```kotlin
plugins {
    alias(libs.plugins.android.kotlin.multiplatform.library)
    alias(libs.plugins.maven.publish)
}

// Inherit group and version from root gradle.properties, or override locally
```
When publishing, this ensures both `:lib` and `:lib-core` generate their respective KMP platform metadata, letting consumers resolve transitive dependencies seamlessly from Maven Central.
