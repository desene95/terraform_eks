locals {
    env_config = yamldecode(file("${get_terragrunt_dir()}/../config_main.yaml"))
    resources = yamldecode(file("${get_terragrunt_dir()}/../config_env_resources.yaml"))
    
}

terraform {
    source = "/Users/damianesene/terraform_eks/modules/iam"
}

inputs = {
    eks_role_name       =   local.resources.global.iam.eks_role_name
    eks_node_role_name  =   local.resources.global.iam.eks_node_role_name

}

include {
  path = find_in_parent_folders()
}