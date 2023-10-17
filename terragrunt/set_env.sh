#!/bin/bash

THIS_DIR="$( cd "$(dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"
find . -name .terragrunt-cache -type d -exec rm -rf {} +
find . -name .terraform -type d -exec rm -rf {} +

export ENV_CONFIG_FILE_NAME=config_main.yaml
export ORCHESTRATION_PATH=${THIS_DIR}/orchestration 
export MAIN_CONFIG_PATH=${THIS_DIR}/orchestration
export MAIN_CONFIG_FILE_NAME=config_main.yaml

