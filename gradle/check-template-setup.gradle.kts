// Check if template has been configured
// This task ensures users don't forget to run setup-template.sh

tasks.register("checkTemplateSetup") {
    doLast {
        val settingsFile = rootProject.file("settings.gradle.kts")
        val content = settingsFile.readText()

        if (content.contains("cmp-lib-template")) {
            val errorMessage = """
                
                ╔════════════════════════════════════════════════════════════╗
                ║              ⚠️  TEMPLATE NOT CONFIGURED ⚠️               ║
                ╠════════════════════════════════════════════════════════════╣
                ║                                                            ║
                ║  This project was created from a template and needs to     ║
                ║  be configured with your library details.                  ║
                ║                                                            ║
                ║  Please run:                                               ║
                ║                                                            ║
                ║      ./setup-template.sh                                   ║
                ║                                                            ║
                ║  This will configure your library name, package            ║
                ║  structure, and Maven coordinates.                         ║
                ║                                                            ║
                ║  See: docs/using-this-template.md for details              ║
                ║                                                            ║
                ╚════════════════════════════════════════════════════════════╝
                
            """.trimIndent()

            logger.error(errorMessage)
            throw GradleException("Template not configured. Run ./setup-template.sh first.")
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

