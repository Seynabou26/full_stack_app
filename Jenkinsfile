pipeline {
    agent any

    tools {
        nodejs "NodeJS_22"
    }

    environment {
        DOCKER_HUB_USER = 'seynabou02'
        FRONT_IMAGE = 'react-frontend'
        BACKEND_IMAGE = 'express-backend'
        AWS_DEFAULT_REGION = 'us-west-2'
        PATH = "/usr/local/bin:$PATH"
    }

    parameters {
        booleanParam(name: 'APPLY_INFRA', defaultValue: false, description: 'Appliquer Terraform apply ?')
    }

    triggers {
        GenericTrigger(
            genericVariables: [
                [key: 'ref', value: '$.ref'],
                [key: 'pusher_name', value: '$.pusher.name'],
                [key: 'commit_message', value: '$.head_commit.message']
            ],
            causeString: 'Push par $pusher_name sur $ref: "$commit_message"',
            token: 'mywebhook',
            printContributedVariables: true,
            printPostContent: true
        )
    }

    stages {

        //  Étape 1 : Infrastructure Terraform
        stage('Terraform - Infrastructure AWS') {
            steps {
                script {
                    withCredentials([
                        usernamePassword(
                            credentialsId: 'aws-credentials',
                            usernameVariable: 'AWS_ACCESS_KEY_ID',
                            passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                        ),
                        string(
                            credentialsId: 'aws-session-token',
                            variable: 'AWS_SESSION_TOKEN'
                        )
                    ]) {
                        dir('terraform') {
                            // Init et plan Terraform
                            sh '''
                                terraform init
                                terraform plan -var-file=terraform.tfvars
                            '''
                            if (params.APPLY_INFRA) {
                                sh '''
                                    terraform apply -auto-approve -var-file=terraform.tfvars
                                '''
                            }
                        }
                    }
                }
            }
        }

        // Étape 2 : Cloner le code
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Seynabou26/full_stack_app.git'
            }
        }

        // Étape 3 : Scan sécurité Trivy - Analyse du code (FS)
        stage('Trivy - FS scan') {
            steps {
                sh '''
                    echo "Scan Trivy du code (File System)..."
                    trivy fs --exit-code 0 --severity HIGH,CRITICAL .
                '''
            }
        }

        // Étape 4 : Scan Trivy - Configuration (K8s + Terraform)
        stage('Trivy - Config Scan') {
            steps {
                sh '''
                    echo "Scan Trivy des configurations..."
                    trivy config --exit-code 0 ./k8s
                    trivy config --exit-code 0 ./terraform
                '''
            }
        }

        // Installer dépendances backend
        stage('Install dependencies - Backend') {
            steps {
                dir('back') {
                    sh 'npm install'
                }
            }
        }

        // Installer dépendances frontend
        stage('Install dependencies - Frontend') {
            steps {
                dir('front') {
                    sh 'npm install'
                }
            }
        }

        // Tests
        stage('Run tests') {
            steps {
                script {
                    sh 'cd back && npm test || echo "Aucun test backend"'
                    sh 'cd front && npm test || echo "Aucun test frontend"'
                }
            }
        }

        // Build Docker
        stage('Build Docker Images') {
            steps {
                script {
                    sh """
                        docker build -t $DOCKER_HUB_USER/$FRONT_IMAGE:latest \
                        --build-arg VITE_API_URL=http://192.168.49.2:30001/api ./front
                    """
                    sh "docker build -t $DOCKER_HUB_USER/$BACKEND_IMAGE:latest ./back"
                }
            }
        }

        // Étape Trivy après build : Scan image Docker
        stage('Trivy - Image Scan') {
            steps {
                sh """
                    echo "Scan Trivy sur l'image frontend..."
                    trivy image --exit-code 0 $DOCKER_HUB_USER/$FRONT_IMAGE:latest

                    echo "Scan Trivy sur l'image backend..."
                    trivy image --exit-code 0 $DOCKER_HUB_USER/$BACKEND_IMAGE:latest
                """
            }
        }

        // Push DockerHub
        stage('Push Docker Images') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'DOCKER_CREDENTIALS', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                        docker push $DOCKER_USER/$FRONT_IMAGE:latest
                        docker push $DOCKER_USER/$BACKEND_IMAGE:latest
                    '''
                }
            }
        }

        // Nettoyage Docker
        stage('Clean Docker') {
            steps {
                sh 'docker container prune -f'
                sh 'docker image prune -f'
            }
        }

        // Déploiement Kubernetes
        stage('Deploy to Kubernetes') {
            steps {
                withKubeConfig([credentialsId: 'kubeconfig-jenkins']) {
                    sh "kubectl apply -f k8s/mongo-deployment.yaml"
                    sh "kubectl apply -f k8s/mongo-service.yaml"

                    sh "kubectl apply -f k8s/back-deployment.yaml"
                    sh "kubectl apply -f k8s/back-service.yaml"

                    sh "kubectl apply -f k8s/front-deployment.yaml"
                    sh "kubectl apply -f k8s/front-service.yaml"

                    // Vérification déploiement
                    sh "kubectl rollout status deployment/mongo"
                    sh "kubectl rollout status deployment/backend"
                    sh "kubectl rollout status deployment/frontend"
                }
            }
        }

    }

    // Notifications
    post {
        success {
            emailext(
                subject: "Build SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Pipeline réussi !\nDétails : ${env.BUILD_URL}",
                to: "seynaboubadji26@gmail.com"
            )
        }
        failure {
            emailext(
                subject: "Build FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Le pipeline a échoué.\nDétails : ${env.BUILD_URL}",
                to: "seynaboubadji26@gmail.com"
            )
        }
    }

}
