pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPO = '715841364973.dkr.ecr.us-east-1.amazonaws.com/demo-app-jenkins'
        IMAGE_TAG = "${env.BUILD_NUMBER}"
        S3_BUCKET = 'build-artifakt-jenkins'
        
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/ugursakarya0707/demo-pipeline.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    dockerImage = docker.build("demo-docker:${IMAGE_TAG}")
                }
            }
        }
        stage('Push to ECR') {
            steps {
                script {
                    // ECR’ye giriş yapılması
                    sh '''
                        aws ecr-public get-login-password --region us-east-1 | docker login -u AWS --password-stdin public.ecr.aws
                    '''
                    // Docker image’ı push etme
                    sh "docker tag demo-docker:${IMAGE_TAG} ${ECR_REPO}:latest"
                    sh "docker push ${ECR_REPO}:latest"
                }
            }
        }
        stage('Prepare Artifact') {
            steps {
                script {
                    // imagedefinitions.json dosyasını oluşturma
                    writeFile file: 'imagedefinitions.json', text: """
                    [
                        {
                            "name": "demo-docker-container",
                            "imageUri": "${ECR_REPO}:latest"
                        }
                    ]
                    """
                }
                // Dosyayı S3'e yüklemek
                sh """
                    aws s3 cp imagedefinitions.json s3://${S3_BUCKET}
                """
            }
        }
    }
}
