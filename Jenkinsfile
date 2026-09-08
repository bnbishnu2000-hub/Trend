pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
        timeout(time: 30, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '15'))
    }

    triggers {
        githubPush()
    }

    environment {
        DOCKER_IMAGE = 'bishnu2000/trend-app'
        DOCKER_TAG   = "${BUILD_NUMBER}"
        AWS_REGION   = 'eu-north-1'
        EKS_CLUSTER  = 'trend-cluster'
        NAMESPACE    = 'default'
        PATH         = "/usr/local/bin:${env.PATH}"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/bnbishnu2000-hub/Trend.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    set -eu
                    docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} .
                    docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USERNAME',
                    passwordVariable: 'DOCKER_PASSWORD'
                )]) {
                    sh '''
                        set -eu
                        echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
                        docker push ${DOCKER_IMAGE}:${DOCKER_TAG}
                        docker push ${DOCKER_IMAGE}:latest
                    '''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                    set -eu
                    aws eks update-kubeconfig --region ${AWS_REGION} --name ${EKS_CLUSTER}
                    kubectl -n ${NAMESPACE} set image deployment/trend-app \
                        trend-app=${DOCKER_IMAGE}:${DOCKER_TAG}
                    kubectl -n ${NAMESPACE} rollout status deployment/trend-app --timeout=300s
                '''
            }
        }

        stage('Verify') {
            steps {
                sh '''
                    set -eu
                    kubectl -n ${NAMESPACE} get pods -o wide
                    kubectl -n ${NAMESPACE} get svc trend-service
                '''
            }
        }
    }

    post {
        always {
            sh 'docker logout >/dev/null 2>&1 || true'
            sh 'docker image prune -f >/dev/null 2>&1 || true'
        }
        success {
            echo 'Trend application deployed successfully.'
        }
        failure {
            echo 'Deployment failed. Check the stage log above.'
        }
    }
}
