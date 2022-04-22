#output "id" {
#  description = "Contains the EIP allocation ID"
#  value       = aws_eip.my_ip.id
#}
#
#output "public_ip" {
#  description = "Contains the public IP address"
#  value       = aws_eip.my_ip.public_ip
#}

#output "public_dns" {
#  description = "Public DNS associated with the Elastic IP address"
#  value       = aws_eip.my_ip.public_dns
#}

#output "ec2_instance_public_ips" {
#  description = "Public IP addresses of EC2 instances"
#  value       = module.ec2_cluster.public_ip
#}

## https://stackoverflow.com/a/52688167
#output "aws_ec2_instance_ids" {
#  value = module.ec2_cluster.*.public_ip
#}

# How would be a better way for this?
output "ec2_instance_public_ip_0" {
  description = "Public IP addresses of EC2 instance 0"
  value       = module.ec2_cluster.public_ip[0]
}

output "ec2_instance_public_ip_1" {
  description = "Public IP addresses of EC2 instance 1"
  value       = module.ec2_cluster.public_ip[1]
}

output "ec2_instance_public_ip_2" {
  description = "Public IP addresses of EC2 instance 2"
  value       = module.ec2_cluster.public_ip[2]
}

output "ec2_instance_public_ip_3" {
  description = "Public IP addresses of EC2 instance 3"
  value       = module.ec2_cluster.public_ip[3]
}

output "ec2_instance_public_ip_4" {
  description = "Public IP addresses of EC2 instance 4"
  value       = module.ec2_cluster.public_ip[4]
}
