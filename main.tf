provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

locals {
  name        = "my-ec2"
  environment = terraform.workspace

  # This is the convention we use to know what belongs to each other
  resource_name = "${local.name}-${local.environment}"
}

resource "aws_s3_bucket" "example-es" {
  bucket = "example-es"
  content_type = "text/html"
  key          = "nix-cache-info"
  content      = <<EOF
StoreDir: /nix/store
WantMassQuery: 1
Priority: 10
EOF

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
                "arn:aws:s3:::example-nix-cache",
                "arn:aws:s3:::example-nix-cache/*"
            ],
            "Principal": "*"
        }
    ]
}
EOF
}

resource "aws_s3_bucket_public_access_block" "example-es" {
  bucket = aws_s3_bucket.example-es.id

  block_public_acls   = true
  block_public_policy = true
}
