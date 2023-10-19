resource "aws_eip" "nat"{
    vpc = true

    tags = {
        Name = var.eip_name
    }
}
data "terraform_remote_state" "aws_subnet"{
      backend = "s3"
      config = {
      bucket         = "dame-terraform-bucket"
      key            = "orchestration/pub_subnet_1/terraform.tfstate"
      region         = "ca-central-1"  # Modify this to match your S3 bucket's region
      #encrypt        = true
      #shared_credentials_file = "/path/to/aws/credentials/file"  # Optional, if using shared credentials
    }
}

output "subnet_id"{
    value = data.terraform_remote_state.aws_subnet.outputs
}

resource "aws_nat_gateway" "nat"{
    allocation_id = aws_eip.nat.id
    subnet_id = data.terraform_remote_state.aws_subnet.outputs.subnet_id

    tags={
        Name = var.nat_name
    }
}

output "nat_gw_id" {
    value = aws_nat_gateway.nat.id
}