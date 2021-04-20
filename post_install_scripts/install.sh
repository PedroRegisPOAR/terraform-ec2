#!/bin/bash


test -d '/nix' || sudo mkdir --mode=0755 '/nix'
chown 'ubuntu':'ubuntu' '/nix'

export TMPDIR='/tmp'

su ubuntu -c 'curl -fsSL https://raw.githubusercontent.com/ES-Nix/get-nix/288cc322ea5e925d993eb654667ceaa607575a38/get-nix.sh | sh'

chown 'ubuntu':'ubuntu' --recursive '/home/ubuntu'


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
