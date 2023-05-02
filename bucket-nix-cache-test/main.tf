provider "aws" {
  profile = "default"
  region  = "us-east-1"
  # region  = "sa-east-1"
}

locals {
  name        = "AWS bucket Terraform"
  environment = terraform.workspace

  # This is the convention we use to know what belongs to each other
  resource_name = "${local.name}-${local.environment}"
  bucket_name = "playing-bucket-nix-cache-test"
}
