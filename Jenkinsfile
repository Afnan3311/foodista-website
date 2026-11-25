
pipeline {
    agent any

    environment {
        // Docker Hub Configuration
        DOCKER_CREDENTIALS_ID = 'docker-cred'
        DOCKER_IMAGE          = 'afnan2004/foodista_static_website'

        // SonarQube Configuration
        SONAR_SERVER_NAME  = 'sonarqube_env'
        SONAR_SCANNER_TOOL = 'sonar-scanner'

        // GitHub Configuration
        GIT_CREDENTIALS_ID = 'github-cred'

        // Change this to your Foodista repository URL
        MANIFEST_REPO   = 'https://github.com/Afnan3311/foodista-website.git'
        MANIFEST_BRANCH = 'main'
    }

    stages {

        // 1. Checkout Source Code
        stage('Checkout Source Code') {
            steps {
                checkout scm
            }
        }

        // 2. SonarQube Analysis
        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool "${SONAR_SCANNER_TOOL}"

                    withSonarQubeEnv("${SONAR_SERVER_NAME}") {
                        sh """
                            ${scannerHome}/bin/sonar-scanner \
                            -Dsonar.projectKey=foodista \
                            -Dsonar.projectName=foodista-project \
                            -Dsonar.sources=. \
                            -Dsonar.exclusions=**/manifests/**,**/images/**,**/.git/**,**/node_modules/**
                        """
                    }
                }
            }
        }

        // 3. Build and Push Docker Image
        stage('Build & Push Docker Image') {
            steps {
                script {
                    withCredentials([
                        usernamePassword(
                            credentialsId: "${DOCKER_CREDENTIALS_ID}",
                            usernameVariable: 'DOCKER_USER',
                            passwordVariable: 'DOCKER_PASS'
                        )
                    ]) {
                        sh """
                            echo "\$DOCKER_PASS" | docker login \
                            -u "\$DOCKER_USER" --password-stdin

                            docker build \
                            -t ${DOCKER_IMAGE}:${BUILD_NUMBER} \
                            -t ${DOCKER_IMAGE}:latest \
                            .

                            docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                            docker push ${DOCKER_IMAGE}:latest

                            docker logout
                        """
                    }
                }
            }
        }

        // 4. Update Kubernetes Deployment Manifest
        stage('Update Manifest Repo') {
            steps {
                dir('manifest-workspace') {

                    git branch: "${MANIFEST_BRANCH}",
                        credentialsId: "${GIT_CREDENTIALS_ID}",
                        url: "${MANIFEST_REPO}"

                    withCredentials([
                        usernamePassword(
                            credentialsId: "${GIT_CREDENTIALS_ID}",
                            usernameVariable: 'GH_USER',
                            passwordVariable: 'GH_TOKEN'
                        )
                    ]) {
                        sh '''
                            IMAGE_TAG="${DOCKER_IMAGE}:${BUILD_NUMBER}"

                            sed -i -E \
                            "/name: foodista/{n;s|image:.*|image: ${IMAGE_TAG}|}" \
                            manifests/deployment.yaml

                            git config user.name "Afnan3311"
                            git config user.email "mohdafnan9617@gmail.com"

                            git add manifests/deployment.yaml

                            if ! git diff --cached --quiet; then

                                git commit -m "Update Foodista image to ${BUILD_NUMBER} [skip ci]"

                                PUSH_URL="https://${GH_USER}:${GH_TOKEN}@${MANIFEST_REPO#https://}"

                                git push "$PUSH_URL" HEAD:${MANIFEST_BRANCH}

                            else
                                echo "No manifest changes detected"
                            fi
                        '''
                    }
                }
            }
        }
    }

    post {
        success {
            echo 'Foodista pipeline executed successfully!'
            echo 'Docker image pushed and Kubernetes manifest updated.'
        }

        failure {
            echo 'Foodista pipeline failed. Please review the stage logs.'
        }

        always {
            echo 'Foodista pipeline execution completed.'
        }
    }
}
