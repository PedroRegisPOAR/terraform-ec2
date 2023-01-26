module "bucket-nix-cache-test" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.bucket_name

  attach_policy = true

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadAccess",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${local.bucket_name}/*"
        }
    ]
}
POLICY
}
