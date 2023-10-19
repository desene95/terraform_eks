resource "aws_vpc" "main" {
    #name = var.vpc_name
    cidr_block = var.cidr_block
    #location = var.location

    tags = {
        Name=var.vpc_name
    }
  
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

output "vpc_id" {
    value = aws_vpc.main.id
}

output "igw_id" {
    value = aws_internet_gateway.igw.id
}

locals {
    #environment = "development"
    consumable = aws_vpc.main.id
}
output "consumable" {
  value       = local.consumable
  description = "The consumable object. It is the responsibility of the consumable to conceal sensitive attributes."
  sensitive   = false
}