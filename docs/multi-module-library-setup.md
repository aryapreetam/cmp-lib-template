# 🔀 Transitioning to a Multi-Module Library Structure

By default, this template produces a lightweight, single-module KMP library (`:library-module`). This is ideal for most utility and UI libraries. However, if your library grows in complexity—for example, if you want a core engine with optional feature modules or client/server components (similar to systems like [Parikshan](https://github.com/aryapreetam/parikshan))—you can expand it into a multi-module structure by following these steps:

### 1. Create the New Submodule Directory
Under your library's root directory, create a new folder (e.g., `library-module-core/`) with standard KMP sources:
```
├── library-module/
├── library-module-core/              # New submodule
│   ├── src/commonMain/kotlin/
│   └── build.gradle.kts
```

### 2. Register the Submodule in `settings.gradle.kts`
Open the root `settings.gradle.kts` file and include the new project:
```kotlin
include(":library-module")
include(":library-module-core") // Register your new library module
```

### 3. Wire Dependencies Between Submodules
If your main `:library-module` module depends on `:library-module-core`, declare it inside `library-module/build.gradle.kts` under `commonMain`:
```kotlin
kotlin {
    sourceSets {
        commonMain.dependencies {
            api(project(":library-module-core")) // Use api() to expose library-module-core's types to consumers
        }
    }
}
```

### 4. Configure Maven Publication for Submodules
Ensure that `library-module-core` applies the publishing plugin and is assigned coordinates. In `library-module-core/build.gradle.kts`:
```kotlin
plugins {
    alias(libs.plugins.android.kotlin.multiplatform.library)
    alias(libs.plugins.maven.publish)
}

// Inherit group and version from root gradle.properties, or override locally
```
When publishing, this ensures both `:library-module` and `:library-module-core` generate their respective KMP platform metadata, letting consumers resolve transitive dependencies seamlessly from Maven Central.
