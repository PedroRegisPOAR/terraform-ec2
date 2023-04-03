module "ec2_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name        = local.resource_name
  description = "Security group"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp", "kubernetes-api-tcp", "ssh-tcp", "all-icmp"]
  egress_rules        = ["all-all"]

  tags = {
    Type        = "ec2"
    Name        = local.name
    Environment = local.environment
  }
}

module "ec2_cluster" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  name           = local.resource_name
  instance_count = 1

  # It is broken!
  # From: https://github.com/NixOS/nixpkgs/blob/f00f6180725199227d38098873f1516838ca87bc/nixos/modules/virtualisation/amazon-ec2-amis.nix#L413
  # ami                    = "ami-0f43f74cbbdd1ddef"
  # ami                    = "ami-0ac80df6eff0e70b5"

  # This is an Ubuntu 22.04 amd64
  # uname -a
  # Linux ip-10-1-11-201 5.15.0-1004-aws #6-Ubuntu SMP Thu Mar 31 09:44:20 UTC 2022 x86_64 x86_64 x86_64 GNU/Linux
  # From: https://cloud-images.ubuntu.com/locator/
  ami                    = "ami-09d56f8956ab235b3"

  # This is an Ubuntu 22.04 arm64
  # uname -a
  # TODO: it is broken as of now, why?
  # From: https://cloud-images.ubuntu.com/locator/
  # ami                    = "ami-0c6c29c5125214c77"


  # 20.04
  # ami                    = "ami-0c4f7023847b90238"

  # NixOS AMI, is working, and with nix 2.11
  # https://github.com/NixOS/nixpkgs/issues/112354#issuecomment-777813593
  # https://nixos.org/download.html#nixos-virtualbox
  #
  # Old
  # ami                    = "ami-0508167db03652cc4"
  # https://github.com/NixOS/nixpkgs/blob/0be721b12930887fd883260ddb29c80225eaa9f3/nixos/modules/virtualisation/amazon-ec2-amis.nix#L411
  # ami                    = "ami-099756bfda4540da0"

  # 18.04
  # ami                    = "ami-0ac80df6eff0e70b5"

  # 14.04
  # ami                    = "ami-0b174091769efec66"

  # Ubuntu 22.04 arm
  # From: https://cloud-images.ubuntu.com/locator/
  # ami                    = "ami-02ddaf75821f25213"

  #ami                    = "ami-23475747"
  #
  # https://aws.amazon.com/ec2/instance-types/?nc1=h_ls
  # instance_type          = "i3.metal"
  # instance_type          = "t2.nano"
  instance_type          = "t2.micro"
  # instance_type          = "t2.medium"
  # instance_type          = "t2.xlarge"
  # instance_type          = "t2.2xlarge"

  # instance_type          = "r6g.4xlarge"
  # instance_type          = "c5.large"

  #iam_instance_profile   = "ec2-role"
  key_name               = local.name
  monitoring             = true
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.ec2_security_group.this_security_group_id]

  user_data = file("./post_install_scripts/install.sh")

  root_block_device = [
    {
      volume_size = 120
      # https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#delete_on_termination
      delete_on_termination = true
    },
  ]

  tags = {
    Name        = local.name
    Environment = local.environment
  }
}
