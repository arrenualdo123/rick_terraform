pipeline {
    agent any

    tools {
        nodejs 'nodejs'   // Nombre de tu herramienta NodeJS en Jenkins
    }

    environment {
        SONAR_TOKEN = credentials('sonar-token')
    }

    stages {
        // El checkout inicial ya lo hace Jenkins automáticamente, no necesitas otra etapa

        stage('Clean and Install Dependencies') {
            steps {
                sh 'rm -rf node_modules package-lock.json'
                sh 'npm install'
            }
        }

        stage('Dependency Security Audit') {
            steps {
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
                // Capturar error para que el pipeline continúe
                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILED') {
                    sh 'npm run test'
                }
            }
            post {
                always {
                    script {
                        if (fileExists('junit.xml')) {
                            junit 'junit.xml'
                        }
                    }
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
                archiveArtifacts artifacts: 'dist/**', fingerprint: true
            }
        }

        // Opcional: stage('Publish to GitHub Releases') { ... }
    }

    post {
        always {
            cleanWs()
        }
    }
}