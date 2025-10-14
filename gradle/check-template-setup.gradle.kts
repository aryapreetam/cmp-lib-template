// Check if template has been configured
// This task ensures users don't forget to run setup-template.sh

tasks.register("checkTemplateSetup") {
    doLast {
        val settingsFile = rootProject.file("settings.gradle.kts")
        val content = settingsFile.readText()

        // Extract rootProject.name from settings.gradle.kts
        val rootProjectNameRegex = """rootProject\.name\s*=\s*"([^"]+)"""".toRegex()
        val rootProjectName = rootProjectNameRegex.find(content)?.groupValues?.get(1) ?: ""

        // Get the actual project directory name (best approximation of repo name)
        val projectDirName = rootProject.projectDir.name

        logger.lifecycle("Project directory name: $projectDirName")
        logger.lifecycle("settings.gradle.kts rootProject.name: $rootProjectName")

        // Check if we're in the template repo itself
        val isTemplateRepo = projectDirName == "cmp-lib-template" && rootProjectName == "cmp-lib-template"

        // Check if repo was created from template but not configured
        val isUnconfigured = rootProjectName == "cmp-lib-template" && projectDirName != "cmp-lib-template"

        if (isTemplateRepo) {
            logger.lifecycle("✅ Running on template repository itself")
        } else if (isUnconfigured) {
            val errorMessage = """
                
                ╔════════════════════════════════════════════════════════════╗
                ║              ⚠️  TEMPLATE NOT CONFIGURED ⚠️               ║
                ╠════════════════════════════════════════════════════════════╣
                ║                                                            ║
                ║  This project was created from a template and needs to     ║
                ║  be configured with your library details.                  ║
                ║                                                            ║
                ║  Project directory: $projectDirName
                ║  settings.gradle.kts still shows: cmp-lib-template         ║
                ║                                                            ║
                ║  Please run:                                               ║
                ║                                                            ║
                ║      ./setup-template.sh       (Linux/Mac)                 ║
                ║      setup-template.bat        (Windows)                   ║
                ║                                                            ║
                ║  This will configure your library name, package            ║
                ║  structure, and Maven coordinates.                         ║
                ║                                                            ║
                ║  See: docs/using-this-template.md for details              ║
                ║                                                            ║
                ╚════════════════════════════════════════════════════════════╝
                
            """.trimIndent()

            logger.error(errorMessage)
            throw GradleException("Template not configured. Run setup-template.sh or setup-template.bat first.")
        } else {
            logger.lifecycle("✅ Template is configured")
        }
    }
}

// Run check before builds
tasks.matching {
    it.name in listOf("build", "assemble", "test", "publishToMavenLocal", "publishToMavenCentral")
}.configureEach {
    dependsOn("checkTemplateSetup")
}
