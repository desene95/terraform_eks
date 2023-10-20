
data "terraform_remote_state" "priv_sub_1"{
      backend = "s3"
      config = {
      bucket         = "dame-terraform-bucket"
      key            = "orchestration/priv_subnet_1/terraform.tfstate"
      region         = "ca-central-1"  # Modify this to match your S3 bucket's region
      #encrypt        = true
      #shared_credentials_file = "/path/to/aws/credentials/file"  # Optional, if using shared credentials
    }
}

data "terraform_remote_state" "priv_sub_2"{
      backend = "s3"
      config = {
      bucket         = "dame-terraform-bucket"
      key            = "orchestration/priv_subnet_2/terraform.tfstate"
      region         = "ca-central-1"  # Modify this to match your S3 bucket's region
      #encrypt        = true
      #shared_credentials_file = "/path/to/aws/credentials/file"  # Optional, if using shared credentials
    }
}

data "terraform_remote_state" "pub_sub_1"{
      backend = "s3"
      config = {
      bucket         = "dame-terraform-bucket"
      key            = "orchestration/pub_subnet_1/terraform.tfstate"
      region         = "ca-central-1"  # Modify this to match your S3 bucket's region
      #encrypt        = true
      #shared_credentials_file = "/path/to/aws/credentials/file"  # Optional, if using shared credentials
    }
}

data "terraform_remote_state" "pub_sub_2"{
      backend = "s3"
      config = {
      bucket         = "dame-terraform-bucket"
      key            = "orchestration/pub_subnet_2/terraform.tfstate"
      region         = "ca-central-1"  # Modify this to match your S3 bucket's region
      #encrypt        = true
      #shared_credentials_file = "/path/to/aws/credentials/file"  # Optional, if using shared credentials
    }
}

data "terraform_remote_state" "nat_gateway"{
      backend = "s3"
      config = {
      bucket         = "dame-terraform-bucket"
      #key            = "orchestration/*"
      key            = "orchestration/nat_gateway/terraform.tfstate"
      region         = "ca-central-1"  # Modify this to match your S3 bucket's region
      #encrypt        = true
      #shared_credentials_file = "/path/to/aws/credentials/file"  # Optional, if using shared credentials
    }
}

data "terraform_remote_state" "igw"{
      backend = "s3"
      config = {
      bucket         = "dame-terraform-bucket"
      key            = "orchestration/vpc/terraform.tfstate"
      #key            = "orchestration/*"
      region         = "ca-central-1"  # Modify this to match your S3 bucket's region
      #encrypt        = true
      #shared_credentials_file = "/path/to/aws/credentials/file"  # Optional, if using shared credentials
    }
}

# output "nat_gateway_id"{
#     value = data.terraform_remote_state.nat_gateway.outputs
# }

# output "igw_id"{
#     value = data.terraform_remote_state.igw.outputs
# }

# output "vpc_id"{
#     value = data.terraform_remote_state.igw.outputs
# }
resource "aws_route_table" "private"{
    vpc_id = data.terraform_remote_state.igw.outputs.vpc_id

    route = [
        {
            cidr_block                  = "0.0.0.0/0"
            nat_gateway_id              = data.terraform_remote_state.nat_gateway.outputs.nat_gw_id
            carrier_gateway_id          = ""
            core_network_arn            = ""
            destination_prefix_list_id  = ""
            egress_only_gateway_id      = "" 
            ipv6_cidr_block             = null
            local_gateway_id            = ""
            network_interface_id        = ""
            transit_gateway_id          = ""
            vpc_endpoint_id             = ""
            vpc_peering_connection_id   = ""
            gateway_id                  = ""
        }
    ]
    tags = {
        Name = "private"
    }
}

resource "aws_route_table" "public"{
    vpc_id = data.terraform_remote_state.igw.outputs.vpc_id

    route = [
        {
            cidr_block                  = "0.0.0.0/0"
            gateway_id                  = data.terraform_remote_state.igw.outputs.igw_id
            carrier_gateway_id          = ""
            core_network_arn            = ""
            destination_prefix_list_id  = ""
            egress_only_gateway_id      = "" 
            ipv6_cidr_block             = null
            local_gateway_id            = ""
            network_interface_id        = ""
            transit_gateway_id          = ""
            vpc_endpoint_id             = ""
            vpc_peering_connection_id   = ""
            nat_gateway_id              = ""
        }
    ]
    tags = {
        Name = "public"
    }
}

resource "aws_route_table_association" "priv_sub_1"{
    subnet_id = data.terraform_remote_state.priv_sub_1.outputs.priv_subnet_id
    route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "priv_sub_2"{
    subnet_id = data.terraform_remote_state.priv_sub_2.outputs.priv_subnet_id
    route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "pub_sub_1"{
    subnet_id = data.terraform_remote_state.pub_sub_1.outputs.subnet_id
    route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "pub_sub_2"{
    subnet_id = data.terraform_remote_state.pub_sub_2.outputs.subnet_id
    route_table_id = aws_route_table.public.id
}