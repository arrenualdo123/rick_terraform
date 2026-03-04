pipeline {
    agent any

    tools {
        nodejs 'nodejs'   // Ajusta el nombre según tu configuración (puede ser 'nodejs' o 'NodeJS 18')
    }

    environment {
        SONAR_TOKEN = credentials('sonar-token')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/luishark2/rick-morty.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Dependency Security Audit') {
            steps {
                // Analiza vulnerabilidades en dependencias (no detiene el pipeline)
                sh 'npm audit --audit-level=moderate || true'
            }
        }

        stage('Run Lint') {
            steps {
                sh 'npm run lint || true'
            }
        }

        stage('Run Tests with Coverage') {
            steps {
                sh 'npm run test'   // Este script debe ejecutar pruebas y generar cobertura
            }
            post {
                always {
                    // Publica reporte de pruebas JUnit si tu framework lo genera (ej. vitest --reporter=junit)
                    junit 'junit.xml'   // Ajusta la ruta si es necesario
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    script {
                        def scannerHome = tool name: 'SonarQube Scanner', type: 'hudson.plugins.sonar.SonarRunnerInstallation'
                        sh "${scannerHome}/bin/sonar-scanner"
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'HOURS') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Build') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Archive Build Artifacts') {
            steps {
                // Guarda el directorio de salida del build (dist, build, etc.)
                archiveArtifacts artifacts: 'dist/**', fingerprint: true
            }
        }

        stage('Publish to GitHub Releases (Opcional)') {
            when {
                branch 'main'
            }
            steps {
                script {
                    // Requiere tener instalado gh (GitHub CLI) en el contenedor Jenkins y credenciales configuradas
                    def version = "v1.0.${env.BUILD_NUMBER}"
                    sh """
                        gh release create $version --title "Release $version" --notes "Build automático desde Jenkins" ./dist/*
                    """
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}