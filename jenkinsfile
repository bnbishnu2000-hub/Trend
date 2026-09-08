pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'bishnu2000/trend-app'
        DOCKER_TAG = "${BUILD_NUMBER}"
    }

    stage('Checkout') {
    steps {
        git branch: 'main',
            url: 'https://github.com/bnbishnu2000-hub/Trend.git'
    }
}

    

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                    docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds',
                        usernameVariable: 'DOCKER_USERNAME',
                        passwordVariable: 'DOCKER_PASSWORD'
                    )
                ]) {
                    sh '''
                        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        docker push ${DOCKER_IMAGE}:latest
                        docker logout
                    '''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                    aws eks update-kubeconfig \
                      --region eu-north-1 \
                      --name trend-cluster

                    kubectl set image deployment/trend-app \
                      trend-app=${DOCKER_IMAGE}:${DOCKER_TAG}

                    kubectl rollout status deployment/trend-app
                '''
            }
        }
    }

    post {
        success {
            echo 'Trend application deployed successfully!'
        }

        failure {
            echo 'Trend deployment failed!'
        }
    }
}
