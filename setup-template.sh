#!/bin/bash

# Compose Multiplatform Library Template Setup Script
# This script configures the template with your library's information

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration file
CONFIG_FILE=".template-config.json"

echo -e "${BLUE}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Compose Multiplatform Library Template Setup            ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if already configured
if [ -f "$CONFIG_FILE" ]; then
  echo -e "${YELLOW}⚠️  Template already configured!${NC}"
  echo ""
  echo "Current configuration:"
  cat "$CONFIG_FILE"
  echo ""
  read -p "Do you want to reconfigure? (y/n): " RECONFIGURE
  if [ "$RECONFIGURE" != "y" ] && [ "$RECONFIGURE" != "Y" ]; then
    echo -e "${GREEN}Setup cancelled. No changes made.${NC}"
    exit 0
  fi
  echo ""
fi

# Get current git remote URL to auto-detect repository name and org
GIT_REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
if [[ $GIT_REMOTE =~ github.com[:/]([^/]+)/([^/.]+) ]]; then
  DETECTED_ORG="${BASH_REMATCH[1]}"
  DETECTED_REPO="${BASH_REMATCH[2]}"
else
  DETECTED_ORG=""
  DETECTED_REPO=""
fi

# Validate that we have detected a repository
if [ -z "$DETECTED_REPO" ]; then
  echo -e "${RED}Error: Could not detect repository name from git remote!${NC}"
  echo "Please make sure you've created this repository from the template and have a git remote configured."
  exit 1
fi

# Use detected repository name (no user input)
REPO_NAME="$DETECTED_REPO"

# Prompt for configuration values
echo -e "${GREEN}Please provide your library configuration:${NC}"
echo ""
echo -e "${BLUE}Repository detected:${NC} ${YELLOW}${REPO_NAME}${NC}"
echo ""

# Library name (human-readable, for POM)
read -p "Library name [e.g., Media Viewer Library]: " LIBRARY_NAME
while [ -z "$LIBRARY_NAME" ]; do
  echo -e "${RED}Library name cannot be empty!${NC}"
  read -p "Library name: " LIBRARY_NAME
done

# Artifact name (default: repo name)
read -p "Maven artifact name [${REPO_NAME}]: " ARTIFACT_NAME
ARTIFACT_NAME=${ARTIFACT_NAME:-$REPO_NAME}

# GitHub org/username
if [ -n "$DETECTED_ORG" ]; then
  read -p "GitHub username/organization [${DETECTED_ORG}]: " GITHUB_ORG
  GITHUB_ORG=${GITHUB_ORG:-$DETECTED_ORG}
else
  read -p "GitHub username/organization: " GITHUB_ORG
  while [ -z "$GITHUB_ORG" ]; do
    echo -e "${RED}GitHub org cannot be empty!${NC}"
    read -p "GitHub username/organization: " GITHUB_ORG
  done
fi

# Maven group ID
DEFAULT_GROUP_ID="io.github.${GITHUB_ORG}"
read -p "Maven group ID [${DEFAULT_GROUP_ID}]: " GROUP_ID
GROUP_ID=${GROUP_ID:-$DEFAULT_GROUP_ID}

# Developer name
read -p "Developer name (for POM): " DEVELOPER_NAME
while [ -z "$DEVELOPER_NAME" ]; do
  echo -e "${RED}Developer name cannot be empty!${NC}"
  read -p "Developer name: " DEVELOPER_NAME
done

# Library description
read -p "Library description (for POM): " LIBRARY_DESCRIPTION
while [ -z "$LIBRARY_DESCRIPTION" ]; do
  echo -e "${RED}Library description cannot be empty!${NC}"
  read -p "Library description: " LIBRARY_DESCRIPTION
done

# Version
DEFAULT_VERSION="0.0.1"
read -p "Initial version [${DEFAULT_VERSION}]: " VERSION
VERSION=${VERSION:-$DEFAULT_VERSION}

# Ask to keep example code
echo ""
echo -e "${GREEN}Would you like to keep the 'fiblib' Fibonacci example code and tests for reference?${NC}"
echo "  y - Keep example code & tests (migrates them to your new package namespace)"
echo "  n - Delete example code & tests completely (recommended for a clean setup)"
read -p "Keep example code? (y/n) [y]: " KEEP_EXAMPLE
KEEP_EXAMPLE=${KEEP_EXAMPLE:-y}

if [ "$KEEP_EXAMPLE" = "n" ] || [ "$KEEP_EXAMPLE" = "N" ]; then
  KEEP_EXAMPLE_BOOL=false
else
  KEEP_EXAMPLE_BOOL=true
fi

# Generate package name (remove hyphens and special chars, lowercase)
PACKAGE_NAME=$(echo "$ARTIFACT_NAME" | tr -d '-' | tr '[:upper:]' '[:lower:]')
PACKAGE_PATH=$(echo "$GROUP_ID" | tr '.' '/')/$PACKAGE_NAME

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Configuration Summary:${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo "Library name:         $LIBRARY_NAME"
echo "Artifact name:        $ARTIFACT_NAME"
echo "Version:              $VERSION"
echo "GitHub org:           $GITHUB_ORG"
echo "Maven group ID:       $GROUP_ID"
echo "Developer name:       $DEVELOPER_NAME"
echo "Library description:  $LIBRARY_DESCRIPTION"
echo "Keep example code:    $KEEP_EXAMPLE"
echo "Package name:         $GROUP_ID.$PACKAGE_NAME"
echo "Package path:         $PACKAGE_PATH"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

read -p "Proceed with this configuration? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
  echo -e "${RED}Setup cancelled.${NC}"
  exit 1
fi

echo ""
echo -e "${GREEN}🚀 Starting template configuration...${NC}"
echo ""

# Save configuration
cat > "$CONFIG_FILE" << EOF
{
  "configured": true,
  "repo_name": "$REPO_NAME",
  "library_name": "$LIBRARY_NAME",
  "artifact_name": "$ARTIFACT_NAME",
  "github_org": "$GITHUB_ORG",
  "group_id": "$GROUP_ID",
  "developer_name": "$DEVELOPER_NAME",
  "library_description": "$LIBRARY_DESCRIPTION",
  "package_name": "$GROUP_ID.$PACKAGE_NAME",
  "package_path": "$PACKAGE_PATH",
  "version": "$VERSION",
  "keep_example": $KEEP_EXAMPLE_BOOL
}
EOF

echo -e "${GREEN}✓${NC} Configuration saved to $CONFIG_FILE"

# Backup old values for replacement
OLD_REPO="cmp-lib-template"
OLD_ORG="aryapreetam"
OLD_ARTIFACT="fiblib"
OLD_GROUP="io.github.aryapreetam"
OLD_NAMESPACE="io.github.aryapreetam.fiblib"
OLD_DEVELOPER="Preetam Bhosle"
OLD_DESCRIPTION="Compose Multiplatform library for fibonacci numbers"
OLD_LIB_NAME="Fibonacci Library"
OLD_VERSION="0.0.3"

# Replace in settings.gradle.kts
echo -e "${GREEN}✓${NC} Updating settings.gradle.kts..."
sed -i.bak "s/rootProject.name = \"$OLD_REPO\"/rootProject.name = \"$REPO_NAME-root\"/" settings.gradle.kts
sed -i.bak "s/include(\":library-module\")/include(\":$ARTIFACT_NAME\")/" settings.gradle.kts
rm -f settings.gradle.kts.bak

# Replace in gradle.properties
echo -e "${GREEN}✓${NC} Updating gradle.properties..."
sed -i.bak "s|libGroup=io.github.aryapreetam|libGroup=$GROUP_ID|" gradle.properties
sed -i.bak "s|libArtifactId=fiblib|libArtifactId=$ARTIFACT_NAME|" gradle.properties
sed -i.bak "s|libVersion=0.0.4|libVersion=$VERSION|" gradle.properties
rm -f gradle.properties.bak

# Replace in library-module/build.gradle.kts
echo -e "${GREEN}✓${NC} Updating library build file..."
sed -i.bak "s|namespace = \"$OLD_NAMESPACE\"|namespace = \"$GROUP_ID.$PACKAGE_NAME\"|" library-module/build.gradle.kts
sed -i.bak "s|name = \"$OLD_LIB_NAME\"|name = \"$LIBRARY_NAME\"|" library-module/build.gradle.kts
sed -i.bak "s|description = \"$OLD_DESCRIPTION\"|description = \"$LIBRARY_DESCRIPTION\"|" library-module/build.gradle.kts
sed -i.bak "s|url = \"https://$OLD_ORG.github.io/$OLD_REPO\"|url = \"https://$GITHUB_ORG.github.io/$REPO_NAME\"|" library-module/build.gradle.kts
sed -i.bak "s|id = \"$OLD_ORG\"|id = \"$GITHUB_ORG\"|" library-module/build.gradle.kts
sed -i.bak "s|name = \"$OLD_DEVELOPER\"|name = \"$DEVELOPER_NAME\"|" library-module/build.gradle.kts
sed -i.bak "s|url = \"https://github.com/$OLD_ORG/$OLD_REPO\"|url = \"https://github.com/$GITHUB_ORG/$REPO_NAME\"|" library-module/build.gradle.kts
rm -f library-module/build.gradle.kts.bak

# Replace in sample/composeApp/build.gradle.kts
echo -e "${GREEN}✓${NC} Updating sample app build file..."
sed -i.bak "s|implementation(project(\":library-module\"))|implementation(project(\":$ARTIFACT_NAME\"))|" sample/composeApp/build.gradle.kts
rm -f sample/composeApp/build.gradle.kts.bak

# Physically rename directory library-module to $ARTIFACT_NAME
echo -e "${GREEN}✓${NC} Renaming library module directory to $ARTIFACT_NAME..."
mv library-module "$ARTIFACT_NAME"

# Replace in CONTRIBUTING.md
echo -e "${GREEN}✓${NC} Updating CONTRIBUTING.md..."
sed -i.bak "s|$OLD_REPO|$REPO_NAME|g" CONTRIBUTING.md
sed -i.bak "s|$OLD_ORG|$GITHUB_ORG|g" CONTRIBUTING.md
sed -i.bak "s|$OLD_GROUP|$GROUP_ID|g" CONTRIBUTING.md
sed -i.bak "s|$OLD_ARTIFACT|$ARTIFACT_NAME|g" CONTRIBUTING.md
rm -f CONTRIBUTING.md.bak

# Replace in README.MD
echo -e "${GREEN}✓${NC} Updating README.MD..."
sed -i.bak "s|$OLD_REPO|$REPO_NAME|g" README.MD
sed -i.bak "s|$OLD_ORG|$GITHUB_ORG|g" README.MD
sed -i.bak "s|$OLD_ARTIFACT|$ARTIFACT_NAME|g" README.MD
sed -i.bak "s|$OLD_GROUP|$GROUP_ID|g" README.MD

# Remove the template setup warning section from README.MD
echo -e "${GREEN}✓${NC} Removing template setup warning from README.MD..."
sed -i.bak '/<!-- ⚠️ TEMPLATE SETUP WARNING/,/<!-- END TEMPLATE SETUP WARNING -->/d' README.MD

# Remove template acknowledgments section from README.MD
echo -e "${GREEN}✓${NC} Removing template acknowledgments from README.MD..."
sed -i.bak '/<!-- TEMPLATE ACKNOWLEDGMENTS -->/,/<!-- END TEMPLATE ACKNOWLEDGMENTS -->/d' README.MD

rm -f README.MD.bak

# Replace in LICENSE
echo -e "${GREEN}✓${NC} Updating LICENSE..."
sed -i.bak "s|Copyright (c) 2025 $OLD_ORG|Copyright (c) 2025 $GITHUB_ORG|g" LICENSE
rm -f LICENSE.bak

# Replace in .github/workflows/release.yml
echo -e "${GREEN}✓${NC} Updating .github/workflows/release.yml..."
sed -i.bak "s|name: '$OLD_REPO'|name: '$REPO_NAME'|g" .github/workflows/release.yml
sed -i.bak "s|repo: 'https://github.com/$OLD_ORG/$OLD_REPO'|repo: 'https://github.com/$GITHUB_ORG/$REPO_NAME'|g" .github/workflows/release.yml
sed -i.bak "s|<title>Compose Multiplatform Library Template</title>|<title>$REPO_NAME</title>|g" .github/workflows/release.yml
sed -i.bak "s|:library-module:|:$ARTIFACT_NAME:|g" .github/workflows/release.yml
sed -i.bak "s|library-module/build/dokka|$ARTIFACT_NAME/build/dokka|g" .github/workflows/release.yml
sed -i.bak "s|library-module/build/|$ARTIFACT_NAME/build/|g" .github/workflows/release.yml
rm -f .github/workflows/release.yml.bak

# Update push-ci.yml to remove skipped jobs and clean up triggers
echo -e "${GREEN}✓${NC} Optimizing and customizing .github/workflows/push-ci.yml..."
cat > .github/workflows/push-ci.yml << EOF
name: CI (push & PR)

on:
  push:
    branches:
      - '**'
    tags-ignore:
      - 'v*'
    paths:
      # Run CI only when these files/directories change
      - '$ARTIFACT_NAME/**'
      - 'sample/**'
      - 'gradle/**'
      - 'gradle.properties'
      - 'settings.gradle.kts'
      - 'build.gradle.kts'
      - '.github/workflows/ci.yml'
      - '.github/workflows/push-ci.yml'
  pull_request:
    paths:
      # Same path filters for PRs
      - '$ARTIFACT_NAME/**'
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
  group: ci-\${{ github.ref }}
  cancel-in-progress: true

jobs:
  ci:
    name: Reuse CI (lint, build+tests, android UI)
    uses: ./.github/workflows/ci.yml
EOF

# Update ci.yml to point to the renamed module
echo -e "${GREEN}✓${NC} Optimizing .github/workflows/ci.yml..."
sed -i.bak "s|:library-module:|:$ARTIFACT_NAME:|g" .github/workflows/ci.yml
rm -f .github/workflows/ci.yml.bak

# Create new package directory structure and migrate files
echo -e "${GREEN}✓${NC} Migrating package structure..."

# 1. Migrate core library package
NEW_LIB_PATH="$ARTIFACT_NAME/src/commonMain/kotlin/$PACKAGE_PATH"
NEW_LIB_TEST_PATH="$ARTIFACT_NAME/src/commonTest/kotlin/$PACKAGE_PATH"
mkdir -p "$NEW_LIB_PATH"
mkdir -p "$NEW_LIB_TEST_PATH"

if [ "$KEEP_EXAMPLE_BOOL" = "false" ]; then
  echo -e "${GREEN}✓${NC} Removing Fibonacci examples and setting up clean standalone sample app..."
  
  # Overwrite App.kt
  cat > "sample/composeApp/src/commonMain/kotlin/sample/app/App.kt" << 'EOF'
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
        text = "Welcome to your new Compose Multiplatform Library!",
        style = TextStyle(
          fontSize = 20.sp,
          fontWeight = FontWeight.Bold,
          color = Color.Black
        )
      )
      BasicText(
        text = "Edit App.kt to build a sample application for your library.",
        style = TextStyle(
          fontSize = 14.sp,
          color = Color.Gray
        )
      )
    }
  }
}
EOF

  # Overwrite SampleUiTest.kt
  cat > "sample/composeApp/src/commonTest/kotlin/sample/app/SampleUiTest.kt" << 'EOF'
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
    onNodeWithText("Welcome to your new Compose Multiplatform Library!").assertExists()
  }
}
EOF

  cat > "sample/composeApp/src/commonTest/kotlin/sample/app/SampleIntegrationTest.kt" << 'EOF'
package sample.app

import io.github.aryapreetam.parikshan.E2ETestLifecycle
import io.github.aryapreetam.parikshan.e2eTest
import kotlin.test.Test

class SampleIntegrationTest : E2ETestLifecycle {

  @Test
  fun sampleIntegrationTest() = e2eTest {
    assertVisible("Welcome to your new Compose Multiplatform Library!")
  }
}
EOF

  # Delete fiblib example folders completely
  rm -rf "$ARTIFACT_NAME/src/commonMain/kotlin/fiblib"
  rm -rf "$ARTIFACT_NAME/src/commonTest/kotlin/fiblib"
else
  if [ -d "$ARTIFACT_NAME/src/commonMain/kotlin/fiblib" ]; then
    mv $ARTIFACT_NAME/src/commonMain/kotlin/fiblib/* "$NEW_LIB_PATH/" 2>/dev/null || true
    rm -rf $ARTIFACT_NAME/src/commonMain/kotlin/fiblib
  fi
  if [ -d "$ARTIFACT_NAME/src/commonTest/kotlin/fiblib" ]; then
    mv $ARTIFACT_NAME/src/commonTest/kotlin/fiblib/* "$NEW_LIB_TEST_PATH/" 2>/dev/null || true
    rm -rf $ARTIFACT_NAME/src/commonTest/kotlin/fiblib
  fi
fi

# 2. Migrate composeApp package
SAMPLE_PACKAGE_PATH=$(echo "$GROUP_ID.$PACKAGE_NAME.sample" | tr '.' '/')
SAMPLE_SOURCE_SETS=("commonMain" "commonTest" "iosMain" "jvmMain" "wasmJsMain")

for source_set in "${SAMPLE_SOURCE_SETS[@]}"; do
  OLD_DIR="sample/composeApp/src/$source_set/kotlin/sample/app"
  NEW_DIR="sample/composeApp/src/$source_set/kotlin/$SAMPLE_PACKAGE_PATH"
  
  if [ -d "$OLD_DIR" ]; then
    mkdir -p "$NEW_DIR"
    mv "$OLD_DIR"/* "$NEW_DIR/" 2>/dev/null || true
    rm -rf "$OLD_DIR"
    # Clean up empty parent directories
    rmdir -p "sample/composeApp/src/$source_set/kotlin/sample" 2>/dev/null || true
  fi
done

# 3. Migrate androidApp package
ANDROID_PACKAGE_PATH=$(echo "$GROUP_ID.$PACKAGE_NAME.android" | tr '.' '/')
OLD_ANDROID_DIR="sample/androidApp/src/main/kotlin/sample/app/android"
NEW_ANDROID_DIR="sample/androidApp/src/main/kotlin/$ANDROID_PACKAGE_PATH"

if [ -d "$OLD_ANDROID_DIR" ]; then
  mkdir -p "$NEW_ANDROID_DIR"
  mv "$OLD_ANDROID_DIR"/* "$NEW_ANDROID_DIR/" 2>/dev/null || true
  rm -rf "$OLD_ANDROID_DIR"
  rmdir -p "sample/androidApp/src/main/kotlin/sample/app" 2>/dev/null || true
fi

# 4. Perform search-and-replace for package names and namespaces across all modules
echo -e "${GREEN}✓${NC} Performing search-and-replace for package names & namespaces..."

find "$ARTIFACT_NAME" sample -type f \( -name "*.kt" -o -name "*.gradle.kts" -o -name "*.xml" \) 2>/dev/null | while read -r file; do
  # Replace lib package
  sed -i.bak "s/package fiblib/package $GROUP_ID.$PACKAGE_NAME/g" "$file" 2>/dev/null || true
  sed -i.bak "s/import fiblib\./import $GROUP_ID.$PACKAGE_NAME./g" "$file" 2>/dev/null || true
  
  # Replace composeApp package
  sed -i.bak "s/package sample.app/package $GROUP_ID.$PACKAGE_NAME.sample/g" "$file" 2>/dev/null || true
  sed -i.bak "s/import sample.app\./import $GROUP_ID.$PACKAGE_NAME.sample./g" "$file" 2>/dev/null || true
  
  # Replace androidApp package
  sed -i.bak "s/package sample.app.android/package $GROUP_ID.$PACKAGE_NAME.android/g" "$file" 2>/dev/null || true
  sed -i.bak "s/import sample.app.android\./import $GROUP_ID.$PACKAGE_NAME.android./g" "$file" 2>/dev/null || true
  
  # Replace namespaces in build.gradle.kts files
  sed -i.bak "s/namespace = \"sample.app\"/namespace = \"$GROUP_ID.$PACKAGE_NAME.sample\"/g" "$file" 2>/dev/null || true
  sed -i.bak "s/namespace = \"sample.app.android\"/namespace = \"$GROUP_ID.$PACKAGE_NAME.android\"/g" "$file" 2>/dev/null || true
  sed -i.bak "s/applicationId = \"sample.app\"/applicationId = \"$GROUP_ID.$PACKAGE_NAME.sample\"/g" "$file" 2>/dev/null || true
  
  rm -f "${file}.bak"
done

# 5. Update Binary Compatibility Validator baseline
echo -e "${GREEN}✓${NC} Updating BCV baseline..."
if [ -f "$ARTIFACT_NAME/api/jvm/library-module.api" ]; then
  mv "$ARTIFACT_NAME/api/jvm/library-module.api" "$ARTIFACT_NAME/api/jvm/$ARTIFACT_NAME.api"
fi
rm -rf maestro-e2e 2>/dev/null || true

# 6. Global Search and Replace in README.MD and CONTRIBUTING.md for lib paths
sed -i.bak "s|:library-module:|:$ARTIFACT_NAME:|g" README.MD
sed -i.bak "s|:library-module:|:$ARTIFACT_NAME:|g" CONTRIBUTING.md
sed -i.bak "s|library-module/|$ARTIFACT_NAME/|g" README.MD
sed -i.bak "s|library-module/|$ARTIFACT_NAME/|g" CONTRIBUTING.md
rm -f README.MD.bak CONTRIBUTING.md.bak

# Create README in new package directory
cat > "$ARTIFACT_NAME/src/commonMain/kotlin/$PACKAGE_PATH/README.md" << EOF
# Your Library Code Goes Here

This is your library's main package: \`$GROUP_ID.$PACKAGE_NAME\`

## Getting Started

Add your library code in this directory.

## Package Structure

\`\`\`
$ARTIFACT_NAME/src/
├── commonMain/kotlin/
│   └── $PACKAGE_PATH/          # Your library code (THIS DIRECTORY)
└── commonTest/kotlin/
    └── $PACKAGE_PATH/          # Your tests
\`\`\`
EOF

echo -e "${GREEN}✓${NC} Migrated directories and updated namespaces successfully."

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                  ✅ Setup Complete!                       ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}What's next?${NC}"
echo ""
echo "1. Your new library package is ready at:"
echo -e "   ${YELLOW}$ARTIFACT_NAME/src/commonMain/kotlin/$PACKAGE_PATH/${NC}"
echo ""
echo "2. Your sample compose app package is ready at:"
echo -e "   ${YELLOW}sample/composeApp/src/commonMain/kotlin/$SAMPLE_PACKAGE_PATH/${NC}"
echo ""
echo "3. Your sample android app package is ready at:"
echo -e "   ${YELLOW}sample/androidApp/src/main/kotlin/$ANDROID_PACKAGE_PATH/${NC}"
echo ""
echo "4. Commit your changes:"
echo -e "   ${YELLOW}git add .${NC}"
echo -e "   ${YELLOW}git commit -m \"Configure template for $REPO_NAME\"${NC}"
echo ""
echo -e "${GREEN}Happy coding! 🎉${NC}"
echo ""
