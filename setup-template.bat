@echo off
setlocal enabledelayedexpansion

REM Compose Multiplatform Library Template Setup Script (Windows)
REM This script configures the template with your library's information

echo ============================================================
echo    Compose Multiplatform Library Template Setup
echo ============================================================
echo.

REM Configuration file
set CONFIG_FILE=.template-config.json

REM Check if already configured
if exist "%CONFIG_FILE%" (
    echo [WARNING] Template already configured!
    echo.
    echo Current configuration:
    type "%CONFIG_FILE%"
    echo.
    set /p RECONFIGURE="Do you want to reconfigure? (y/n): "
    if /i not "!RECONFIGURE!"=="y" (
        echo Setup cancelled. No changes made.
        exit /b 0
    )
    echo.
)

REM Detect git remote URL for auto-detecting repository name and org
set DETECTED_ORG=
set DETECTED_REPO=
for /f "delims=" %%i in ('git remote get-url origin 2^>nul') do set GIT_REMOTE=%%i
if defined GIT_REMOTE (
    REM Extract org and repo from github.com URLs
    echo !GIT_REMOTE! | findstr /i "github.com" >nul
    if !errorlevel! equ 0 (
        REM Parse github.com/org/repo or github.com:org/repo
        for /f "tokens=4,5 delims=/:." %%a in ("!GIT_REMOTE!") do (
            set DETECTED_ORG=%%a
            set DETECTED_REPO=%%b
        )
    )
)

REM Validate that we have detected a repository
if not defined DETECTED_REPO (
    echo [ERROR] Could not detect repository name from git remote!
    echo Please make sure you've created this repository from the template and have a git remote configured.
    exit /b 1
)

REM Use detected repository name (no user input)
set REPO_NAME=!DETECTED_REPO!

echo Please provide your library configuration:
echo.
echo Repository detected: !REPO_NAME!
echo.

REM Library name (human-readable, for POM)
set /p LIBRARY_NAME="Library name [e.g., Media Viewer Library]: "
if "!LIBRARY_NAME!"=="" (
    echo [ERROR] Library name cannot be empty!
    exit /b 1
)

REM Artifact name (default: repo name)
set /p ARTIFACT_NAME="Maven artifact name [!REPO_NAME!]: "
if "!ARTIFACT_NAME!"=="" set ARTIFACT_NAME=!REPO_NAME!

REM GitHub org/username
if defined DETECTED_ORG (
    set /p GITHUB_ORG="GitHub username/organization [!DETECTED_ORG!]: "
    if "!GITHUB_ORG!"=="" set GITHUB_ORG=!DETECTED_ORG!
) else (
    set /p GITHUB_ORG="GitHub username/organization: "
    if "!GITHUB_ORG!"=="" (
        echo [ERROR] GitHub org cannot be empty!
        exit /b 1
    )
)

REM Maven group ID
set DEFAULT_GROUP_ID=io.github.!GITHUB_ORG!
set /p GROUP_ID="Maven group ID [!DEFAULT_GROUP_ID!]: "
if "!GROUP_ID!"=="" set GROUP_ID=!DEFAULT_GROUP_ID!

REM Developer name
set /p DEVELOPER_NAME="Developer name (for POM): "
if "!DEVELOPER_NAME!"=="" (
    echo [ERROR] Developer name cannot be empty!
    exit /b 1
)

REM Library description
set /p LIBRARY_DESCRIPTION="Library description (for POM): "
if "!LIBRARY_DESCRIPTION!"=="" (
    echo [ERROR] Library description cannot be empty!
    exit /b 1
)

REM Version
set DEFAULT_VERSION=0.0.1
set /p VERSION="Initial version [!DEFAULT_VERSION!]: "
if "!VERSION!"=="" set VERSION=!DEFAULT_VERSION!

REM Ask to keep example code
echo.
echo Would you like to keep the 'fiblib' Fibonacci example code and tests for reference?
echo   y - Keep example code ^& tests ^(migrates them to your new package namespace^)
echo   n - Delete example code ^& tests completely ^(recommended for a clean setup^)
set /p KEEP_EXAMPLE="Keep example code? (y/n) [y]: "
if "!KEEP_EXAMPLE!"=="" set KEEP_EXAMPLE=y

if /i "!KEEP_EXAMPLE!"=="n" (
    set KEEP_EXAMPLE_BOOL=false
) else (
    set KEEP_EXAMPLE_BOOL=true
)

REM Generate package name (remove hyphens and special chars, lowercase)
set PACKAGE_NAME=!ARTIFACT_NAME:-=!
REM Convert to lowercase
for %%a in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do (
    call set PACKAGE_NAME=%%PACKAGE_NAME:%%a=%%a%%
)
set PACKAGE_PATH=!GROUP_ID:.=/!/!PACKAGE_NAME!

echo.
echo ============================================================
echo Configuration Summary:
echo ============================================================
echo Library name:         !LIBRARY_NAME!
echo Artifact name:        !ARTIFACT_NAME!
echo Version:              !VERSION!
echo GitHub org:           !GITHUB_ORG!
echo Maven group ID:       !GROUP_ID!
echo Developer name:       !DEVELOPER_NAME!
echo Library description:  !LIBRARY_DESCRIPTION!
echo Keep example code:    !KEEP_EXAMPLE!
echo Package name:         !GROUP_ID!.!PACKAGE_NAME!
echo Package path:         !PACKAGE_PATH!
echo ============================================================
echo.

set /p CONFIRM="Proceed with this configuration? (y/n): "
if /i not "!CONFIRM!"=="y" (
    echo Setup cancelled.
    exit /b 1
)

echo.
echo Starting template configuration...
echo.

REM Save configuration to JSON
(
echo {
echo   "configured": true,
echo   "repo_name": "!REPO_NAME!",
echo   "library_name": "!LIBRARY_NAME!",
echo   "artifact_name": "!ARTIFACT_NAME!",
echo   "github_org": "!GITHUB_ORG!",
echo   "group_id": "!GROUP_ID!",
echo   "developer_name": "!DEVELOPER_NAME!",
echo   "library_description": "!LIBRARY_DESCRIPTION!",
echo   "package_name": "!GROUP_ID!.!PACKAGE_NAME!",
echo   "package_path": "!PACKAGE_PATH!",
echo   "version": "!VERSION!",
echo   "keep_example": !KEEP_EXAMPLE_BOOL!
echo }
) > "%CONFIG_FILE%"

echo [OK] Configuration saved to %CONFIG_FILE%

REM Backup old values for replacement
set OLD_REPO=cmp-lib-template
set OLD_ORG=aryapreetam
set OLD_ARTIFACT=fiblib
set OLD_GROUP=io.github.aryapreetam
set OLD_NAMESPACE=io.github.aryapreetam.fiblib
set OLD_DEVELOPER=Preetam Bhosle
set OLD_DESCRIPTION=Compose Multiplatform library for fibonacci numbers
set OLD_LIB_NAME=Fibonacci Library
set OLD_VERSION=0.0.3

REM Replace in settings.gradle.kts
echo [OK] Updating settings.gradle.kts...
powershell -Command "(Get-Content 'settings.gradle.kts') -replace 'rootProject.name = \"%OLD_REPO%\"', 'rootProject.name = \"!REPO_NAME!-root\"' -replace 'include\(\":library-module\"\)', 'include(\":!ARTIFACT_NAME!\")' | Set-Content 'settings.gradle.kts'"

REM Replace in gradle.properties
echo [OK] Updating gradle.properties...
powershell -Command "$content = Get-Content 'gradle.properties' -Raw; $content = $content -replace 'libGroup=io.github.aryapreetam', 'libGroup=!GROUP_ID!'; $content = $content -replace 'libArtifactId=fiblib', 'libArtifactId=!ARTIFACT_NAME!'; $content = $content -replace 'libVersion=0.0.4', 'libVersion=!VERSION!'; Set-Content 'gradle.properties' $content"

REM Replace in library-module/build.gradle.kts
echo [OK] Updating library build file...
powershell -Command "$content = Get-Content 'library-module/build.gradle.kts' -Raw; $content = $content -replace 'namespace = \"%OLD_NAMESPACE%\"', 'namespace = \"!GROUP_ID!.!PACKAGE_NAME!\"'; $content = $content -replace 'name = \"%OLD_LIB_NAME%\"', 'name = \"!LIBRARY_NAME!\"'; $content = $content -replace 'description = \"%OLD_DESCRIPTION%\"', 'description = \"!LIBRARY_DESCRIPTION!\"'; $content = $content -replace 'url = \"https://%OLD_ORG%.github.io/%OLD_REPO%\"', 'url = \"https://!GITHUB_ORG!.github.io/!REPO_NAME!\"'; $content = $content -replace 'id = \"%OLD_ORG%\"', 'id = \"!GITHUB_ORG!\"'; $content = $content -replace 'name = \"%OLD_DEVELOPER%\"', 'name = \"!DEVELOPER_NAME!\"'; $content = $content -replace 'url = \"https://github.com/%OLD_ORG%/%OLD_REPO%\"', 'url = \"https://github.com/!GITHUB_ORG!/!REPO_NAME!\"'; Set-Content 'library-module/build.gradle.kts' $content"

REM Replace in sample/composeApp/build.gradle.kts
echo [OK] Updating sample app build file...
powershell -Command "(Get-Content 'sample/composeApp/build.gradle.kts') -replace 'implementation\(project\(\":library-module\"\)\)', 'implementation(project(\":!ARTIFACT_NAME!\"))' | Set-Content 'sample/composeApp/build.gradle.kts'"

REM Physically rename directory library-module to !ARTIFACT_NAME!
echo [OK] Renaming library module directory to !ARTIFACT_NAME!...
move library-module "!ARTIFACT_NAME!"

REM Replace in CONTRIBUTING.md
echo [OK] Updating CONTRIBUTING.md...
powershell -Command "(Get-Content 'CONTRIBUTING.md') -replace '%OLD_REPO%', '!REPO_NAME!' -replace '%OLD_ORG%', '!GITHUB_ORG!' -replace '%OLD_GROUP%', '!GROUP_ID!' -replace '%OLD_ARTIFACT%', '!ARTIFACT_NAME!' | Set-Content 'CONTRIBUTING.md'"

REM Replace in README.MD
echo [OK] Updating README.MD...
powershell -Command "(Get-Content 'README.MD') -replace '%OLD_REPO%', '!REPO_NAME!' -replace '%OLD_ORG%', '!GITHUB_ORG!' -replace '%OLD_ARTIFACT%', '!ARTIFACT_NAME!' -replace '%OLD_GROUP%', '!GROUP_ID!' | Set-Content 'README.MD'"

REM Remove the template setup warning section from README.MD
echo [OK] Removing template setup warning from README.MD...
powershell -Command "$content = Get-Content 'README.MD' -Raw; $content = $content -replace '(?s)<!-- ⚠️ TEMPLATE SETUP WARNING.*?<!-- END TEMPLATE SETUP WARNING -->', ''; Set-Content 'README.MD' $content"

REM Replace in LICENSE
echo [OK] Updating LICENSE...
powershell -Command "(Get-Content 'LICENSE') -replace 'Copyright \(c\) 2025 %OLD_ORG%', 'Copyright (c) 2025 !GITHUB_ORG!' | Set-Content 'LICENSE'"

REM Replace in .github/workflows/release.yml
echo [OK] Updating .github/workflows/release.yml...
powershell -Command "(Get-Content '.github/workflows/release.yml') -replace 'name: ''%OLD_REPO%''', 'name: ''!REPO_NAME!''' -replace 'repo: ''https://github.com/%OLD_ORG%/%OLD_REPO%''', 'repo: ''https://github.com/!GITHUB_ORG!/!REPO_NAME!''' -replace '<title>Compose Multiplatform Library Template</title>', '<title>!REPO_NAME!</title>' -replace ':library-module:', ':!ARTIFACT_NAME!:' -replace 'library-module/build/dokka', '!ARTIFACT_NAME!/build/dokka' -replace 'library-module/build/', '!ARTIFACT_NAME!/build/' | Set-Content '.github/workflows/release.yml'"

REM Overwrite and optimize push-ci.yml
echo [OK] Customizing and optimizing .github/workflows/push-ci.yml...
powershell -Command "Set-Content '.github/workflows/push-ci.yml' @'
name: CI (push & PR)

on:
  push:
    branches:
      - '**'
    tags-ignore:
      - 'v*'
    paths:
      - '!ARTIFACT_NAME!/**'
      - 'sample/**'
      - 'gradle/**'
      - 'gradle.properties'
      - 'settings.gradle.kts'
      - 'build.gradle.kts'
      - '.github/workflows/ci.yml'
      - '.github/workflows/push-ci.yml'
  pull_request:
    paths:
      - '!ARTIFACT_NAME!/**'
      - 'sample/**'
      - 'gradle/**'
      - 'gradle.properties'
      - 'settings.gradle.kts'
      - 'build.gradle.kts'
      - '.github/workflows/ci.yml'
      - '.github/workflows/push-ci.yml'

permissions:
  contents: read

concurrency:
  group: ci-`$`{` github.ref `}
  cancel-in-progress: true

jobs:
  ci:
    name: Reuse CI (lint, build+tests, android UI)
    uses: ./.github/workflows/ci.yml
'@ -Encoding utf8"

REM Fix formatting on push-ci variables block
powershell -Command "$content = Get-Content '.github/workflows/push-ci.yml' -Raw; $content = $content -replace 'ci-`\$`\{` github\.ref `\}', 'ci-\${{ github.ref }}'; Set-Content '.github/workflows/push-ci.yml' $content"

REM Update ci.yml to point to the renamed module and E2E test file
echo [OK] Optimizing .github/workflows/ci.yml...
powershell -Command "(Get-Content '.github/workflows/ci.yml') -replace ':library-module:', ':!ARTIFACT_NAME!:' -replace 'fib-test.yaml', '!ARTIFACT_NAME!-test.yaml' | Set-Content '.github/workflows/ci.yml'"

REM Migrate package structures and search-and-replace namespaces across all modules
echo Migrating package structure...

if "!KEEP_EXAMPLE_BOOL!"=="false" (
    echo [OK] Removing Fibonacci examples and setting up clean standalone sample app...
    powershell -Command "Set-Content 'sample/composeApp/src/commonMain/kotlin/sample/app/App.kt' @'
package sample.app

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.BasicText
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

@Composable
fun App() {
  Box(
    modifier = Modifier.fillMaxSize().background(Color.White),
    contentAlignment = Alignment.Center
  ) {
    Column(
      horizontalAlignment = Alignment.CenterHorizontally,
      verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
      BasicText(
        text = \"Welcome to your new Compose Multiplatform Library!\",
        style = TextStyle(
          fontSize = 20.sp,
          fontWeight = FontWeight.Bold,
          color = Color.Black
        )
      )
      BasicText(
        text = \"Edit App.kt to build a sample application for your library.\",
        style = TextStyle(
          fontSize = 14.sp,
          color = Color.Gray
        )
      )
    }
  }
}
'@ -Encoding utf8"

    powershell -Command "Set-Content 'sample/composeApp/src/commonTest/kotlin/sample/app/SampleUiTest.kt' @'
package sample.app

import androidx.compose.ui.test.ExperimentalTestApi
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.runComposeUiTest
import kotlin.test.Test

class SampleUITest {

  @OptIn(ExperimentalTestApi::class)
  @Test
  fun sampleUiTest() = runComposeUiTest {
    setContent { App() }
    onNodeWithText(\"Welcome to your new Compose Multiplatform Library!\").assertExists()
  }
}
'@ -Encoding utf8"

    powershell -Command "Set-Content 'sample/composeApp/src/commonTest/kotlin/sample/app/SampleIntegrationTest.kt' @'
package sample.app

import io.github.aryapreetam.parikshan.E2ETestLifecycle
import io.github.aryapreetam.parikshan.e2eTest
import kotlin.test.Test

class SampleIntegrationTest : E2ETestLifecycle {

  @Test
  fun sampleIntegrationTest() = e2eTest {
    assertVisible(\"Welcome to your new Compose Multiplatform Library!\")
  }
}
'@ -Encoding utf8"
)

powershell -Command ^
    "$packagePath = '!PACKAGE_PATH!';" ^
    "$samplePackagePath = '!GROUP_ID!.!PACKAGE_NAME!.sample'.Replace('.', '/');" ^
    "$androidPackagePath = '!GROUP_ID!.!PACKAGE_NAME!.android'.Replace('.', '/');" ^
    "if (Test-Path '!ARTIFACT_NAME!/src/commonMain/kotlin/fiblib') {" ^
    "  New-Item -ItemType Directory -Force -Path \"!ARTIFACT_NAME!/src/commonMain/kotlin/$packagePath\" | Out-Null;" ^
    "  if ('!KEEP_EXAMPLE_BOOL!' -eq 'true') {" ^
    "    Move-Item -Path '!ARTIFACT_NAME!/src/commonMain/kotlin/fiblib/*' -Destination \"!ARTIFACT_NAME!/src/commonMain/kotlin/$packagePath\" -ErrorAction SilentlyContinue;" ^
    "  }" ^
    "  Remove-Item -Recurse -Force '!ARTIFACT_NAME!/src/commonMain/kotlin/fiblib';" ^
    "}" ^
    "if (Test-Path '!ARTIFACT_NAME!/src/commonTest/kotlin/fiblib') {" ^
    "  New-Item -ItemType Directory -Force -Path \"!ARTIFACT_NAME!/src/commonTest/kotlin/$packagePath\" | Out-Null;" ^
    "  if ('!KEEP_EXAMPLE_BOOL!' -eq 'true') {" ^
    "    Move-Item -Path '!ARTIFACT_NAME!/src/commonTest/kotlin/fiblib/*' -Destination \"!ARTIFACT_NAME!/src/commonTest/kotlin/$packagePath\" -ErrorAction SilentlyContinue;" ^
    "  }" ^
    "  Remove-Item -Recurse -Force '!ARTIFACT_NAME!/src/commonTest/kotlin/fiblib';" ^
    "}" ^
    "$sources = @('commonMain', 'commonTest', 'iosMain', 'jvmMain', 'wasmJsMain');" ^
    "foreach ($src in $sources) {" ^
    "  $oldDir = \"sample/composeApp/src/$src/kotlin/sample/app\";" ^
    "  $newDir = \"sample/composeApp/src/$src/kotlin/$samplePackagePath\";" ^
    "  if (Test-Path $oldDir) {" ^
    "    New-Item -ItemType Directory -Force -Path $newDir | Out-Null;" ^
    "    Move-Item -Path \"$oldDir/*\" -Destination $newDir -ErrorAction SilentlyContinue;" ^
    "    Remove-Item -Recurse -Force $oldDir;" ^
    "    # Remove empty parent directories" ^
    "    $parent = Split-Path $oldDir -Parent;" ^
    "    while ($parent -and $parent -ne 'sample/composeApp/src' -and $parent -ne 'sample/composeApp' -and (Test-Path $parent) -and (Get-ChildItem $parent).Count -eq 0) {" ^
    "      Remove-Item $parent -Force;" ^
    "      $parent = Split-Path $parent -Parent;" ^
    "    }" ^
    "  }" ^
    "}" ^
    "$oldAndroidDir = 'sample/androidApp/src/main/kotlin/sample/app/android';" ^
    "$newAndroidDir = \"sample/androidApp/src/main/kotlin/$androidPackagePath\";" ^
    "if (Test-Path $oldAndroidDir) {" ^
    "  New-Item -ItemType Directory -Force -Path $newAndroidDir | Out-Null;" ^
    "  Move-Item -Path \"$oldAndroidDir/*\" -Destination $newAndroidDir -ErrorAction SilentlyContinue;" ^
    "  Remove-Item -Recurse -Force $oldAndroidDir;" ^
    "  $parent = Split-Path $oldAndroidDir -Parent;" ^
    "  while ($parent -and $parent -ne 'sample/androidApp/src' -and $parent -ne 'sample/androidApp' -and (Test-Path $parent) -and (Get-ChildItem $parent).Count -eq 0) {" ^
    "    Remove-Item $parent -Force;" ^
    "    $parent = Split-Path $parent -Parent;" ^
    "  }" ^
    "}"

echo Performing search-and-replace for package names & namespaces...
powershell -Command ^
    "Get-ChildItem -Path !ARTIFACT_NAME!, sample -Recurse -Include *.kt, *.gradle.kts, *.xml | ForEach-Object {" ^
    "  $content = Get-Content $_.FullName -Raw;" ^
    "  $content = $content -replace 'package fiblib', 'package !GROUP_ID!.!PACKAGE_NAME!';" ^
    "  $content = $content -replace 'import fiblib\.', 'import !GROUP_ID!.!PACKAGE_NAME!.';" ^
    "  $content = $content -replace 'package sample\.app', 'package !GROUP_ID!.!PACKAGE_NAME!.sample';" ^
    "  $content = $content -replace 'import sample\.app\.', 'import !GROUP_ID!.!PACKAGE_NAME!.sample\..';" ^
    "  $content = $content -replace 'package sample\.app\.android', 'package !GROUP_ID!.!PACKAGE_NAME!.android';" ^
    "  $content = $content -replace 'import sample\.app\.android\.', 'import !GROUP_ID!.!PACKAGE_NAME!.android\..';" ^
    "  $content = $content -replace 'namespace = \"sample\.app\"', 'namespace = \"!GROUP_ID!.!PACKAGE_NAME!.sample\"';" ^
    "  $content = $content -replace 'namespace = \"sample\.app\.android\"', 'namespace = \"!GROUP_ID!.!PACKAGE_NAME!.android\"';" ^
    "  $content = $content -replace 'applicationId = \"sample\.app\"', 'applicationId = \"!GROUP_ID!.!PACKAGE_NAME!.sample\"';" ^
    "  Set-Content $_.FullName $content;" ^
    "}"

REM Update BCV baseline
echo [OK] Updating BCV baseline...
if exist "!ARTIFACT_NAME!\api\jvm\library-module.api" (
  move "!ARTIFACT_NAME!\api\jvm\library-module.api" "!ARTIFACT_NAME!\api\jvm\!ARTIFACT_NAME!.api"
)
if exist "maestro-e2e" rmdir /s /q "maestro-e2e"

REM Global search-and-replace in MD files
powershell -Command "(Get-Content 'README.MD') -replace ':library-module:', ':!ARTIFACT_NAME!:' -replace 'library-module/', '!ARTIFACT_NAME!/' | Set-Content 'README.MD'"
powershell -Command "(Get-Content 'CONTRIBUTING.md') -replace ':library-module:', ':!ARTIFACT_NAME!:' -replace 'library-module/', '!ARTIFACT_NAME!/' | Set-Content 'CONTRIBUTING.md'"

REM Create README in new package directory
(
echo # Your Library Code Goes Here
echo.
echo This is your library's main package: `!GROUP_ID!.!PACKAGE_NAME!`
echo.
echo ## Getting Started
echo.
echo Add your library code in this directory.
echo.
echo ## Package Structure
echo.
echo ```
echo !ARTIFACT_NAME!/src/
echo ├── commonMain/kotlin/
echo │   └── !PACKAGE_PATH!/          # Your library code ^(THIS DIRECTORY^)
echo └── commonTest/kotlin/
echo     └── !PACKAGE_PATH!/          # Your tests
echo ```
) > "!ARTIFACT_NAME!\src\commonMain\kotlin\!PACKAGE_PATH!\README.md"

echo [OK] Created package structure with README

echo.
echo ============================================================
echo                  Setup Complete!
echo ============================================================
echo.
echo What's next?
echo.
echo 1. Your new library package is ready at:
echo    !ARTIFACT_NAME!/src/commonMain/kotlin/!PACKAGE_PATH!/
echo.
echo 2. Your sample compose app package is ready at:
echo    sample/composeApp/src/commonMain/kotlin/!GROUP_ID!.!PACKAGE_NAME!.sample (slash separated)
echo.
echo 3. Your sample android app package is ready at:
echo    sample/androidApp/src/main/kotlin/!GROUP_ID!.!PACKAGE_NAME!.android (slash separated)
echo.
echo 4. Commit your changes:
echo    git add .
echo    git commit -m "Configure template for !REPO_NAME!"
echo.
echo Happy coding!
echo.

endlocal
