locals {
    env_config = yamldecode(file("${get_terragrunt_dir()}/../config_main.yaml"))
    resources = yamldecode(file("${get_terragrunt_dir()}/../config_env_resources.yaml"))
    
}

terraform {
    source = "/Users/damianesene/terraform_eks/modules/eks"
}

inputs = {
    eks_name       =   local.resources.global.eks.eks_name
    node_group_name  =   local.resources.global.eks.node_group_name

}

include {
  path = find_in_parent_folders()
}