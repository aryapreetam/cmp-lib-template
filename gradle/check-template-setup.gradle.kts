// Check if template has been configured
// This task ensures users don't forget to run setup-template.sh

abstract class CheckTemplateSetupTask : DefaultTask() {
    @get:InputFile
    @get:PathSensitive(PathSensitivity.RELATIVE)
    abstract val settingsFile: RegularFileProperty

    @get:Input
    abstract val projectDirName: Property<String>

    init {
        // Don't cache this task as it's a quick validation check
        outputs.upToDateWhen { false }
    }

    @TaskAction
    fun check() {
        val content = settingsFile.get().asFile.readText()

        // Extract rootProject.name from settings.gradle.kts
        val rootProjectNameRegex = """rootProject\.name\s*=\s*"([^"]+)"""".toRegex()
        val rootProjectName = rootProjectNameRegex.find(content)?.groupValues?.get(1) ?: ""

        val dirName = projectDirName.get()

        logger.lifecycle("Project directory name: $dirName")
        logger.lifecycle("settings.gradle.kts rootProject.name: $rootProjectName")

        // Check if we're in the template repo itself
        val isTemplateRepo = dirName == "cmp-lib-template" && rootProjectName == "cmp-lib-template"

        // Check if repo was created from template but not configured
        val isUnconfigured = rootProjectName == "cmp-lib-template" && dirName != "cmp-lib-template"

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
                ║  Project directory: $dirName
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

val checkTask = tasks.register<CheckTemplateSetupTask>("checkTemplateSetup") {
    group = "verification"
    description = "Checks if the template has been properly configured"
    settingsFile.set(layout.projectDirectory.file("settings.gradle.kts"))
    projectDirName.set(providers.provider { layout.projectDirectory.asFile.name })
}

// Run check before builds
tasks.matching {
    it.name in listOf("build", "assemble", "test", "publishToMavenLocal", "publishToMavenCentral")
}.configureEach {
    dependsOn(checkTask)
}
