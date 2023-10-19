locals {
    env_config = yamldecode(file("${get_terragrunt_dir()}/../config_main.yaml"))
    resources = yamldecode(file("${get_terragrunt_dir()}/../config_env_resources.yaml"))
    
}

terraform {
    source = "/Users/damianesene/terraform_eks/modules/route_tables"
}

inputs = {

}

include {
  path = find_in_parent_folders()
}