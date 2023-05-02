module "bucket-nix-cache-test" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.bucket_name

  attach_policy = true

  # https://docs.aws.amazon.com/pt_br/AmazonS3/latest/userguide/example-bucket-policies.html#example-bucket-policies-acl-1
  # AllowDirectReads vs AddPublicReadCannedAcl
  policy = <<EOF
{
    "Id": "DirectReads",
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AllowDirectReads",
            "Action": [
                "s3:GetObject",
                "s3:GetBucketLocation"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${local.bucket_name}",
                "arn:aws:s3:::${local.bucket_name}/*"
            ],
            "Principal": "*"
        }
    ]
}
EOF
}

