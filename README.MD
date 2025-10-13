<h1 align="center">Compose Multiplatform Library Template</h1>

<p align="center">
  <img src="https://img.shields.io/badge/Compose%20Multiplatform-v1.9.0-4285F4?logo=jetpackcompose" alt="Compose Multiplatform Version">
  <img src="https://img.shields.io/badge/Kotlin-v2.2.20-blueviolet?logo=kotlin" alt="Kotlin Version">
</p>

<p align="center">
  <a href="https://github.com/aryapreetam/cmp-lib-template/actions/workflows/release.yml">
    <img src="https://github.com/aryapreetam/cmp-lib-template/actions/workflows/release.yml/badge.svg" alt="Release workflow status">
  </a>
  <a href="https://mvnrepository.com/artifact/io.github.aryapreetam/fiblib">
    <img src="https://img.shields.io/maven-central/v/io.github.aryapreetam/fiblib?label=Maven%20Central&color=blue" alt="Maven Central Version">
  </a>
  <a href="https://github.com/aryapreetam/cmp-lib-template/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="MIT License">
  </a>
</p>

<!-- New: Brief template description -->
This repository is a ready-to-ship template for building and releasing Compose Multiplatform libraries. It automates the heavy lifting so you can focus on your API and UX:

- Turns your README into a library homepage and publishes it via GitHub Pages (rendered using Docsify).
- Builds and deploys a wasm demo to `/demo` so users can try your library in the browser.
- Generates and publishes API docs (Dokka) to `/api`.
- Produces downloadable sample app executables (APK, DMG, iOS Simulator zip, wasm bundle) so users can validate the library on their device/emulator quickly.
- Wires a complete CI/CD: test → package → GitHub Release → Pages deploy → optional Maven Central publish on tags.

Wasm Demo: 
[![Try Live Demo](https://img.shields.io/badge/Try%20Live%20Demo-Web%20wasmJs-blueviolet?style=for-the-badge)](https://aryapreetam.github.io/cmp-lib-template/demo/)

API Docs:
[![Library API Docs](https://img.shields.io/badge/API%20Reference-Library%20Docs-green?style=for-the-badge)](https://aryapreetam.github.io/cmp-lib-template/api/)

---

## 🛠️ Using This Template

**New to this template?** Check out the complete guide: [📖 Using This Template for Your Library](docs/using-this-template.md)

**Quick setup:**
1. Click "Use this template" to create your repo
2. Follow the [setup guide](docs/using-this-template.md) to customize for your library
3. Configure [GitHub secrets](docs/github-secrets-setup.md) for publishing
4. Start coding your library!

**For contributors:** See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

---

## Quick Start

Add the dependency to your Kotlin Multiplatform library or app. Replace coordinates with your published group/artifact.

Option A — Version catalog (recommended)

1) In `gradle/libs.versions.toml`:

```toml
yourlib = "0.1.0"

[libraries]
yourlib = { module = "io.github.yourorg:your-lib", version.ref = "yourlib" }
```

2) In your module's `build.gradle.kts`:

```kotlin
kotlin {
  sourceSets {
    val commonMain by getting {
      dependencies {
        implementation(libs.yourlib)
      }
    }
  }
}
```

Option B — Hardcoded dependency (direct version)
[versions]

```kotlin
kotlin {
  sourceSets {
    val commonMain by getting {
        // From Maven Central release
        // implementation("io.github.yourorg:your-lib:0.1.0-SNAPSHOT")
      }
    }
  }
}
```

If using snapshots from Maven Local, ensure:

```kotlin
repositories {
  mavenLocal()
  mavenCentral()
}
```

Minimal usage example:

```kotlin
import fiblib.getFibonacciNumbers

val first10 = getFibonacciNumbers(10)
println(first10)
```

---

**⬇️ Download the latest sample app executables for your platform:**

[![Download for Mac (Intel)](https://img.shields.io/badge/Download--Mac--x64--DMG-blue?style=for-the-badge)](https://github.com/aryapreetam/cmp-lib-template/releases/latest/download/sample-app-desktop-x64.dmg)
[![Download for Mac (Apple Silicon)](https://img.shields.io/badge/Download--Mac--arm64--DMG-blue?style=for-the-badge)](https://github.com/aryapreetam/cmp-lib-template/releases/latest/download/sample-app-desktop-arm64.dmg)
[![Download for Windows](https://img.shields.io/badge/Download--Windows--MSI-0078D4?style=for-the-badge&logo=windows)](https://github.com/aryapreetam/cmp-lib-template/releases/latest/download/sample-app-windows.msi)
[![Download Android APK](https://img.shields.io/badge/Download--Android--APK-green?style=for-the-badge&logo=android)](https://github.com/aryapreetam/cmp-lib-template/releases/latest/download/sample-app-android-unsigned.apk)
[![Download Web (WASM bundle)](https://img.shields.io/badge/Download--Web--Wasm--zip-purple?style=for-the-badge)](https://github.com/aryapreetam/cmp-lib-template/releases/latest/download/sample-app-wasm.zip)
[![Download iOS Simulator App](https://img.shields.io/badge/Download--iOS--Simulator--zip-orange?style=for-the-badge&logo=apple)](https://github.com/aryapreetam/cmp-lib-template/releases/latest/download/sample-app-ios-simulator.zip)

### Testing on iOS Simulator

- Download `sample-app-ios-simulator.zip` from
  the [latest release](https://github.com/aryapreetam/cmp-lib-template/releases).
- Unzip it to get `sample-app-ios-simulator.app`.
- To install:
    1. Open your iOS Simulator in Xcode
    2. Drag the `.app` onto the Simulator window OR run:
       ```sh
       xcrun simctl install booted /path/to/sample-app-ios-simulator.app
       ```
- The sample app will now appear and can be launched directly from the Simulator!

**Running the Downloaded Desktop App (macOS: DMG)**

- Download the DMG from GitHub Releases for your Mac architecture (Intel or Apple Silicon).
- Open (mount) the DMG and drag the app to your Applications folder (or Desktop).
- **When you try to open the app for the first time, you may see a Gatekeeper warning:**

  <p align="center">
    <img src="readme_images/desktop_app_run.png" alt="Gatekeeper dialog" width="380" />
    <br/>
    <sub>Mac Gatekeeper dialog when opening the app for the first time</sub>
  </p>

- To allow running the app:
     1. **Right-click (control-click) the app and select "Open".**
     2. In the dialog, click "Open". (If there is a question mark in the corner, you can click it for more info.)
     3. The app will start. This is safe for open-source/test builds.

> This is a normal security step for all open-source and CI-generated Mac executables. Apps are signed ad-hoc for
> internal/dev use, not with a public Apple developer ID.

### Download Desktop App for Your Mac

On every release, two separate DMG files are built:

| Platform         | File Name                    | Download for…                                          |
|------------------|------------------------------|--------------------------------------------------------|
| 🍏 Intel Mac     | sample-app-desktop-x64.dmg   | Intel-based Macs (2019 or earlier, or with Intel CPUs) |
| 🍎 Apple Silicon | sample-app-desktop-arm64.dmg | Newer Macs with M1/M2/M3 chips                         |

You can find both files in the Assets section of
each [GitHub Release](https://github.com/aryapreetam/cmp-lib-template/releases).

_**Tip**: Unsure about your Mac's type? Click the Apple logo → "About This Mac". If it says Intel, download x64; if it
says M1, M2, or M3, download arm64._

You can also run Gradle tasks in the terminal:

* `./gradlew run` to run application
* `./gradlew package` to store native distribution into `build/compose/binaries`

### Run Sample App

- Desktop JVM: `./gradlew :sample:composeApp:run`
- Android: `open project in Android Studio and run the sample app`
- iOS: `open 'sample/iosApp/iosApp.xcodeproj' in Xcode and run the sample app`
- Wasm: `./gradlew :sample:composeApp:wasmJsBrowserRun`

---

## Dokka UI comparison

The API documentation appearance has improved with Dokka 2.1.0-Beta. Below is a quick visual comparison.

| Dokka (2.0.0)                                           | Dokka (2.1.0-Beta)                                    |
|---------------------------------------------------------|-------------------------------------------------------|
| ![API index old](readme_images/api-doc-index-old.png)   | ![API index new](readme_images/api-doc-index-new.png) |
| ![Function doc new](readme_images/function-doc-old.png) | ![Function doc old](readme_images/function-doc-new.png) |


## CI/CD overview

This repo ships with an opinionated CI/CD that builds, tests, packages, releases, and deploys docs & demo automatically on tags.

```mermaid
flowchart TD
    A["Lint"] --> B["Build & Test - Library + Sample (all targets)"]
    B --> C["Android UI tests (emulator) & Maestro E2E tests(iOS & Android)"]
    C --> D["Build artifacts - all targets APK • DMG • iOS Simulator zip • wasm bundle"]
    D --> E["Create GitHub Release and upload artifacts"]
    E --> F["Publish to Maven Central"]
    E --> G["Deploy GitHub Pages README site (Docsify) + wasm demo + API docs"]
```

Key points:
- Triggered on version tags (`v*`) and manual runs.
- Lint first, then build/test library targets followed by sample targets.
- Android UI tests on emulator before packaging.
- GitHub Release includes platform artifacts for quick validation.
- GitHub Pages hosts the README homepage (Docsify), wasm demo, and Dokka API docs.

---

### Publish to MavenLocal

1) Run `./gradlew :lib:publishToMavenLocal`
2) Open `~/.m2/repository/fiblib/`

### Publish to MavenCentral

Follow https://www.jetbrains.com/help/kotlin-multiplatform-dev/multiplatform-publish-libraries.html & complete all necessary steps.

The above article focuses on publishing to MavenCentral.
But if you want to verify publishing from your local machine, you can follow below steps:

1) Add these lines to `~/.gradle/gradle.properties`(not to be confused with `gradle.properties` in project root):
   ```
   signing.keyId=XXXXXXXX
   signing.password=[key password]
   signing.secretKeyRingFile=../XXXXXXXX.gpg
   mavenCentralUsername=[generated username]
   mavenCentralPassword=[generated password]
   ```
   For `GPG_KEY_CONTENTS` secret(signing.secretKeyRingFile above), can get plain text version of gpg key using below commands.
   ```
   # This will print the private GPG key in plain text.
   gpg --export-secret-keys --armor <key id>
   
   # this will copy it for pasting in github actions secrets.
   gpg --export-secret-keys --armor <key id> | pbcopy
   ```
5) Run `./gradlew :lib:publishAndReleaseToMavenCentral --no-configuration-cache`

## License

MIT License © 2025 aryapreetam and contributors. See [LICENSE](./LICENSE) for details.

---

## 📋 TBD (To Be Done) - Future Enhancements

This section lists planned improvements and features for the template. Contributions are welcome!

### 🔧 Code Quality & Tooling

- [ ] **Add Detekt** - Static code analysis for Kotlin
  - Configure rules for library code
  - Integrate into CI pipeline
  
- [ ] **Add ktlint** - Kotlin code formatter
  - Consistent code style across project
  - Auto-formatting in CI
  
- [ ] **Add Kover** - Code coverage reporting
  - Track test coverage across platforms
  - Publish coverage reports to Codecov
  
- [ ] **Add Dependabot** - Automated dependency updates
  - Weekly checks for Gradle dependencies
  - Weekly checks for GitHub Actions versions

### 🧪 Testing Enhancements

- [ ] **Screenshot Testing** - Visual regression testing
  - Add Paparazzi for Android
  - iOS screenshot tests using XCTest
  
- [ ] **Performance Benchmarking** - Track performance metrics
  - Integrate androidx.benchmark for Android
  - Baseline profiles for library code

### 📚 Documentation & Examples

- [ ] **Multi-Module Support Guide**
  - Document how to structure multi-module libraries
  - Example with feature modules
  
- [ ] **Compose Resources Guide**
  - How to bundle images, strings, fonts
  - Localization examples
  - Resource packaging best practices
  
- [ ] **Video Tutorial**
  - 10-minute walkthrough of using the template
  - Publishing to Maven Central demo
  - Deploying demo and docs
  
- [ ] **Blog Post / Article**
  - Write comprehensive guide on Dev.to or Medium
  - Share on Reddit r/Kotlin and r/Kotlinmobile

### 🤖 Automation Improvements

- [ ] **Automated Changelog Generation**
  - Use conventional commits
  - Auto-generate release notes from commits/PRs
  - Integrate github-changelog-generator
  
- [ ] **Version Bump Automation**
  - Script to update version in lib/build.gradle.kts
  - Semantic versioning support
  - Consider semantic-release integration
  
- [ ] **Automated Screenshots**
  - Generate sample app screenshots during CI
  - Attach to releases or README

### 🖥️ Platform Support

- [ ] **Linux Desktop Packaging**
  - Add DEB/RPM package generation
  - AppImage support
  
- [ ] **Additional Apple Platforms**
  - watchOS support
  - tvOS support
  - macCatalyst support
  
- [ ] **Desktop Linux Native Build**
  - Build on Linux runners for native Linux apps
  - Better Linux desktop integration

### 🌐 GitHub Pages Enhancements

- [ ] **Custom Domain Support**
  - Document setup for custom domains
  - DNS configuration guide
  
- [ ] **Improved Docsify Theme**
  - Custom theme matching library branding
  - Dark mode support
  - Better mobile responsive design
  
- [ ] **Search Functionality**
  - Add search to documentation site
  - Full-text search across API docs

### 🔐 Security & Best Practices

- [ ] **Vulnerability Scanning**
  - Integrate Snyk or similar
  - Automated security updates
  
- [ ] **SBOM Generation**
  - Generate Software Bill of Materials
  - Dependency transparency
  
- [ ] **Signed Releases**
  - Sign release artifacts with GPG
  - Provide checksums (SHA256)

### 📦 Distribution & Publishing

- [ ] **JitPack Support**
  - Alternative to Maven Central
  - Easier for snapshot builds
  
- [ ] **NPM Package for Wasm**
  - Publish wasm builds to NPM
  - Better integration with web projects
  
- [ ] **CocoaPods Support**
  - Publish iOS framework to CocoaPods
  - Easier iOS integration

### 🎨 Template Features

- [ ] **Template Initialization Script**
  - Interactive CLI to customize template
  - Automated find/replace for package names
  - Git history cleanup

---

### 💡 Have an Idea?

If you have suggestions for improvements or want to contribute:
1. Check if the feature is already listed above
2. Open an issue to discuss your idea
3. Submit a PR with your implementation

**Priority**: Items marked with 🔥 are high priority and would have the most impact.

---

## 🤝 Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed contribution guidelines.
