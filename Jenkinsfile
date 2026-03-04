pipeline {
    agent any

    tools {
        nodejs 'nodejs'   // Asegúrate que coincide con el nombre en Jenkins
    }

    environment {
        SONAR_TOKEN = credentials('sonar-token')
    }

    stages {
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
                script {
                    // Ejecutar pruebas y capturar código de salida
                    def exitCode = sh(script: 'npm run test', returnStatus: true)
                    if (exitCode != 0) {
                        currentBuild.result = 'UNSTABLE'
                        echo "Las pruebas fallaron con código ${exitCode}. El build se marca como inestable."
                    }
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
    }

    post {
        always {
            cleanWs()
        }
    }
}