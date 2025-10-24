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

        // 🚀 Étape 1 : Infrastructure Terraform
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

        // ⚙️ Étape 2 : Cloner le code
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Seynabou26/full_stack_app.git'
            }
        }

        // 📦 Étape 3 : Installer les dépendances
        stage('Install dependencies - Backend') {
            steps {
                dir('back') {
                    sh 'npm install'
                }
            }
        }

        stage('Install dependencies - Frontend') {
            steps {
                dir('front') {
                    sh 'npm install'
                }
            }
        }

        // 🧪 Étape 4 : Exécuter les tests
        stage('Run tests') {
            steps {
                script {
                    sh 'cd back && npm test || echo "Aucun test backend"'
                    sh 'cd front && npm test || echo "Aucun test frontend"'
                }
            }
        }

        // 🐳 Étape 5 : Build des images Docker
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

        // 📤 Étape 6 : Push des images sur DockerHub
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

        // 🧹 Étape 7 : Nettoyage Docker
        stage('Clean Docker') {
            steps {
                sh 'docker container prune -f'
                sh 'docker image prune -f'
            }
        }

        // ☸️ Étape 8 : Déploiement Kubernetes
        stage('Deploy to Kubernetes') {
            steps {
                withKubeConfig([credentialsId: 'kubeconfig-jenkins']) {
                    // MongoDB
                    sh "kubectl apply -f k8s/mongo-deployment.yaml"
                    sh "kubectl apply -f k8s/mongo-service.yaml"

                    // Backend
                    sh "kubectl apply -f k8s/back-deployment.yaml"
                    sh "kubectl apply -f k8s/back-service.yaml"

                    // Frontend
                    sh "kubectl apply -f k8s/front-deployment.yaml"
                    sh "kubectl apply -f k8s/front-service.yaml"

                    // Vérification du déploiement
                    sh "kubectl rollout status deployment/mongo"
                    sh "kubectl rollout status deployment/backend"
                    sh "kubectl rollout status deployment/frontend"
                }
            }
        }

    }

    // 📧 Notifications email
    post {
        success {
            emailext(
                subject: "✅ Build SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Pipeline réussi !\nDétails : ${env.BUILD_URL}",
                to: "seynaboubadji26@gmail.com"
            )
        }
        failure {
            emailext(
                subject: "❌ Build FAILED: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Le pipeline a échoué.\nDétails : ${env.BUILD_URL}",
                to: "seynaboubadji26@gmail.com"
            )
        }
    }

}
