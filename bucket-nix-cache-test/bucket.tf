module "bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.bucket_name

  block_public_acls   = true
  block_public_policy = true

}
