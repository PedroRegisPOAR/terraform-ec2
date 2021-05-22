#!/bin/bash


test -d '/nix' || sudo mkdir --mode=0755 '/nix'
chown 'ubuntu':'ubuntu' '/nix'

# It blows up if it is not set to /tmp, the size of ~/tmp is too small
export TMPDIR='/tmp'

# The nix official installer does not work for the root user, so
# is need to run as the ubuntu user
su ubuntu -c 'curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/21592dddb73b3dd96cb89ff29da31886ed7fa578/get-nix.sh | sh'

chown 'ubuntu':'ubuntu' --recursive '/home/ubuntu' '/nix'


#mkdir -p /home/nixuser
#echo 'nixuser:x:12345:6789::/home/nixuser:/bin/bash' >> /etc/passwd
#echo 'nixgroup:x:6789:' >> /etc/group
#echo "nixuser:123" | chpasswd
#
#chmod 0700 /home/nixuser
#chown 'nixuser':'nixgroup' --recursive '/home/nixuser'
#
#mkdir 0755 /run/user/12345
#chown 'nixuser':'nixgroup' /run/user/12345
#
#mkdir --mode=0755 '/nix'
#chown 'nixuser':'nixgroup' '/nix'
#
#
#echo 'nixuser:100000:65536' >> /etc/subuid
#echo 'nixgroup:100000:65536' >> /etc/subgid

# export XDG_RUNTIME_DIR=/run/user/$(id -u)
# getcap /nix/store/*-shadow-4.8.1/bin/new?idmap
# setcap cap_setuid+ep /nix/store/*-shadow-4.8.1/bin/newuidmap
# setcap cap_setgid+ep /nix/store/*-shadow-4.8.1/bin/newgidmap



# Old
#su ubuntu -c 'env > /home/ubuntu/env.log'
#su ubuntu -c 'nix --version > /home/ubuntu/out.log'
#su ubuntu -c 'nix-shell -I nixpkgs=channel:nixos-20.09 --packages nixFlakes --run id > log.log'
#nix-shell \
#-I nixpkgs=channel:nixos-20.09 \
#--packages \
#nixFlakes \
#--run \
#'nix develop github:ES-Nix/nix-flakes-shellHook-writeShellScriptBin-defaultPackage/65e9e5a64e3cc9096c78c452b51cc234aa36c24f --command id'

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
