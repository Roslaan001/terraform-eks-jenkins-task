Pipeline any {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key_id')
        AWS_SECRET_ACCESS_KEY = credentials('jenkins-aws_secret_access_key')
    }

    stages {
        stage('Provisioning of cluster') {
            environment {
                TF_VAR_env_prefix = "dev"
                TF_VAR_private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
                TF_VAR_public_subnets = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
                TF_VAR_cidr_block = "10.0.0.0/16"
            }
            steps {
                script {
                    echo "Creating your EKS cluster"
                    sh "terraform init"
                    sh "terraform apply -auto-approve"


                    env.K8S_CLUSTER_URL = sh(
                        script: "terraform output cluster_url",
                        returnStdout: true
                    ).trim()

                    sh "aws eks update-kubeconfig --name my-eks-cluster-task --region us-east-1"
                }
               
            }
}
}
 }