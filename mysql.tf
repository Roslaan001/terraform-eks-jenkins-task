data "aws_eks_cluster" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks.cluster_name]
}

data "aws_eks_cluster_auth" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks.cluster_name]
}


provider "kubernetes" {
  # load_config_file       = "false"
  alias                  = "mysql"
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.cluster.endpoint
    token                  = data.aws_eks_cluster_auth.cluster.token
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  }
}

resource "helm_release" "mysql" {
  name       = "my-release"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "mysql"
  version    = "9.14.0"
  timeout    = "1000" # seconds

  values = [
    "${file("values.yaml")}"
  ]

  # Set chart values individually
  set = [{
    name  = "volumePermissions.enabled"
    value = "true"
  }]
}