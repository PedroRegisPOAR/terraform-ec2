module "bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.bucket_name

}
