#!/bin/bash



# TODO: check if the instance size is related to reproducibility of the bug
#  It blows up if it is not set to /tmp, the size of ~/tmp is too small
# export TMPDIR='/tmp'

# The nix official installer does not work for the root user, so
# it is a must to run as one user different from root user, 
# in this case, the ubuntu user, it comes from the ami-0ac80df6eff0e70b5
BASE_URL='https://raw.githubusercontent.com/ES-Nix/get-nix/' \
&& SHA256=61bc33388f399fd3de71510b5ca20f159c803491 \
&& NIX_RELEASE_VERSION='nix-2.4pre20210823_af94b54' \
&& su ubuntu -c 'curl -fsSL '"${BASE_URL}""$SHA256"'/get-nix.sh' | su ubuntu -c 'sh -s -- '${NIX_RELEASE_VERSION}


# sudo apt-get update \
# && sudo apt-get upgrade -y \
# && sudo apt-get install -y haproxy

#apt-get update
#apt-get install -y apt-transport-https ca-certificates curl
#
#echo 'Start docker installation...' \
#&& curl -fsSL https://get.docker.com | sh \
#&& getent group docker || groupadd docker \
#&& usermod --append --groups docker "$USER" \
#&& docker --version
#
#cat <<EOF | tee /etc/docker/daemon.json
#{
#    "exec-opts": ["native.cgroupdriver=systemd"]
#}
#EOF
#echo 'End docker installation!'
#
#
#curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
#echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list
#
#apt-get update
#apt-get install -y kubelet kubeadm kubectl
#apt-mark hold kubelet kubeadm kubectl
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
#sed \
#-i \
#'s/^GRUB_CMDLINE_LINUX="/&swapaccount=0/' \
#/etc/default/grub \
#&& grub-mkconfig -o /boot/grub/grub.cfg
#
#echo 'vm.swappiness = 0' | tee -a /etc/sysctl.conf
#
## TODO: document it
#ufw allow 6443

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
