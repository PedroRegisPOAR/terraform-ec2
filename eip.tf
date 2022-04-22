#resource "aws_eip" "my_ip" {
#  vpc      = true
#  instance = module.ec2_cluster.id[0]
#
#  tags = {
#    Name        = local.name
#    Environment = local.environment
#  }
#}
