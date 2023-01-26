resource "aws_s3_bucket" "bucket-nix-cache-test" {
  bucket = local.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.bucket-nix-cache-test.id
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
                "arn:aws:s3:::example-es",
                "arn:aws:s3:::example-es/*"
            ],
            "Principal": "*"
        }
    ]
}
EOF
}


resource "aws_s3_bucket_public_access_block" "bucket-nix-cache-test" {
  bucket = aws_s3_bucket.bucket-nix-cache-test.id

  block_public_acls   = true
  block_public_policy = true
}
