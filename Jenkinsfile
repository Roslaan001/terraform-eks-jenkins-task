pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('jenkins_aws_secret_access_key')
        AWS_DEFAULT_REGION = 'us-east-1'
        CLUSTER_NAME = 'my-eks-cluster-task'
        PRINCIPAL_ARN = 'arn:aws:iam::381492075201:user/Roslaan01'
    }
    stages {
        stage('Provisioning of cluster') {
            environment {
                TF_VAR_env_prefix = "dev"
                TF_VAR_vpc_cidr = "10.0.0.0/16"
            }
            steps {
                script {
                    echo "Creating your EKS cluster"
                    sh "terraform init"
                    
                    // Try terraform apply, if it fails due to access entry conflict, handle it
                    def applyResult = sh(
                        script: "terraform apply -auto-approve",
                        returnStatus: true
                    )
                    
                    if (applyResult != 0) {
                        echo "Terraform apply failed, checking if it's due to access entry conflict..."
                        
                        // Import the access entry and retry
                        echo "Importing existing access entry..."
                        sh "terraform import 'module.eks.aws_eks_access_entry.this[\"cluster_creator\"]' '${CLUSTER_NAME}:${PRINCIPAL_ARN}'"
                        
                        echo "Retrying terraform apply..."
                        sh "terraform apply -auto-approve"
                    }
                    
                    // Get cluster endpoint
                    env.K8S_CLUSTER_URL = sh(
                        script: "terraform output cluster_url",
                        returnStdout: true
                    ).trim()
                    
                    // Update kubeconfig
                    sh "aws eks update-kubeconfig --name ${CLUSTER_NAME} --region ${AWS_DEFAULT_REGION}"
                }
            }
        }
    }
}
