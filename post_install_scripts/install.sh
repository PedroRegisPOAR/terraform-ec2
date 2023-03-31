#!/bin/bash


command -v curl || (command -v apt && apt-get update && apt-get install -y curl)


curl -fsSL https://get.docker.com | sh
usermod --append --groups docker ubuntu \
&& docker --version \
&& docker images

#su ubuntu -lc \
#'
#    NIX_RELEASE_VERSION=2.10.2 \
#    && curl -L https://releases.nixos.org/nix/nix-"${NIX_RELEASE_VERSION}"/install | sh -s -- --no-daemon
#    && . "$HOME"/.nix-profile/etc/profile.d/nix.sh
#
#    test -d "$HOME"/.profile || touch "$HOME"/.profile
#
#    echo ". \"$HOME\"/.nix-profile/etc/profile.d/nix.sh" >> "$HOME"/.profile
#    echo "export NIX_CONFIG=\"extra-experimental-features = nix-command flakes\"" >> "$HOME"/.profile
#'


# TODO: check if the instance size is related to reproducibility of the bug
#  It blows up if it is not set to /tmp the size of ~/tmp is too small
# export TMPDIR='/tmp'

# The nix official installer does not work for the root user so
# it is a must to run as one user different from root user 
# in this case the ubuntu user it comes from the ami-0ac80df6eff0e70b5
#BASE_URL='https://raw.githubusercontent.com/ES-Nix/get-nix/' \
#&& SHA256=45f3508bbadbc40a6e14b861c4ce4628680f1562 \
#&& NIX_RELEASE_VERSION='2.10.2' \
#&& su ubuntu -c 'curl -fsSL '"${BASE_URL}""$SHA256"'/get-nix.sh' | su ubuntu -c 'sh -s -- '${NIX_RELEASE_VERSION}
#


# sudo apt-get update \
# && sudo apt-get upgrade -y \
# && sudo apt-get install -y haproxy


#apt-get update
#sh -c 'apt-get install -y apt-transport-https ca-certificates'
#
## TODO: it has the user hardcoded! How to do it better?
#echo 'Start docker installation...' \
#&& curl -fsSL https://get.docker.com | sh \
#&& getent group docker || groupadd docker \
#&& usermod --append --groups docker ubuntu \
#&& docker --version
#
#cat <<EOF | tee /etc/docker/daemon.json
#{
#    "exec-opts": ["native.cgroupdriver=systemd"]
#}
#EOF
#echo 'End docker installation!'
#
## This bug still exist in 2022-05-06T19:25:40Z
## https://github.com/containerd/containerd/issues/4581
#rm /etc/containerd/config.toml
#systemctl restart containerd
#
## k8s
#curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
#echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
#
## From: https://v1-23.docs.kubernetes.io/docs/tasks/tools/install-kubectl-linux/#install-kubectl-binary-with-curl-on-linux
#curl -LO https://dl.k8s.io/release/v1.23.5/bin/linux/amd64/kubectl
#install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
#
#apt-get update
#sh -c 'apt-get install -y kubelet kubeadm'
#apt-mark hold kubelet kubeadm
#
#
#cat <<EOF | tee /etc/modules-load.d/k8s.conf
#br_netfilter
#EOF
#
#cat <<EOF | tee /etc/sysctl.d/k8s.conf
#net.bridge.bridge-nf-call-ip6tables = 1
#net.bridge.bridge-nf-call-iptables = 1
#EOF
#
## sysctl --system
#
#echo 'Start cgroup v2 instalation...' \
#&& mkdir -p /etc/systemd/system/user@.service.d \
#&& sh -c "echo '[Service]' >> /etc/systemd/system/user@.service.d/delegate.conf" \
#&& sh -c "echo 'Delegate=yes' >> /etc/systemd/system/user@.service.d/delegate.conf" \
#&& sed \
#--in-place \
#'s/^GRUB_CMDLINE_LINUX="/&swapaccount=0 systemd.unified_cgroup_hierarchy=1/' \
#/etc/default/grub \
#&& grub-mkconfig -o /boot/grub/grub.cfg \
#&& echo 'End cgroup v2 instalation...'
#
##sed \
##-i \
##'s/^GRUB_CMDLINE_LINUX="/&swapaccount=0/' \
##/etc/default/grub \
##&& grub-mkconfig -o /boot/grub/grub.cfg
#
#echo 'vm.swappiness = 0' | tee -a /etc/sysctl.conf
#
## TODO: document it
#ufw allow 6443
#
## Is a must to set an hostname?
## hostname 'k8s-single-master'
#
## TODO: document it
#reboot


#file_string=$(echo -e "$(cat <<"EOF"
#echo test
#EOF
#)")
#
#echo "$file_string" > /home/ubuntu/Makefile
#
#file_string=$(echo -e "$(cat <<"EOF"
##!/bin/bash
#
#EOF
#)")
#echo "$file_string" > /home/ubuntu/daily_cron.sh
#chmod +x /home/ubuntu/daily_cron.sh
