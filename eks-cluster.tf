
module "eks" {
  source                                   = "terraform-aws-modules/eks/aws"
  version                                  = "20.37.2"
  cluster_name                             = "my-eks-cluster-task"
  cluster_version                          = "1.33"
  enable_irsa                              = true
  cluster_endpoint_public_access           = true
  cluster_endpoint_public_access_cidrs     = ["0.0.0.0/0"]
  vpc_id                                   = module.vpc.vpc_id
  subnet_ids                               = module.vpc.private_subnets
  enable_cluster_creator_admin_permissions = true

  # Add access entries instead of using aws-auth ConfigMap
  access_entries = {
    roslaan_user = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::381492075201:user/Roslaan01"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }

    sso_role = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::381492075201:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_PowerUserAccess_191f2b34491031f8"

      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  tags = {
    "kubernetes.io/cluster/my-eks-cluster-task" = "shared"
    Environment                                 = var.env_prefix
    Name                                        = "my-eks-cluster-task"
  }
  eks_managed_node_groups = {
    dev = {
      use_custom_templates = false
      instance_types       = ["t3.small"]
      node_group_name      = var.env_prefix
      min_size             = 1
      max_size             = 3
      desired_size         = 2
      tags = {
        "Name" = "${var.env_prefix}-node-group"
      }
    }
  }
  fargate_profiles = {
    dev = {
      name               = "${var.env_prefix}-fargate-profile"
      pod_execution_role = "arn:aws:iam::381492075201:role/eks-fargate-pod-execution-role"

      subnets = module.vpc.private_subnets
      selectors = [
        {
          namespace = "my-app"
        }
      ]
    }
  }

  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent = true # Use the most recent version compatible with your cluster
    }
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  iam_role_additional_policies = {
    AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  }


}

