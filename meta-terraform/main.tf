provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

locals {
  name        = "Meta Terraform"
  environment = terraform.workspace

  # This is the convention we use to know what belongs to each other
  resource_name = "${local.name}-${local.environment}"
  bucket_name = "playing-with-ec2"
}
