locals {
    env_config = yamldecode(file("${get_terragrunt_dir()}/../config_main.yaml"))
    resources = yamldecode(file("${get_terragrunt_dir()}/../config_env_resources.yaml"))
    
}

terraform {
    source = "/Users/damianesene/terraform_eks/modules/nat_gateway"
}

inputs = {
    eip_name = local.resources.global.network.nat_gateway.eip_name
    nat_name      = local.resources.global.network.nat_gateway.nat_name
}

include {
  path = find_in_parent_folders()
}