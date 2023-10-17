locals{
    env_config = yamldecode(file(format("%s/%s", get_env("MAIN_CONFIG_PATH"), get_env("ENV_CONFIG_FILE_NAME"))))
    tfstate_key = replace(get_terragrunt_dir(), get_env("ORCHESTRATION_PATH"), "orchestration")
}

remote_state{
    backend = "s3"

    generate = {
        path = "backend.tf"
        if_exists = "overwrite"
    }
    config = {
        bucket = local.env_config.global.remote_state.bucket_name
        #prefix = "${path_relative_to_include()}"
        #project = local.env_config.global.host_project.id
        region = local.env_config.global.region
        #key = "${path_relative_to_include()}/terraform.tfstate"
        #key = "terraform.tfstate"
        key = "${local.tfstate_key}/terraform.tfstate"
    }
}