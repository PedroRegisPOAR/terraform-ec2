terraform {
  backend "s3" {
    bucket = "playing-with-ec2"
    region = "us-east-1"
    key    = "mytfstate.tfstate"
  }
}
