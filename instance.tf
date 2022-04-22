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
  instance_count = 5

  # From:
  # https://github.com/NixOS/nixpkgs/blob/f00f6180725199227d38098873f1516838ca87bc/nixos/modules/virtualisation/amazon-ec2-amis.nix#L413
  # ami                    = "ami-0f43f74cbbdd1ddef"
  ami                    = "ami-0ac80df6eff0e70b5"
  #
  # https://aws.amazon.com/ec2/instance-types/?nc1=h_ls
  # instance_type          = "i3.metal"
  # instance_type          = "t2.nano"
  # instance_type          = "t2.micro"
  instance_type          = "t2.medium"
  # instance_type          = "t2.xlarge"
  # instance_type          = "t2.2xlarge"
  #iam_instance_profile   = "ec2-role"
  key_name               = local.name
  monitoring             = true
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [module.ec2_security_group.this_security_group_id]

  user_data = file("./post_install_scripts/install.sh")

  tags = {
    Name        = local.name
    Environment = local.environment
  }
}
