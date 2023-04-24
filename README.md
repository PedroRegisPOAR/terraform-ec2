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
output = json
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
&& make apply args='-auto-approve' \
&& TERRAFORM_OUTPUT_PUBLIC_IP="$(terraform output ec2_instance_public_ip)" \
&& while ! nc -t -w 1 -z "${TERRAFORM_OUTPUT_PUBLIC_IP}" 22; do echo $(date +'%d/%m/%Y %H:%M:%S:%3N'); sleep 0.5; done \
&& ssh \
    ubuntu@"${TERRAFORM_OUTPUT_PUBLIC_IP}" \
    -i ~/.ssh/my-ec2.pem \
    -o StrictHostKeyChecking=no \
    -o StrictHostKeyChecking=accept-new
```



```bash
TERRAFORM_OUTPUT_PUBLIC_IP="$(terraform output ec2_instance_public_ip)" \
&& while ! nc -t -w 1 -z "${TERRAFORM_OUTPUT_PUBLIC_IP}" 22; do echo $(date +'%d/%m/%Y %H:%M:%S:%3N'); sleep 0.5; done \
&& ssh \
    ubuntu@"${TERRAFORM_OUTPUT_PUBLIC_IP}" \
    -i ~/.ssh/my-ec2.pem \
    -o StrictHostKeyChecking=no \
    -o StrictHostKeyChecking=accept-new
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

Not working:
```bash
aws ec2 describe-subnets \
| rg SubnetId \
| cut -d '"' -f4 \
| xargs -I{} \
   aws \
   ec2 \
   delete-subnet \
   --subnet-id={}
```

```bash
aws ec2 describe-vpcs | jq '.[][].VpcId'
```


```bash
#!/bin/bash

vpc="vpc-008db271b63154912" 
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

aws resourcegroupstaggingapi get-resources --region $region
```
Refs.:
- https://serverfault.com/a/1010868
- https://aws.amazon.com/premiumsupport/knowledge-center/troubleshoot-dependency-error-delete-vpc/
- https://serverfault.com/a/747868



```bash
aws ec2 describe-vpcs | jq '.[][].VpcId' \
| xargs -I{} \
  aws ec2 delete-vpc --vpc-id={}
```


```bash
vpc="vpc-008db271b63154912" 
region="us-west-1"

igw="igw-0281f2419ad263c7d"

aws ec2 detach-internet-gateway --internet-gateway-id=$igw --vpc-id=$vpc
aws ec2 delete-internet-gateway --internet-gateway-id=$igw
aws ec2 delete-vpc --vpc-id=$vpc
```

```bash
aws \
ec2 \
delete-network-interface \
--network-interface-id=eni-0f4b3313ec323350b
```

#### Install nix?

https://github.com/ES-Nix/get-nix/tree/draft-in-wip#single-user

TODO: 
- The `key_name` (`my-ec2.pem`) needs some manual work.
- Explain all steps need to make it work
- Change the sleep 30 with some "smarter logic of retry" 

References

- https://learn.hashicorp.com/tutorials/terraform/module-use


## Cluster, instance_count = 3



```bash
make destroy args='-auto-approve' \
&& make apply args='-auto-approve' \
&& TERRAFORM_OUTPUT_PUBLIC_IP_0="$(terraform output ec2_instance_public_ip_0)" \
&& TERRAFORM_OUTPUT_PUBLIC_IP_1="$(terraform output ec2_instance_public_ip_1)" \
&& TERRAFORM_OUTPUT_PUBLIC_IP_2="$(terraform output ec2_instance_public_ip_2)" \
&& sleep 30 \
&& ssh \
    ubuntu@"${TERRAFORM_OUTPUT_PUBLIC_IP_0}" \
    -i ~/.ssh/my-ec2.pem \
    -o StrictHostKeyChecking=no
```



```bash
sudo su
echo 'kube-master' > /etc/hostname
hostname kube-master
```

```bash
sudo su
echo 'kube-worker-1' > /etc/hostname
hostname kube-worker-1
exit 0
exit 0
```

```bash
sudo su
echo 'kube-worker-2' > /etc/hostname
hostname kube-worker-2
exit 0
exit 0

```
Adapted from: https://www.youtube.com/watch?v=TqMKBIinjew&t=141s


```bash
mkdir -p "${HOME}"/.kube
sudo cp -i /etc/kubernetes/admin.conf "${HOME}"/.kube/config
sudo chown "$(id -u)":"$(id -g)" "${HOME}"/.kube/config
```
From: 
- [Instalando Cluster Kubernetes do ZERO](https://youtu.be/TqMKBIinjew?t=782), t=782
- https://www.weave.works/docs/net/latest/kubernetes/kube-addon/#-installation



#### Kubernetes single main node (control plane) and stacked etcd, all from apt


Be sure that you have reboot if you are starting from scratch.

After the reboot:
```bash
TERRAFORM_OUTPUT_PUBLIC_IP="$(terraform output ec2_instance_public_ip)" \
&& while ! nc -t -w 1 -z "${TERRAFORM_OUTPUT_PUBLIC_IP}" 22; do echo $(date +'%d/%m/%Y %H:%M:%S:%3N'); sleep 0.5; done \
&& ssh \
    ubuntu@"${TERRAFORM_OUTPUT_PUBLIC_IP}" \
    -i ~/.ssh/my-ec2.pem \
    -o StrictHostKeyChecking=no
```

```bash
# sudo kubeadm config images pull
# sudo kubeadm config images list

sudo kubeadm init --pod-network-cidr=10.244.0.0/16 \
&& echo 'End of kubeadm init --pod-network-cidr=10.244.0.0/16' \
&& mkdir -pv "$HOME"/.kube \
&& sudo cp -fv /etc/kubernetes/admin.conf "$HOME"/.kube/config \
&& sudo chown -v $(id -u):$(id -g) "$HOME"/.kube/config \
&& sleep 5 \
&& while ! nc -t -w 1 -z localhost 6443; do echo $(date +'%d/%m/%Y %H:%M:%S:%3N'); sleep 0.5; done \
&& kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml \
&& watch --interval=1  kubectl get pods -A
```
Refs.:
- https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/


For some reason, for now, you must run:
```bash
sed -i -e 's/v1alpha1/v1beta1/' ~/.kube/config
```
From: https://stackoverflow.com/a/71470764

#### Installs kubernetes with nix


```bash
nix \
profile \
install \
github:NixOS/nixpkgs/51d859cdab1ef58755bd342d45352fc607f5e59b#cni \
github:NixOS/nixpkgs/51d859cdab1ef58755bd342d45352fc607f5e59b#cni-plugins \
github:NixOS/nixpkgs/51d859cdab1ef58755bd342d45352fc607f5e59b#conntrack-tools \
github:NixOS/nixpkgs/51d859cdab1ef58755bd342d45352fc607f5e59b#cri-o \
github:NixOS/nixpkgs/51d859cdab1ef58755bd342d45352fc607f5e59b#cri-tools \
github:NixOS/nixpkgs/51d859cdab1ef58755bd342d45352fc607f5e59b#docker \
github:NixOS/nixpkgs/51d859cdab1ef58755bd342d45352fc607f5e59b#ebtables \
github:NixOS/nixpkgs/51d859cdab1ef58755bd342d45352fc607f5e59b#flannel \
github:NixOS/nixpkgs/51d859cdab1ef58755bd342d45352fc607f5e59b#kubernetes \
github:NixOS/nixpkgs/51d859cdab1ef58755bd342d45352fc607f5e59b#socat \
&& sudo cp "$(nix eval --raw github:NixOS/nixpkgs/51d859cdab1ef58755bd342d45352fc607f5e59b#docker)"/etc/systemd/system/{docker.service,docker.socket} /etc/systemd/system/ \
&& getent group docker || sudo groupadd docker \
&& sudo usermod --append --groups docker "$USER" \
&& sudo systemctl enable --now docker

echo 'Start bypass sudo stuff...' \
&& NIX_CNI_PATH="$(nix eval --raw github:NixOS/nixpkgs/51d859cdab1ef58755bd342d45352fc607f5e59b#cni)"/bin \
&& NIX_CNI_PLUGINS_PATH="$(nix eval --raw github:NixOS/nixpkgs/51d859cdab1ef58755bd342d45352fc607f5e59b#cni-plugins)"/bin \
&& NIX_FLANNEL_PATH="$(nix eval --raw github:NixOS/nixpkgs/51d859cdab1ef58755bd342d45352fc607f5e59b#flannel)"/bin \
&& NIX_CRI_TOOLS_PATH="$(nix eval --raw github:NixOS/nixpkgs/51d859cdab1ef58755bd342d45352fc607f5e59b#cri-tools)"/bin \
&& NIX_EBTABLES_PATH="$(nix eval --raw github:NixOS/nixpkgs/51d859cdab1ef58755bd342d45352fc607f5e59b#ebtables)"/bin \
&& NIX_SOCAT_PATH="$(nix eval --raw github:NixOS/nixpkgs/51d859cdab1ef58755bd342d45352fc607f5e59b#socat)"/bin \
&& CONNTRACK_NIX_PATH="$(nix eval --raw github:NixOS/nixpkgs/51d859cdab1ef58755bd342d45352fc607f5e59b#conntrack-tools)/bin" \
&& DOCKER_NIX_PATH="$(nix eval --raw github:NixOS/nixpkgs/51d859cdab1ef58755bd342d45352fc607f5e59b#docker)/bin" \
&& KUBERNETES_BINS_NIX_PATH="$(nix eval --raw github:NixOS/nixpkgs/51d859cdab1ef58755bd342d45352fc607f5e59b#kubernetes)/bin" \
&& echo 'Defaults    secure_path = /sbin:/bin:/usr/sbin:/usr/bin:'"$KUBERNETES_BINS_NIX_PATH"':'"$DOCKER_NIX_PATH"':'"$CONNTRACK_NIX_PATH"':'"$NIX_CNI_PLUGINS_PATH"':'"$NIX_CRI_TOOLS_PATH"':'"$NIX_EBTABLES_PATH"':'"$NIX_SOCAT_PATH"':'"$NIX_FLANNEL_PATH"':'"$NIX_CNI_PATH"  | sudo tee -a /etc/sudoers.d/"$USER" \
&& echo 'End bypass sudo stuff...'


KUBERNETES_BINS_NIX_PATH="$(nix eval --raw nixpkgs#kubernetes)/bin"
cat <<EOF | sudo tee /etc/systemd/system/kubelet.service
# /lib/systemd/system/kubelet.service
[Unit]
Description=kubelet: The Kubernetes Node Agent
Documentation=https://kubernetes.io/docs/home/
Wants=network-online.target
After=network-online.target

[Service]
ExecStart="$KUBERNETES_BINS_NIX_PATH"/kubelet
Restart=always
StartLimitInterval=0
RestartSec=10

[Install]
WantedBy=multi-user.target

# /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
# Note: This dropin only works with kubeadm and kubelet v1.11+
[Service]
Environment="KUBELET_KUBECONFIG_ARGS=--bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf"
Environment="KUBELET_CONFIG_ARGS=--config=/var/lib/kubelet/config.yaml"
# This is a file that "kubeadm init" and "kubeadm join" generates at runtime, populating the KUBELET_KUBEADM_ARGS variable dynamically
EnvironmentFile=-/var/lib/kubelet/kubeadm-flags.env
# This is a file that the user can use for overrides of the kubelet args as a last resort. Preferably, the user should use
# the .NodeRegistration.KubeletExtraArgs object in the configuration files instead. KUBELET_EXTRA_ARGS should be sourced from this file.
EnvironmentFile=-/etc/default/kubelet
ExecStart=
ExecStart="$KUBERNETES_BINS_NIX_PATH"/kubelet \$KUBELET_KUBECONFIG_ARGS \$KUBELET_CONFIG_ARGS \$KUBELET_KUBEADM_ARGS \$KUBELET_EXTRA_ARGS
EOF

cat <<EOF | sudo tee /etc/docker/daemon.json
{
    "exec-opts": ["native.cgroupdriver=systemd"]
}
EOF

sudo systemctl enable --now kubelet

cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sudo sysctl --system

sudo \
    sed \
    --in-place \
    's/^GRUB_CMDLINE_LINUX="/&swapaccount=0/' \
    /etc/default/grub \
&& sudo grub-mkconfig -o /boot/grub/grub.cfg

echo 'vm.swappiness = 0' | sudo tee -a /etc/sysctl.conf

#nix store gc --verbose \
#&& nix store optimise --verbose

# sudo su
echo 'k8s-single-main-node' | sudo tee /etc/hostname
sudo hostname k8s-single-main-node

sudo reboot
```
Refs.:
- https://stackoverflow.com/a/66940710
- https://askubuntu.com/a/463283
- https://github.com/NixOS/nixpkgs/issues/70407
- https://github.com/moby/moby/tree/e9ab1d425638af916b84d6e0f7f87ef6fa6e6ca9/contrib/init/systemd


```bash
# sudo kubeadm config images pull
# sudo kubeadm config images list

sudo kubeadm init --pod-network-cidr=192.168.0.0/16 \
&& mkdir -p "${HOME}"/.kube \
&& sudo cp -i /etc/kubernetes/admin.conf "${HOME}"/.kube/config \
&& sudo chown "$(id -u)":"$(id -g)" "${HOME}"/.kube/config \
&& sleep 5 \
&& while ! nc -t -w 1 -z localhost 6443; do echo $(date +'%d/%m/%Y %H:%M:%S:%3N'); sleep 0.5; done \
&& kubectl \
    create \
      -f https://docs.projectcalico.org/manifests/tigera-operator.yaml \
      -f https://docs.projectcalico.org/manifests/custom-resources.yaml \
&& watch --interval=1 kubectl get pods -A
```

```bash
kubectl delete all --all --all-namespaces
```

```bash
systemctl list-units --full --all | grep kub
```

```bash
echo 'kube-worker-1' | sudo tee /etc/hostname
sudo hostname 'kube-worker-1'

sudo reboot
```

```bash
echo 'kube-worker-2' | sudo tee /etc/hostname
sudo hostname 'kube-worker-2'

sudo reboot
```

```bash
sudo kubeadm config images pull
sudo kubeadm config images list
sudo kubeadm init --pod-network-cidr=192.168.0.0/16

mkdir -p "${HOME}"/.kube
sudo cp -i /etc/kubernetes/admin.conf "${HOME}"/.kube/config
sudo chown "$(id -u)":"$(id -g)" "${HOME}"/.kube/config

kubectl create -f https://docs.projectcalico.org/manifests/tigera-operator.yaml
kubectl create -f https://docs.projectcalico.org/manifests/custom-resources.yaml

watch --interval=1 kubectl get pods -A
```

```bash
kubeadm \
join \
10.1.11.221:6443 \
--token ecpgjl.eq8wozo49hjqvmy2 \
--discovery-token-ca-cert-hash \
sha256:3a6f3c7fa2e970990a1e0f2565d36c82b1415389c186408aa32a14101aefb5ed
```


```bash
# sudo kubeadm init
sudo kubeadm init --pod-network-cidr=10.244.0.0/16

mkdir -p "${HOME}"/.kube
sudo cp -i /etc/kubernetes/admin.conf "${HOME}"/.kube/config
sudo chown "$(id -u)":"$(id -g)" "${HOME}"/.kube/config

sudo kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

watch --interval=1 kubectl get pods -A
```


### Cluster with 5 nodes, 2 masters 3 workers

```bash
make destroy args='-auto-approve' \
&& make apply args='-auto-approve'
```

```bash
TERRAFORM_OUTPUT_PUBLIC_IP_0="$(terraform output ec2_instance_public_ip_0)"
ssh \
    ubuntu@"${TERRAFORM_OUTPUT_PUBLIC_IP_0}" \
    -i ~/.ssh/my-ec2.pem \
    -o StrictHostKeyChecking=no \
<< HERE
echo 'kube-master-0' | sudo tee /etc/hostname
sudo hostname 'kube-master-0'

sudo reboot
HERE
```

```bash
TERRAFORM_OUTPUT_PUBLIC_IP_1="$(terraform output ec2_instance_public_ip_1)"
ssh \
    ubuntu@"${TERRAFORM_OUTPUT_PUBLIC_IP_1}" \
    -i ~/.ssh/my-ec2.pem \
    -o StrictHostKeyChecking=no \
<< HERE
echo 'kube-master-1' | sudo tee /etc/hostname
sudo hostname 'kube-master-1'

sudo reboot
HERE
```

```bash
TERRAFORM_OUTPUT_PUBLIC_IP_2="$(terraform output ec2_instance_public_ip_2)"
ssh \
    ubuntu@"${TERRAFORM_OUTPUT_PUBLIC_IP_2}" \
    -i ~/.ssh/my-ec2.pem \
    -o StrictHostKeyChecking=no \
<< HERE
echo 'kube-worker-1' | sudo tee /etc/hostname
sudo hostname 'kube-worker-1'

sudo reboot
HERE
```

```bash
TERRAFORM_OUTPUT_PUBLIC_IP_3="$(terraform output ec2_instance_public_ip_3)"
ssh \
    ubuntu@"${TERRAFORM_OUTPUT_PUBLIC_IP_3}" \
    -i ~/.ssh/my-ec2.pem \
    -o StrictHostKeyChecking=no \
<< HERE
echo 'kube-worker-2' | sudo tee /etc/hostname
sudo hostname 'kube-worker-2'

sudo reboot
HERE
```


```bash
TERRAFORM_OUTPUT_PUBLIC_IP_4="$(terraform output ec2_instance_public_ip_4)"
ssh \
    ubuntu@"${TERRAFORM_OUTPUT_PUBLIC_IP_4}" \
    -i ~/.ssh/my-ec2.pem \
    -o StrictHostKeyChecking=no \
<< HERE
echo 'kube-worker-3' | sudo tee /etc/hostname
sudo hostname 'kube-worker-3'

sudo reboot
HERE
```


```bash

TERRAFORM_OUTPUT_PUBLIC_IP_0="$(terraform output ec2_instance_public_ip_0)"
ssh \
    ubuntu@"${TERRAFORM_OUTPUT_PUBLIC_IP_0}" \
    -i ~/.ssh/my-ec2.pem \
    -o StrictHostKeyChecking=no \
<< HERE
echo 'loadbalancer' | sudo tee /etc/hostname
sudo hostname 'loadbalancer'

sudo reboot
HERE

TERRAFORM_OUTPUT_PUBLIC_IP_0="$(terraform output ec2_instance_public_ip_0)"
ssh \
    ubuntu@"${TERRAFORM_OUTPUT_PUBLIC_IP_0}" \
    -i ~/.ssh/my-ec2.pem \
    -o StrictHostKeyChecking=no \
<< HERE
sudo apt-get update \
&& sudo apt-get upgrade -y \
&& sudo apt-get install -y haproxy
HERE
```

cat << EOF | sudo tee -a /etc/haproxy/haproxy.cfg
frontend fe-apiserver
   bind 54.242.94.244:6443
   mode tcp
   option tcplog
   default_backend be-apiserver
EOF

echo 'TERRAFORM_OUTPUT_PUBLIC_IP_1='"${TERRAFORM_OUTPUT_PUBLIC_IP_1}"
echo 'TERRAFORM_OUTPUT_PUBLIC_IP_2='"${TERRAFORM_OUTPUT_PUBLIC_IP_2}"


cat << EOF | sudo tee -a /etc/haproxy/haproxy.cfg
backend be-apiserver
   mode tcp
   option tcplog
   option tcp-check
   balance roundrobin
   default-server inter 10s downinter 5s rise 2 fall 2 slowstart 60s maxconn 250 maxqueue 256 weight 100

   server kube-master-0 "${TERRAFORM_OUTPUT_PUBLIC_IP_0}":6443 check
   server kube-master-1 "${TERRAFORM_OUTPUT_PUBLIC_IP_1}":6443 check
EOF

```bash
sudo \
kubeadm \
init \
--control-plane-endpoint "${TERRAFORM_OUTPUT_PUBLIC_IP_0}:6443" \
--upload-certs \
--pod-network-cidr=192.168.0.0/16 
```

```bash
# sudo kubeadm init --pod-network-cidr=10.244.0.0/16
sudo kubeadm init --upload-certs --pod-network-cidr=10.244.0.0/16

mkdir -p "${HOME}"/.kube
sudo cp -i /etc/kubernetes/admin.conf "${HOME}"/.kube/config
sudo chown "$(id -u)":"$(id -g)" "${HOME}"/.kube/config

sudo kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

watch --interval=1 kubectl get pods -A
```


```bash
CERTIFICATE_KEY="$(sudo kubeadm init phase upload-certs --upload-certs | sed '3q;d')"

sudo \
kubeadm \
token \
create \
--certificate-key "${CERTIFICATE_KEY}" \
--print-join-command | sed 's/ / \\\n/g'
```

```bash
# If the node to be joint is an "main node" 
kubeadm \
join \
10.1.11.178:6443 \
--token \
y0r6tx.otqw15eg1zed3mn0 \
--discovery-token-ca-cert-hash \
sha256:6fd0cfc9abb714558b795002b722ab77a8122d95e3d8604f516fc32262b87cfd \
--control-plane \
--certificate-key \
464e4087ae879d8c0cc0e18312fcae01f822bd9e6746e2c1d2eb813ebc9d68f4

# If the node to be joint is an "worker node" the flags --control-plane and --certificate-key
# are not needed. 
kubeadm \
join \
10.1.11.178:6443 \
--token \
y0r6tx.otqw15eg1zed3mn0 \
--discovery-token-ca-cert-hash \
sha256:6fd0cfc9abb714558b795002b722ab77a8122d95e3d8604f516fc32262b87cfd
```


#### Troubleshooting


```bash
openssl x509 -in /etc/kubernetes/pki/ca.crt -noout -pubkey \
| openssl rsa -pubin -outform DER 2>/dev/null \
| sha256sum \
| cut -d' ' -f1

openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt \
| openssl rsa -pubin -outform der 2>/dev/null \
| openssl dgst -sha256 -hex \
| sed 's/^.* //'

kubeadm token list

sudo ufw status

netstat -tnlp

kubectl cluster-info

nc -zv 10.1.11.178 6443
nc -zv 10.1.11.178 22
```


### Creating cluster with eksctl


Some sanity check:
```bash
eksctl version
kubectl version
aws-iam-authenticator version
```


```bash
#eksctl \
#create \
#cluster \
#--name test-eks-cluster \
#--version 1.21 \
#--region us-east-1 \
#--nodegroup-name linux-nodes-for-eks \
#--node-type t2.medium \
#--nodes 3
```

```bash
eksctl \
create \
cluster \
--name test-eks-cluster \
--version 1.21 \
--region us-east-1 \
--nodegroup-name linux-nodes-for-eks \
--node-type t2.medium \
--nodes 2 \
--nodes-min 1 \
--nodes-max 3 \
--ssh-access \
--ssh-public-key ~/.ssh/id_rsa.pub
```
Adapted from: 
- [AWS EKS | Create EKS Cluster on AWS using EKSCTL | Install Kubernetes on AWS](https://www.youtube.com/watch?v=QXzYIKZxxHc&t=56s)
- Adapted from: https://eksctl.io/usage/vpc-cluster-access/


For some reason, for now, you must run:
```bash
sed -i -e 's/v1alpha1/v1beta1/' ~/.kube/config
```
From: https://stackoverflow.com/a/71470764


```bash
kubectl get nodes

kubectl get ns

kubectl get svc
```

Getting the IPs: 
```bash
kubectl \
get \
nodes \
-o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'
```

```bash
ssh \
    ec2-user@3.239.70.128 \
    -i ~/.ssh/id_rsa \
    -o StrictHostKeyChecking=no
```


### Test creating a pod with an .yaml


```bash
cat << EOF > example.yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-pod
spec:
  containers:
  - name: test-pod
    image: busybox
    command: ['sh', '-c', 'echo The Bench Container 1 is Running ; sleep 100000']
EOF

kubectl create -f example.yaml
``` 

```bash

kubectl get pods

kubectl logs test-pod

kubectl get pods
kubectl exec test-pod -i -t -- /bin/sh -c ' ls -al /'

kubectl delete pod test-pod
rm -fv example.yaml
```


```bash
cat ~/.kube/config

apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUM1ekNDQWMrZ0F3SUJBZ0lCQURBTkJna3Foa2lHOXcwQkFRc0ZBREFWTVJNd0VRWURWUVFERXdwcmRXSmwKY201bGRHVnpNQjRYRFRJeU1EUXlOakl5TkRVME1Wb1hEVE15TURReU16SXlORFUwTVZvd0ZURVRNQkVHQTFVRQpBeE1LYTNWaVpYSnVaWFJsY3pDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUJBT2F4ClM0aXhlK002RXh1S09JTEs1TTZmSllTT3phU2lnVG5NSmlGRTJ5ZTZQQ1NxanI0Sk9LeGNKMWNla245SmdKSloKVEV3V29XdFVXYlJFTFVkSGlTVlFkMm1lWVVPUXU0ZktpNVB1SjFVbjlJRnZHcmc0dkY0L2hVSkxSWU1BdHdNeApCT1g4bm1MdUYyMjg2TmFEU0l4MWV3WXpRUm43aENRRFlYam5sWldmR0NJaWsvTHVmcWpTUVg0UnhCM253SjZqCnJXU0E5MUZvSlVrNnJRSEhKVGh5MjJhbXZnYkVQWDUwcUV3TnhCQ2lFWGptNFNlMzlqOWxrS1ZDd1g0UkllMkUKMkFibGR0NFVLK3JkalRBVEx1cjJld2JKSjJZMGtCVVZqRUlXcURvMlRVU2tXRjZDOXNpTzZNL3ozc2IvRmYrRwo3SG5FOTR0ZW10T245YThvRXgwQ0F3RUFBYU5DTUVBd0RnWURWUjBQQVFIL0JBUURBZ0trTUE4R0ExVWRFd0VCCi93UUZNQU1CQWY4d0hRWURWUjBPQkJZRUZDTEo0ZVMwRjJ2bG96RXhTa1c5elhlbWp1MHNNQTBHQ1NxR1NJYjMKRFFFQkN3VUFBNElCQVFBQldmc3d0Q2lMOVB6RzlVaERBbUxhREw4bmRnVmJKNDRvRTV0YkNrZkc1aXIwcGVkdgpnVUNMQysvb01wVjRRdHZtc05WczRZRWwwVjdmYkJNN21RNUhuMTlnVDZRZGtYZUxDVVJuMkxyQXllWW84NGlUClcxMHh6NlNPb1czWEs3bkJpQjhtRHFaZUo0K0tOaExJdWZIdmEzQUV4L0t0ZTFQQmkyNXJlZU16RlpYUWlRNEgKMkhKTmI3ckM4KzFVQTBrUUpTeTB2TXYyRFZKTFhVd2QzS1pVNlFYQnV6STFYV3VtSHBvYXByeGtUcVJOUFFkWgo5UTFlTWJESFRxVnBnMHRPNzNBZHFaMG11WnNYbEd0SWNzTE13Wlc4QTk5L1BlOG1rdHl4MkVTa1RjY2l5dWRkCnJvcmp6RXNKVDc0ejdLV3RROW9FWnJPTmtlNGFFYnJSbFJqQQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0tCg==
    server: https://A2E3806EF24C5A59799FD738B650B93D.gr7.us-east-1.eks.amazonaws.com
  name: test-eks-cluster.us-east-1.eksctl.io
contexts:
- context:
    cluster: test-eks-cluster.us-east-1.eksctl.io
    user: mynixuser@test-eks-cluster.us-east-1.eksctl.io
  name: mynixuser@test-eks-cluster.us-east-1.eksctl.io
current-context: mynixuser@test-eks-cluster.us-east-1.eksctl.io
kind: Config
preferences: {}
users:
- name: mynixuser@test-eks-cluster.us-east-1.eksctl.io
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      args:
      - token
      - -i
      - test-eks-cluster
      command: aws-iam-authenticator
      env:
      - name: AWS_STS_REGIONAL_ENDPOINTS
        value: regional
      - name: AWS_DEFAULT_REGION
        value: us-east-1
      provideClusterInfo: false
```


> If you encounter any issues, check CloudFormation console or try:
```bash
eksctl utils describe-stacks --region=us-east-1 --cluster=test-eks-cluster
```

Refs.
- [AWS EKS - Create Kubernetes cluster on Amazon EKS | the easy way](https://www.youtube.com/watch?v=p6xDCz00TxU)



### Cleaning and restart from scratch


```bash
eksctl \
delete \
cluster \
--name test-eks-cluster \
--wait
```
From: https://stackoverflow.com/a/60113741

> You can wait 10 mins and try to create your EKS cluster again,
> or you can choose to use a different cluster name.
From: https://www.ibm.com/docs/en/cloud-paks/cp-management/1.3.0?topic=management-creating-eks-cluster-fails-due-error-alreadyexistsexception



```bash
aws \
cloudformation \
delete-stack \
--stack-name eksctl-test-eks-cluster-cluster
```

```bash
rm -fr ~/.kube/
```

It was showing up:
```bash
aws cloudformation list-stacks | rg ROLLBACK_COMPLETE -A 4 -B 6
```

```bash
aws cloudformation list-stacks | rg StackStatus
```

```bash
aws cloudformation --region us-west-1 list-stacks
```

```bash
aws cloudformation --region us-west-1 list-stacks
```


#### Not needed

```bash
eksctl utils update-cluster-endpoints --name=<clustername> --private-access=true --public-access=false
```


```bash
apiVersion: v1
clusters: null
contexts: null
current-context: ""
kind: Config
preferences: {}
users: null
vpc:
  clusterEndpoints:
    publicAccess: true
    privateAccess: true
```



###


```bash
nix profile install nixpkgs#flutter
```


```bash
nix \
shell \
--impure \
nixpkgs#clang \
nixpkgs#cmake \
nixpkgs#flutter \
nixpkgs#ninja \
nixpkgs#pkg-config \
nixpkgs#gtk3.dev \
nixpkgs#util-linux.dev \
nixpkgs#glib.dev
```

```bash
sudo apt-get update \
&& sudo apt-get install -y \
  clang \
  cmake \
  ninja-build \
  pkg-config \
  gtk+-3 \
  libgtk-3-dev \
  liblzma-dev
```

```bash
sudo apt-get update \
&& sudo apt-get install -y \
    libgtk-3-dev
```

```bash
sudo apt install libblkid-dev
```

```bash
flutter config --enable-linux-desktop

flutter create my_app \
&& cd my_app \
&& flutter clean \
&& flutter build linux
```

```bash
pkg-config --variable pc_path pkg-config
```
From:
- https://stackoverflow.com/questions/50031080/pkg-config-cannot-find-gtk-3-0



```bash
nix \
store \
ls \
--store https://cache.nixos.org/ \
--long \
--recursive \
"$(nix eval --raw nixpkgs#gtk3.dev)"/lib/pkgconfig/
```


```bash
nix \
store \
cat \
--store https://cache.nixos.org/ \
"$(nix eval --raw nixpkgs#gtk3.dev)"/lib/pkgconfig/gtk+-3.0.pc
```


```bash
export PKG_CONFIG_PATH="$(nix eval --raw nixpkgs#gtk3.dev)/lib/pkgconfig:"

export PKG_CONFIG_PATH+="$(nix eval --raw nixpkgs#util-linux)/lib/pkgconfig:"
export PKG_CONFIG_PATH+="$(nix eval --raw nixpkgs#glib.dev)/lib/pkgconfig:"

export PKG_CONFIG_PATH+='/usr/local/lib/x86_64-linux-gnu/pkgconfig:'
export PKG_CONFIG_PATH+='/usr/local/lib/pkgconfig:'
export PKG_CONFIG_PATH+='/usr/local/share/pkgconfig:'
export PKG_CONFIG_PATH+='/usr/lib/x86_64-linux-gnu/pkgconfig:'
export PKG_CONFIG_PATH+='/usr/lib/pkgconfig:'
export PKG_CONFIG_PATH+='/usr/share/pkgconfig'

pkg-config --modversion gtk+-3.0
pkg-config --modversion glib-2.0
pkg-config --modversion gio-2.0
pkg-config --modversion blkid
```

Refs.:
- https://stackoverflow.com/questions/55547435/how-to-install-libgtk2-0-dev-on-nixos
- 

### 

```bash
sudo apt-get update \
&& sudo apt-get install -y \
make \
podman
```


sudo snap install android-studio --classic

sudo apt install default-jdk

```bash
test -d ~/.ssh || mkdir -pv ~/.ssh

nano ~/.ssh/id_rsa \
&& chmod 0600 ~/.ssh/id_rsa
```

```bash
git clone git@github.com:imobanco/income-back.git \
&& cd income-back \
&& make config.env \
&& make build \
&& make up.logs
```



###

```bash
nix shell nixpkgs#ascinema

asciinema rec demo"$(date +'%d-%m-%Y %H:%M:%S:%3N')".cast
```

```bash
sudo apt-get -qq -y update \
&& sudo sh -c 'apt-get install -y nix-bin' \
&& sudo nix run nixpkgs#qemu --extra-experimental-features 'nix-command flakes' -- --version
```

```bash
QEMU emulator version 7.0.0
Copyright (c) 2003-2022 Fabrice Bellard and the QEMU Project developers
```

```bash
sudo \
nix \
run \
nixpkgs#hello \
--extra-experimental-features 'nix-command flakes'
```


```bash
nix upgrade-nix
```
