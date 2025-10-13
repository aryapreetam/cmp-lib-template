# 🛠️ Using This Template for Your Own Library

This guide walks you through adapting this template for your own Compose Multiplatform library.

---

## 📋 Quick Checklist

- [ ] Fork/clone this repository
- [ ] Rename all identifiers (package names, artifact IDs)
- [ ] Update library metadata (POM info)
- [ ] Setup GitHub secrets for publishing
- [ ] Write your library code
- [ ] Update documentation
- [ ] Test publishing flow
- [ ] Create your first release

---

## Step 1: Fork or Use Template

### Option A: Use as Template (Recommended)
1. Click "Use this template" button on GitHub
2. Create a new repository with your library name
3. Clone your new repository

### Option B: Fork
1. Fork this repository
2. Clone your fork
3. Remove the template-specific commit history (optional):
   ```bash
   git checkout --orphan new-main
   git add -A
   git commit -m "Initial commit from template"
   git branch -D main
   git branch -m main
   git push -f origin main
   ```

---

## Step 2: Rename Identifiers

### 2.1 Update Package Names

**In `lib/build.gradle.kts`:**
```kotlin
android {
  namespace = "io.github.yourname.yourlibname"  // Change this
  // ...
}

mavenPublishing {
  coordinates("io.github.yourname", "yourlibname", "0.1.0")  // Change group & artifact
  // ...
}
```

**In `lib/src/commonMain/kotlin/`:**
1. Rename package directory from `fiblib/` to `yourlibname/`
2. Update package declarations in all `.kt` files:
   ```kotlin
   package io.github.yourname.yourlibname  // Change this
   ```

**In `lib/src/commonTest/kotlin/`:**
1. Rename test package directory
2. Update package declarations

### 2.2 Update Sample App

**In `sample/composeApp/build.gradle.kts`:**
```kotlin
android {
  namespace = "sample.app"  // You can keep this or change it
  defaultConfig {
    applicationId = "sample.app"  // Change if desired
  }
}
```

**In `sample/composeApp/src/commonMain/kotlin/`:**
- Update imports to use your new package name

### 2.3 Update Root Configuration

**In `settings.gradle.kts`:**
```kotlin
rootProject.name = "your-lib-name"  // Change this

include(":lib")
include(":sample:composeApp")
```

### 2.4 Find & Replace

Use global find/replace in your IDE:
- Find: `io.github.aryapreetam` → Replace: `io.github.yourname`
- Find: `fiblib` → Replace: `yourlibname`
- Find: `aryapreetam` → Replace: `yourname`
- Find: `cmp-lib-template` → Replace: `your-repo-name`

---

## Step 3: Update Library Metadata

**In `lib/build.gradle.kts` - Update POM info:**

```kotlin
mavenPublishing {
  coordinates("io.github.yourname", "yourlibname", "0.1.0")

  pom {
    name = "Your Library Name"  // Change
    description = "Description of what your library does"  // Change
    url = "https://yourname.github.io/your-repo"  // Change

    licenses {
      license {
        name = "MIT"  // Or your chosen license
        url = "https://opensource.org/licenses/MIT"
      }
    }

    developers {
      developer {
        id = "yourname"  // Change
        name = "Your Full Name"  // Change
        email = "your.email@example.com"  // Optional
      }
    }

    scm {
      url = "https://github.com/yourname/your-repo"  // Change
      connection = "scm:git:git://github.com/yourname/your-repo.git"  // Optional
      developerConnection = "scm:git:ssh://git@github.com/yourname/your-repo.git"  // Optional
    }
  }
}
```

---

## Step 4: Setup GitHub Secrets

### 4.1 Create Sonatype Account

1. Go to https://central.sonatype.com/
2. Sign up for an account
3. Verify your namespace (e.g., `io.github.yourname`)
   - For GitHub: Use `io.github.yourname` and verify via a public repo

### 4.2 Generate GPG Key

```bash
# Generate a new GPG key
gpg --full-generate-key
# Choose: RSA, 4096 bits, no expiration
# Enter your name and email

# List your keys to find the key ID
gpg --list-secret-keys --keyid-format=long
# Output looks like: sec   rsa4096/ABCD1234EFGH5678 2024-01-01
# Key ID is: ABCD1234EFGH5678

# Export the private key (ASCII-armored)
gpg --export-secret-keys --armor ABCD1234EFGH5678 > private-key.asc

# Upload public key to keyserver (required by Maven Central)
gpg --keyserver keyserver.ubuntu.com --send-keys ABCD1234EFGH5678
```

### 4.3 Add GitHub Secrets

Go to: **Your Repo → Settings → Secrets and variables → Actions → New repository secret**

Add these 5 secrets:

| Secret Name | Value | How to Get |
|------------|-------|------------|
| `MAVEN_CENTRAL_USERNAME` | Your Sonatype username | From step 4.1 |
| `MAVEN_CENTRAL_PASSWORD` | Your Sonatype password | From step 4.1 (or generate token) |
| `SIGNING_KEY_ID` | Last 8 chars of GPG key ID | e.g., `EFGH5678` |
| `SIGNING_PASSWORD` | Your GPG key passphrase | What you entered when creating key |
| `GPG_KEY_CONTENTS` | Contents of `private-key.asc` | Copy entire file including BEGIN/END lines |

**Important:** For `GPG_KEY_CONTENTS`, copy the ENTIRE content including:
```
-----BEGIN PGP PRIVATE KEY BLOCK-----

lQdGBF...base64-encoded-content...
-----END PGP PRIVATE KEY BLOCK-----
```

---

## Step 5: Update Documentation

### 5.1 Update README.MD

Replace template-specific content:

```markdown
# Your Library Name

Brief description of what your library does.

## Features

- Feature 1
- Feature 2
- Feature 3

## Installation

[Keep the version catalog and dependency instructions, update coordinates]

## Usage

[Add your usage examples]

## Download Sample Apps

[Keep the download badges, they'll work automatically with releases]
```

**Find and replace in README.MD:**
- `Compose Multiplatform Library Template` → `Your Library Name`
- `cmp-lib-template` → `your-repo-name`
- `aryapreetam` → `yourname`
- `fiblib` → `yourlibname`
- All usage examples with your actual library code

### 5.2 Update LICENSE

Replace the name and year in `LICENSE` file:
```
MIT License

Copyright (c) 2025 Your Name

[Rest of MIT license text]
```

### 5.3 Update CONTRIBUTING.md

Replace repository-specific URLs:
- `https://github.com/aryapreetam/cmp-lib-template` → Your repo URL

---

## Step 6: Write Your Library Code

### 6.1 Remove Template Code

1. Delete `lib/src/commonMain/kotlin/fiblib/Fibonacci.kt`
2. Delete `lib/src/commonTest/kotlin/fiblib/FibonacciTest.kt`

### 6.2 Add Your Code

Create your library files in `lib/src/commonMain/kotlin/yourpackage/`:

```kotlin
// lib/src/commonMain/kotlin/io/github/yourname/yourlibname/YourClass.kt
package io.github.yourname.yourlibname

/**
 * Your main library class or function
 */
fun yourAwesomeFunction(): String {
    return "Hello from your library!"
}
```

### 6.3 Add Tests

Create tests in `lib/src/commonTest/kotlin/yourpackage/`:

```kotlin
// lib/src/commonTest/kotlin/io/github/yourname/yourlibname/YourTest.kt
package io.github.yourname.yourlibname

import kotlin.test.Test
import kotlin.test.assertEquals

class YourTest {
    @Test
    fun testYourAwesomeFunction() {
        val result = yourAwesomeFunction()
        assertEquals("Hello from your library!", result)
    }
}
```

### 6.4 Update Sample App

Update `sample/composeApp/src/commonMain/kotlin/sample/app/App.kt` to demonstrate your library:

```kotlin
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import io.github.yourname.yourlibname.yourAwesomeFunction

@Composable
fun App() {
    Text(yourAwesomeFunction())
}
```

---

## Step 7: Test Locally

### 7.1 Build & Test

```bash
# Clean build
./gradlew clean build

# Run all tests
./gradlew test

# Test on specific platforms
./gradlew :lib:jvmTest
./gradlew :lib:iosSimulatorArm64Test
./gradlew :lib:wasmJsBrowserTest
```

### 7.2 Test Sample Apps

```bash
# Android
./gradlew :sample:composeApp:assembleDebug

# Desktop
./gradlew :sample:composeApp:run

# Web/wasm
./gradlew :sample:composeApp:wasmJsBrowserDevelopmentRun --continuous
```

### 7.3 Test Publishing Locally

```bash
# Publish to Maven Local
./gradlew :lib:publishToMavenLocal

# Check it exists
ls ~/.m2/repository/io/github/yourname/yourlibname/
```

---

## Step 8: Test CI/CD Pipeline

### 8.1 Push Changes

```bash
git add .
git commit -m "Initial library setup"
git push origin main
```

This will trigger the `push-ci.yml` workflow which runs:
- Lint checks
- All platform tests (JVM, iOS, wasm, Android)
- Android UI tests

### 8.2 Monitor Workflow

Go to: **Your Repo → Actions tab**

Verify all jobs pass:
- ✅ lint
- ✅ lib-tests (jvm, ios, wasm)
- ✅ test-android-unit
- ✅ android-ui-tests

### 8.3 Fix Any Failures

Common issues:
- Package name mismatches
- Missing imports
- Test failures due to removed template code

---

## Step 9: Create Your First Release

### 9.1 Verify Secrets

Double-check all 5 GitHub secrets are set correctly:
- MAVEN_CENTRAL_USERNAME
- MAVEN_CENTRAL_PASSWORD
- SIGNING_KEY_ID
- SIGNING_PASSWORD
- GPG_KEY_CONTENTS

### 9.2 Create Release Tag

```bash
# Ensure version in lib/build.gradle.kts is correct
# coordinates("io.github.yourname", "yourlibname", "0.1.0")

git tag v0.1.0
git push origin v0.1.0
```

### 9.3 Monitor Release Workflow

Go to: **Actions → Publish Multiplatform Release**

The workflow will:
1. ✅ Run CI (lint + tests)
2. ✅ Build artifacts (APK, DMG x2, wasm, iOS)
3. ✅ Create GitHub Release
4. ✅ Publish to Maven Central
5. ✅ Deploy docs to GitHub Pages

### 9.4 Verify Publication

**GitHub Release:**
- Go to: **Your Repo → Releases**
- Verify artifacts are attached

**Maven Central:**
- Wait ~30 minutes for sync
- Check: https://central.sonatype.com/artifact/io.github.yourname/yourlibname

**GitHub Pages:**
- Go to: **Settings → Pages**
- Enable Pages if not already enabled
- Visit: `https://yourname.github.io/your-repo/`
- Check `/demo/` and `/api/` work

---

## Step 10: Update Version Badge (Optional)

Add a Maven Central version badge to your README:

```markdown
[![Maven Central](https://img.shields.io/maven-central/v/io.github.yourname/yourlibname.svg)](https://central.sonatype.com/artifact/io.github.yourname/yourlibname)
```

---

## 🎉 You're Done!

Your library is now:
- ✅ Published on Maven Central
- ✅ Documented with API docs
- ✅ Demo-able via wasm
- ✅ Downloadable as sample apps
- ✅ Fully automated CI/CD

---

## 🔄 For Future Releases

1. Make changes to library code
2. Update version in `lib/build.gradle.kts`
3. Commit and push
4. Create and push new tag: `git tag v0.2.0 && git push origin v0.2.0`
5. Watch the automation work!

---

## 📚 Additional Resources

- [Kotlin Multiplatform Docs](https://kotlinlang.org/docs/multiplatform.html)
- [Compose Multiplatform Docs](https://www.jetbrains.com/compose-multiplatform/)
- [Publishing to Maven Central](https://central.sonatype.org/publish/publish-guide/)
- [GitHub Actions Docs](https://docs.github.com/en/actions)

---

## ❓ Need Help?

- Check CONTRIBUTING.md for development guidelines
- Open an issue if you encounter problems
- Review existing issues for common problems

