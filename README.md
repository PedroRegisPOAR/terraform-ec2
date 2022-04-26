# terraform-ec2




If you use `nix-direnv` + `direnv`, just `cd` into the project cloned folder. 

```bash
nix develop .#
```

```bash
aws configure
```

```bash
aws ec2 describe-regions
```

TODO: check if it is needed in the first time
```bash
make init
```

```bash
make plan
```


```bash
make destroy args='-auto-approve' \
&& make apply args='-auto-approve' \
&& TERRAFORM_OUTPUT_PUBLIC_IP="$(terraform output ec2_instance_public_ip)" \
&& sleep 30 \
&& ssh \
    ubuntu@"${TERRAFORM_OUTPUT_PUBLIC_IP}" \
    -i ~/.ssh/my-ec2.pem \
    -o StrictHostKeyChecking=no
```

Even after `make destroy args='-auto-approve'` it shows an VPC:
```bash
aws ec2 describe-vpcs
aws cloudformation list-stacks
```
Why?


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
- https://youtu.be/TqMKBIinjew?t=782
- https://www.weave.works/docs/net/latest/kubernetes/kube-addon/#-installation



#### Installs kubernetes with nix


```bash
nix \
profile \
install \
nixpkgs#cni \
nixpkgs#cni-plugins \
nixpkgs#conntrack-tools \
nixpkgs#cri-o \
nixpkgs#cri-tools \
nixpkgs#docker \
nixpkgs#ebtables \
nixpkgs#flannel \
nixpkgs#kubernetes \
nixpkgs#socat \
&& sudo cp "$(nix eval --raw nixpkgs#docker)"/etc/systemd/system/{docker.service,docker.socket} /etc/systemd/system/ \
&& getent group docker || sudo groupadd docker \
&& sudo usermod --append --groups docker "$USER" \
&& sudo systemctl enable --now docker

echo 'Start bypass sudo stuff...' \
&& NIX_CNI_PATH="$(nix eval --raw nixpkgs#cni)"/bin \
&& NIX_CNI_PLUGINS_PATH="$(nix eval --raw nixpkgs#cni-plugins)"/bin \
&& NIX_FLANNEL_PATH="$(nix eval --raw nixpkgs#flannel)"/bin \
&& NIX_CRI_TOOLS_PATH="$(nix eval --raw nixpkgs#cri-tools)"/bin \
&& NIX_EBTABLES_PATH="$(nix eval --raw nixpkgs#ebtables)"/bin \
&& NIX_SOCAT_PATH="$(nix eval --raw nixpkgs#socat)"/bin \
&& CONNTRACK_NIX_PATH="$(nix eval --raw nixpkgs#conntrack-tools)/bin" \
&& DOCKER_NIX_PATH="$(nix eval --raw nixpkgs#docker)/bin" \
&& KUBERNETES_BINS_NIX_PATH="$(nix eval --raw nixpkgs#kubernetes)/bin" \
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

nix store gc --verbose \
&& nix store optimise --verbose

# sudo su
echo 'kube-master' | sudo tee /etc/hostname
sudo hostname kube-master

sudo reboot
```
Refs.:
- https://stackoverflow.com/a/66940710
- https://askubuntu.com/a/463283
- https://github.com/NixOS/nixpkgs/issues/70407
- https://github.com/moby/moby/tree/e9ab1d425638af916b84d6e0f7f87ef6fa6e6ca9/contrib/init/systemd


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


