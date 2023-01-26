module "bucket-nix-cache-test" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = local.bucket_name

  attach_policy = true

  policy = <<POLICY
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
                "arn:aws:s3:::playing-bucket-nix-cache-test",
                "arn:aws:s3:::playing-bucket-nix-cache-test/*"
            ],
            "Principal": "*"
        }
    ]
}
POLICY
}
