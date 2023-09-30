pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'us-east-1'  // Change to your AWS region
    }

    stages {
        stage('Checkout') {
            steps {
                // This step checks out your code from the source control.
                checkout scm
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh 'terraform plan'
            }
        }

        stage('Terraform Apply') {
            when {
                // Condition to run apply, e.g., only on the main branch.
                branch 'main'
            }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', 
                                  credentialsId: 'aws-credentials-id', 
                                  accessKeyVariable: 'AWS_ACCESS_KEY_ID', 
                                  secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {

                    sh 'terraform apply -auto-approve'
                }
            }
        }
    }
}
