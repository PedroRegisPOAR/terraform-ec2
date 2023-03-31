# terraform-ec2




If you use `nix-direnv` + `direnv`, just `cd` into the project cloned folder. 


This `.pem` is from the AWS site:
```bash
nano ~/.ssh/my-ec2.pem
```


```bash
nix \
flake \
clone \
github:PedroRegisPOAR/terraform-ec2/dev \
--dest terraform-ec2 \
&& cd terraform-ec2 \
&& ( command -v direnv && direnv allow ) || nix develop '.#'
```
Refs.:
- https://stackoverflow.com/a/53900466


```bash
test -d ~/.aws || mkdir -pv ~/.aws

cat > ~/.aws/credentials << 'EOF'
[default]
aws_access_key_id = YOUR_ACCESS_KEY_ID
aws_secret_access_key = YOUR_SECRET_ACCESS_KEY
EOF

cat > ~/.aws/config << 'EOF'
[default]
region = us-east-1
EOF
```


```bash
aws configure list

aws sts get-caller-identity
aws sts get-caller-identity --profile=default
```


```bash
test -d .terraform || make init

make destroy args='-auto-approve' \
&& make apply args='-auto-approve'
```

Maybe useful:
```bash
nix develop .#
```

```bash
aws configure
```

```bash
aws ec2 describe-regions
```

```bash
aws \
ec2 \
describe-images \
--owners amazon \
--filters "Name=name,Values=amzn*gp2" "Name=virtualization-type,Values=hvm" "Name=root-device-type,Values=ebs" \
--query "sort_by(Images, &CreationDate)[-1].ImageId" \
--output text
```


It is a must in the first time.
```bash
make init
```

If you want to look in what is planned to be done:
```bash
make plan
```


Even after `make destroy args='-auto-approve'` it shows an VPC:
```bash
aws ec2 describe-vpcs
aws cloudformation list-stacks
```

```bash
aws ec2 describe-subnets | rg available
aws ec2 describe-subnets | rg SubnetId 
```

```bash
aws \
ec2 \
delete-subnet \
--subnet-id=subnet-10923666 \
--subnet-id=subnet-c7a5d598 \
--subnet-id=subnet-433c4162
```


```bash
#!/bin/bash
vpc="vpc-53f1722e" 
region="us-west-1"
aws ec2 describe-vpc-peering-connections --region $region --filters 'Name=requester-vpc-info.vpc-id,Values='$vpc | grep VpcPeeringConnectionId
aws ec2 describe-nat-gateways --region $region --filter 'Name=vpc-id,Values='$vpc | grep NatGatewayId
aws ec2 describe-instances --region $region --filters 'Name=vpc-id,Values='$vpc | grep InstanceId
aws ec2 describe-vpn-gateways --region $region --filters 'Name=attachment.vpc-id,Values='$vpc | grep VpnGatewayId
aws ec2 describe-network-interfaces --region $region --filters 'Name=vpc-id,Values='$vpc | grep NetworkInterfaceId

aws cloudformation list-stacks | grep StackStatus

aws ec2 describe-internet-gateways
aws ec2 describe-subnets | grep SubnetId
aws ec2 describe-vpcs

aws resourcegroupstaggingapi get-resources --region us-west-1
```
Refs.:
- https://serverfault.com/a/1010868
- https://aws.amazon.com/premiumsupport/knowledge-center/troubleshoot-dependency-error-delete-vpc/
- https://serverfault.com/a/747868


```bash
aws ec2 detach-internet-gateway --internet-gateway-id=igw-1e887e64 --vpc-id=vpc-53f1722e
aws ec2 delete-internet-gateway --internet-gateway-id=igw-1e887e64
aws ec2 delete-vpc --vpc-id=vpc-e2087c86
```
