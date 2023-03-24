
## In the first time

Configuring the aws CLI:
```bash
test -d ~/.aws || mkdir -pv ~/.aws

cat > ~/.aws/credentials << 'EOF'
[default]
aws_access_key_id = YOUR_ACCESS_KEY_ID
aws_secret_access_key = YOUR_SECRET_ACCESS_KEY
EOF
```


### s3 bucket



#### Minimal Working Example of s3 bucket


```bash
cd bucket-nix-cache-test

test -d .terraform || make init

terraform apply -auto-approve

# terraform destroy -auto-approve
```


Testing it via CLI using `curl`:
```bash
curl -I https://playing-bucket-nix-cache-test.s3.amazonaws.com
```

Or just access the url: https://playing-bucket-nix-cache-test.s3.amazonaws.com


Sending some local file named `foo.txt` and with `abc` as the content:
```bash
# creating an specific file with known content
echo abc > foo.txt

# using the aws cli to copy the file to the bucket
aws s3 cp foo.txt s3://playing-bucket-nix-cache-test/
```

When you access, using some browser:
https://playing-bucket-nix-cache-test.s3.amazonaws.com/foo.txt

you should see the file contents, `abc` string.

Testing it via CLI using `aws`:
```bash
aws s3 cp s3://playing-bucket-nix-cache-test/foo.txt -
```


Testing it via CLI using `curl`:
```bash
curl https://playing-bucket-nix-cache-test.s3.amazonaws.com/foo.txt
```


WARNING: be carefull. Removing the bucket:
```bash
aws s3 rb s3://playing-bucket-nix-cache-test --force
```

So this is going to be empty:
```bash
aws s3 ls
```

TODO: how to remove only some files in the s3 bucket?


#### nix cache in s3 bucket



```bash
aws s3 cp nix-cache-info s3://playing-bucket-nix-cache-test/
```

How to print all the s3 bucket contents:
```bash
aws s3 cp s3://playing-bucket-nix-cache-test/nix-cache-info -
```
Refs.:
- https://stackoverflow.com/a/28390423

```bash
curl -I https://playing-bucket-nix-cache-test.s3.amazonaws.com/nix-cache-info
```


#### Sending GNU hello to a custom s3 binary cache


```bash
nix \
copy \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#hello \
--to 's3://playing-bucket-nix-cache-test'
```


```bash
nix \
store \
ls \
--store s3://playing-bucket-nix-cache-test/ \
--long \
--recursive \
$(nix eval --raw github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#hello)
```


```bash
NIXPKGS_ALLOW_INSECURE=1 \
&& nix \
shell \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/573603b7fdb9feb0eb8efc16ee18a015c667ab1b"; 
  with legacyPackages.${builtins.currentSystem};
  (openssl_1_1.overrideAttrs (oldAttrs: rec {
    src = fetchurl {
      url = https://www.openssl.org/source/old/1.1.1/openssl-1.1.1l.tar.gz;
      sha256 = "sha256-C3o+XlnDSCf+DDp0t+yLrvMCuY+oAIjX+RU6oW+na9E=";
    };
    configureFlags = (oldAttrs.configureFlags or "") ++ [ "-DOPENSSL_TLS_SECURITY_LEVEL=2" ]; 
  }))
)' \
--command \
bash \
-c \
"
(openssl version -f | grep -q -e '-DOPENSSL_TLS_SECURITY_LEVEL=2') || echo 'Not found flag -DOPENSSL_TLS_SECURITY_LEVEL=2'
openssl version -f | sed 's/ / \\ \n/g' | sed -e 1d | (sed -u 1q; sort)
"
```

```bash
nix \
build \
--impure \
--print-build-logs \
--option substituters 's3://playing-bucket-nix-cache-test/' \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/573603b7fdb9feb0eb8efc16ee18a015c667ab1b"; 
  with legacyPackages.${builtins.currentSystem};
  (openssl_1_1.overrideAttrs (oldAttrs: rec {
    src = fetchurl {
      url = https://www.openssl.org/source/old/1.1.1/openssl-1.1.1l.tar.gz;
      sha256 = "sha256-C3o+XlnDSCf+DDp0t+yLrvMCuY+oAIjX+RU6oW+na9E=";
    };
    configureFlags = (oldAttrs.configureFlags or "") ++ [ "-DOPENSSL_TLS_SECURITY_LEVEL=2" ]; 
  }))
)'
```



```bash
nix \
eval \
--raw \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/573603b7fdb9feb0eb8efc16ee18a015c667ab1b"; 
  with legacyPackages.${builtins.currentSystem};
  (openssl_1_1.overrideAttrs (oldAttrs: rec {
    src = fetchurl {
      url = https://www.openssl.org/source/old/1.1.1/openssl-1.1.1l.tar.gz;
      sha256 = "sha256-C3o+XlnDSCf+DDp0t+yLrvMCuY+oAIjX+RU6oW+na9E=";
    };
    configureFlags = (oldAttrs.configureFlags or "") ++ [ "-DOPENSSL_TLS_SECURITY_LEVEL=2" ]; 
  }))
)'
```


```bash
nix \
store \
ls \
--store s3://playing-bucket-nix-cache-test/ \
-lR \
$(nix \
eval \
--raw \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/573603b7fdb9feb0eb8efc16ee18a015c667ab1b"; 
  with legacyPackages.${builtins.currentSystem};
  (openssl_1_1.overrideAttrs (oldAttrs: rec {
    src = fetchurl {
      url = https://www.openssl.org/source/old/1.1.1/openssl-1.1.1l.tar.gz;
      sha256 = "sha256-C3o+XlnDSCf+DDp0t+yLrvMCuY+oAIjX+RU6oW+na9E=";
    };
    configureFlags = (oldAttrs.configureFlags or "") ++ [ "-DOPENSSL_TLS_SECURITY_LEVEL=2" ]; 
  }))
)')
```



```bash
nix \
run \
--impure \
--expr \
'(
  with builtins.getFlake "github:NixOS/nixpkgs/f0fa012b649a47e408291e96a15672a4fe925d65";
  with legacyPackages.${builtins.currentSystem};
  (pkgsStatic.hello.overrideAttrs
    (oldAttrs: {
        patchPhase = (oldAttrs.patchPhase or "") + "sed -i \"s/Hello, world!/hello, Nix!/g\" src/hello.c";
      }
    )
  )
)'
```

```bash
cat > flake.nix << 'EOF'
{
  description = "A very basic flake";

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

    packages.x86_64-linux.default = self.packages.x86_64-linux.hello;

  };
}
EOF

nix \
flake \
update \
--override-input nixpkgs github:NixOS/nixpkgs/e39a949aaa9e4fc652b1619b56e59584e1fc305b

# nix flake lock
git init && git add .

nix build -L '.#'

nix run '.#'
```

```bash
cat > flake.nix << 'EOF'
{
  description = "A very basic flake";

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux.hello = let
        overlay = final: prev: {
          hello = prev.hello.overrideAttrs (oldAttrs: {
            patchPhase = (oldAttrs.patchPhase or "") + "sed -i \"s/Hello, world!/hello, Nix!/g\" src/hello.c";
            # Test fail as the text was changed
            doCheck = false;
          });
        };

        pkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [ overlay ];
        };
      in
        pkgs.hello;

    packages.x86_64-linux.default = self.packages.x86_64-linux.hello;

  };
}
EOF

nix \
flake \
update \
--override-input nixpkgs github:NixOS/nixpkgs/e39a949aaa9e4fc652b1619b56e59584e1fc305b

# nix flake lock
git init && git add .

nix build -L '.#'

nix run '.#'
```





##### Signing 


```bash
aws s3 cp nix-cache-info s3://playing-bucket-nix-cache-test/
```

This is supposed to be done only once:
```bash
nix-store --generate-binary-cache-key playing-bucket-nix-cache-test cache-priv-key.pem cache-pub-key.pem

chown $USER cache-priv-key.pem \
&& chmod 600 cache-priv-key.pem
cat cache-pub-key.pem
```

On the machine with AWS credentials:
```bash
mkdir -p ~/slow-text
cd ~/slow-text

cat > flake.nix << 'EOF'
{
  description = "A very basic flake";

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux.slow-text = let
        overlay = final: prev: {
          slow-text = prev.stdenv.mkDerivation {
            name = "slow-text";
            buildPhase = "echo started building && sleep 30 && mkdir -pv $out && echo 18de53ca965bd0678aaf09e5ce0daae05c58355a >> $out/log.txt && sleep 30 && echo a55385c50eaad0ec5e90faa8760db569ac35ed81 >> $out/log.txt";
            dontInstall = true;
            dontUnpack = true;
          };
        };

        pkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [ overlay ];
        };
      in
        pkgs.slow-text;

    packages.x86_64-linux.default = self.packages.x86_64-linux.slow-text;

  };
}
EOF

nix \
flake \
update \
--override-input nixpkgs github:NixOS/nixpkgs/e39a949aaa9e4fc652b1619b56e59584e1fc305b

# nix flake lock
git init && git add .

time nix build -L '.#'

```


```bash
KEY_FILE=cache-priv-key.pem
CACHE=s3://playing-bucket-nix-cache-test
BUILDS=(".#slow-text")
# BUILDS=("nixpkgs#hello" "nixpkgs#figlet")

echo "${BUILDS[@]}" | xargs nix build
mapfile -t DERIVATIONS < <(echo "${BUILDS[@]}" | xargs nix path-info --derivation)
mapfile -t DEPENDENCIES < <(echo "${DERIVATIONS[@]}" | xargs nix-store --query --requisites --include-outputs)
echo "${DEPENDENCIES[@]}" | xargs nix store sign --key-file "${KEY_FILE}" --recursive
echo "${DEPENDENCIES[@]}" | xargs nix copy --to "${CACHE}"
```
Refs.:
- [How to correctly cache build-time dependencies using Nix ](https://www.haskellforall.com/2022/10/how-to-correctly-cache-build-time.html)



In the "client" machine:
```bash
# EXTRA_TRUSTED_PUBLIC_KEYS="$(cat cache-pub-key.pem)"
CACHE='s3://playing-bucket-nix-cache-test'
EXTRA_TRUSTED_PUBLIC_KEYS='playing-bucket-nix-cache-test:8Un6HaBmD5I6nwKi6ECDrzBaO55fmAVjEfDAz3HLbIA='
cat > ~/.config/nix/nix.conf << EOF
system-features = benchmark big-parallel kvm nixos-test
experimental-features = nix-command flakes
show-trace = true
substituters = https://cache.nixos.org $CACHE
trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= $EXTRA_TRUSTED_PUBLIC_KEYS
trusted-users = root $USER
EOF
```


In the "client" machine:
```bash
mkdir -p ~/slow-text
cd ~/slow-text

cat > flake.nix << 'EOF'
{
  description = "A very basic flake";

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux.slow-text = let
        overlay = final: prev: {
          slow-text = prev.stdenv.mkDerivation {
            name = "slow-text";
            buildPhase = "echo started building && sleep 30 && mkdir -pv $out && echo a >> $out/log.txt && sleep 30 && echo b >> $out/log.txt";
            dontInstall = true;
            dontUnpack = true;
          };
        };

        pkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [ overlay ];
        };
      in 
        pkgs.slow-text;

    packages.x86_64-linux.default = self.packages.x86_64-linux.slow-text;

  };
}
EOF

nix \
flake \
update \
--override-input nixpkgs github:NixOS/nixpkgs/e39a949aaa9e4fc652b1619b56e59584e1fc305b

# nix flake lock
git init && git add .

time nix build -L '.#'

```


Broken, it is a generic example.
```bash
nix \
build \
--impure \
--keep-failed \
--no-link \
--print-build-logs \
--print-out-paths \
--expr \
'
  (
    with builtins.getFlake "github:NixOS/nixpkgs/01c02c84d3f1536c695a2ec3ddb66b8a21be152b"; 
    with legacyPackages.${builtins.currentSystem}; 
    stdenv.mkDerivation {
      name = "ubuntu2204box";
      src = fetchurl {
                      url = "https://app.vagrantup.com/generic/boxes/ubuntu2204/versions/4.2.10/providers/libvirt.box";
                      sha256 = "";
                    };
      buildPhase = "mkdir -pv $out/box; cp -R . $out/box";
      dontInstall = true;
    }
  )
'
```


```bash
nix path-info --closure-size --eval-store auto --store 'nixpkgs#glibc^*'
```

```bash
nix path-info --closure-size --eval-store auto --store s3://playing-bucket-nix-cache-test '.#hello^*'
```

> Ok, these errors disappeared when I changed geographical location of the Hydra HTTP client.
> https://github.com/input-output-hk/iohk-nix/issues/237#issuecomment-555675836




### WIP, examples



In the client:
```bash
ssh nixuser@localhost -p 2221
```

```bash
mkdir -pv ~/.ssh \
&& chmod 0700 -v ~/.ssh \
&& touch ~/.ssh/config \
&& chmod 600 -v ~/.ssh/config
```


```bash
tee ~/.ssh/config <<EOF
Host builder
    HostName localhost
    User nixuser
    Port 2221
    PubkeyAcceptedKeyTypes ssh-ed25519
    IdentitiesOnly yes
    IdentityFile ~/.ssh/id_ed25519
    LogLevel INFO
EOF
```

It must work:
```bash
ssh builder
```


```bash
ssh builder nix-store --version
```
Refs.:
- https://nixos.wiki/wiki/Distributed_build#Prerequisites


```bash
nix store ping --store ssh://builder
```


```bash
nix store ping --store ssh-ng://builder
```


In the "client" machine:
```bash
mkdir -p slow-text
cd slow-text

cat > flake.nix << 'EOF'
{
  description = "A very basic flake";

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux.slow-text = let
        overlay = final: prev: {
          slow-text = prev.stdenv.mkDerivation {
            name = "slow-text";
            buildPhase = "echo started building && sleep 30 && mkdir -pv $out && echo a >> $out/log.txt && sleep 30 && echo b >> $out/log.txt";
            dontInstall = true;
            dontUnpack = true;
          };
        };

        pkgs = import nixpkgs {
          system = "x86_64-linux";
          overlays = [ overlay ];
        };
      in 
        pkgs.slow-text;

    packages.x86_64-linux.default = self.packages.x86_64-linux.slow-text;

  };
}
EOF

nix \
flake \
update \
--override-input nixpkgs github:NixOS/nixpkgs/8bc6945b1224a1cfa679d6801580b1054dba1a5c

# nix flake lock
git init && git add .

time \
nix \
build \
--print-build-logs \
--print-out-paths \
--max-jobs 0 \
--eval-store auto \
--store ssh-ng://builder \
'.#'


# If the build is broken it does not work?
nix \
log \
--max-jobs 0 \
--eval-store auto \
--store ssh-ng://builder \
'.#'

```

In the builder machine:
```bash
nix \
--option extra-trusted-public-keys "$(cat /etc/nix/public-key)" \
path-info \
--sigs \
--recursive \
/nix/store/2xw250v6l8416spl3w18am42xs0mnx6x-slow-text
```

```bash
nix \
--option extra-trusted-public-keys "$(cat /etc/nix/public-key)" \
store \
verify \
--recursive \
--sigs-needed 2 \
/nix/store/2xw250v6l8416spl3w18am42xs0mnx6x-slow-text
```


```bash
nix \
--option extra-trusted-public-keys binarycache-1:MTfGu7Yy/XvFDqUm5yK0DETkLV0slNILWPAxqCly+9c= \
copy \
--from ssh-ng://builder \
$(
   nix \
   eval \
   --raw \
   --eval-store auto \
   --store ssh-ng://builder \
   '.#'
)
```


```bash
nix \
--option extra-trusted-public-keys binarycache-1:MTfGu7Yy/XvFDqUm5yK0DETkLV0slNILWPAxqCly+9c= \
store \
verify \
--recursive \
--sigs-needed 1 \
$(
   nix \
   eval \
   --raw \
   --eval-store auto \
   --store ssh-ng://builder \
   '.#'
)
```


TODO: test
```bash
nix \
build \
--max-jobs 0 \
--builders "ssh://builder x86_64-linux - 100 1 big-parallel,benchmark" \
nixpkgs#pkgsStatic.python3
```

```bash
nix build --max-jobs 0 --eval-store auto --store ssh-ng://builder nixpkgs#pkgsStatic.python3
```

```bash
EXPR_NIX='
  (
    with builtins.getFlake "github:NixOS/nixpkgs/8bc6945b1224a1cfa679d6801580b1054dba1a5c";
    with legacyPackages.${builtins.currentSystem};
    (pkgsStatic.hello.overrideAttrs
      (oldAttrs: {
          patchPhase = (oldAttrs.patchPhase or "") + "sed -i \"s/Hello, world!/hello, Nix!/g\" src/hello.c";
          dontCheck = true;
        }
      )
    )
  )
'

nix \
build \
--print-out-paths \
--max-jobs 0 \
--eval-store auto \
--store ssh-ng://builder \
--impure \
--expr \
$EXPR_NIX
```

```bash
mkdir -pv sandbox/sandbox \
&& cd sandbox/sandbox
```


```bash
nix \
build \
--eval-store auto \
--store ssh-ng://builder \
--impure \
--expr \
'
  (
    (
      (
        builtins.getFlake "github:NixOS/nixpkgs/4b4f4bf2845c6e2cc21cd30f2e297908c67d8611"
      ).lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ 
                      "${toString (builtins.getFlake "github:NixOS/nixpkgs/4b4f4bf2845c6e2cc21cd30f2e297908c67d8611")}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
                      { 
                        # https://nixos.wiki/wiki/Creating_a_NixOS_live_CD#Building_faster
                        isoImage.squashfsCompression = "gzip -Xcompression-level 1";
                      }
                    ];
      }
    ).config.system.build.isoImage
  )
'
```


```bash
nix \
copy \
--from ssh-ng://builder \
/nix/store/brdqd7bpp67nyqfacza7ffzwjfp37zrg-hello-static-x86_64-unknown-linux-musl-2.12.drv
```

```bash
nix \
copy \
--no-check-sigs \
--from ssh-ng://builder \
/nix/store/7l35kkayn7a52yqgxzcmjvvg0xnslgrc-nixos-21.11.20210618.4b4f4bf-x86_64-linux.iso.drv
```
Refs.:
- https://github.com/NixOS/nix/issues/4894#issuecomment-1252510474



> The previous point does not retroactively sign existing paths in the store of the builder. To do so, run 

Refs.:
- https://nixos.wiki/wiki/Distributed_build#Prerequisites

```bash
# sudo nix sign-paths --all --key-file /etc/nix/private-key

sudo nix store sign --all --key-file /etc/nix/private-key
```


### --post-build-hook


```bash
tee custom-build-hook.sh <<EOF
#!/usr/bin/env bash

set -euf 

echo "post-build-hook"
echo "-- ${OUT_PATHS} --"
echo "^^ ${DRV_PATH} ^^"
EOF

chmod -v 0755 custom-build-hook.sh

./custom-build-hook.sh
```

```bash
nix build --rebuild -L nixpkgs#hello --post-build-hook ./custom-build-hook.sh
```

```bash
nix build --rebuild nixpkgs#hello --post-build-hook ./custom-build-hook.sh
```


```bash
nix build --rebuild -L nixpkgs#python3 --post-build-hook ./custom-build-hook.sh
```

```bash
time nix build --rebuild nixpkgs#ffmpeg
```


```bash
SCRIPT_NAME='build-hook-sign.sh'

tee "$SCRIPT_NAME" <<EOF
#!/usr/bin/env bash

set -euf 

KEY_FILE=cache-priv-key.pem
# CACHE=s3://playing-bucket-nix-cache-test
BUILDS=("nixpkgs#hello" "nixpkgs#figlet")

echo "post-build-hook"
echo "-- ${OUT_PATHS} --"
echo "^^ ${DRV_PATH} ^^"


echo "${BUILDS[@]}" | xargs nix build
mapfile -t DERIVATIONS < <(echo "${BUILDS[@]}" | xargs nix path-info --derivation)
mapfile -t DEPENDENCIES < <(echo "${DERIVATIONS[@]}" | xargs nix-store --query --requisites --include-outputs)
echo "${DEPENDENCIES[@]}" | xargs nix store sign --key-file "${KEY_FILE}" --recursive
# echo "${DEPENDENCIES[@]}" | xargs nix copy --to "${CACHE}"

EOF

chmod -v 0755 "$SCRIPT_NAME"

./"$SCRIPT_NAME"
```
Refs.:
- [How to correctly cache build-time dependencies using Nix ](https://www.haskellforall.com/2022/10/how-to-correctly-cache-build-time.html)

```bash
nix \
build \
--print-build-logs \
--print-out-paths \
--max-jobs 0 \
--eval-store auto \
--store ssh-ng://builder \
nixpkgs#hello \
--post-build-hook ./custom-build-hook.sh
```

```bash
nix build --print-build-logs nixpkgs#hello --post-build-hook ./custom-build-hook.sh
```

```bash
nix build --substituters '' nixpkgs#hello
```
https://discourse.nixos.org/t/nix-store-copy-vs-sigs/20366/3


```bash
nix path-info --sigs --recursive /nix/store/v02pl5dhayp8jnz8ahdvg5vi71s8xc6g-hello-2.12.1
```


```bash
nix store verify --recursive --sigs-needed 1 "$(readlink -f result)"
```




```bash
# Why sudo?
sudo nix store copy-sigs --all --substituter https://cache.nixos.org/
```

```bash
cat /etc/nix/public-key
```

```bash
sudo cat /etc/nix/private-key
```

```bash
nix \
--option extra-trusted-public-keys  \
store verify --recursive --sigs-needed 2 $(nix build --print-out-paths --no-link nixpkgs#hello)
```

```bash
nix store verify --recursive --sigs-needed 1 $(nix path-info nixpkgs#figlet)


nix store verify --recursive --sigs-needed 2 $(nix path-info nixpkgs#figlet)
```

```bash
nix store verify --recursive --sigs-needed 1 \
$(dirname $(dirname $(readlink -f $(which figlet))))
```

```bash
nix build -L --rebuild nixpkgs#hello
```


```bash
nix store verify --recursive --sigs-needed 1 /nix/store/v02pl5dhayp8jnz8ahdvg5vi71s8xc6g-hello-2.12.1
```

#### amazonImage, WIP


```bash
{ pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/virtualisation/amazon-image.nix> ];
  ec2.hvm = true;
  environment.systemPackages = with pkgs; [ git ];
}
```

```bash
nix \
run \
github:nix-community/nixos-generators \
-- \
--format amazon \
-c ./configuration.nix
```


```bash
nix \
build \
--eval-store auto \
--store ssh-ng://builder \
--impure \
--expr \
'
  (
    (
      (
        builtins.getFlake "github:NixOS/nixpkgs/4b4f4bf2845c6e2cc21cd30f2e297908c67d8611"
      ).lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ 
                      "${toString (builtins.getFlake "github:NixOS/nixpkgs/4b4f4bf2845c6e2cc21cd30f2e297908c67d8611")}/nixos/modules/virtualisation/amazon-image.nix"
                    ];
      }
    ).config.system.build.amazonImage
  )
'
```



```bash
nix-build \
'<nixpkgs/nixos/release.nix>' \
-A amazonImage.x86_64-linux \
--arg configuration ./configuration.nix
```

```bash
nix-build \
'<nixpkgs/nixos/release.nix>' \
-A amazonImage.x86_64-linux \
--arg configuration ./configuration.nix
```


#### FAQ


> Cache size is around 220TB. No plans to change retention, afaik.
Refs.: https://discourse.nixos.org/t/how-long-is-binary-cache-kept-on-cache-nixos-org/11210/6


https://cache.nixos.org/

```nix
 # Legacy configuration conversion.
 nix.settings = mkMerge [
   {
     trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
   }
 ];
```
Refs.:
- https://github.com/NixOS/nixpkgs/blob/eac7da7b519a5aefe92c33c90b4450a24ebe0ab3/nixos/modules/services/misc/nix-daemon.nix#L821-L824
- https://discourse.nixos.org/t/what-is-the-public-key-of-cache-nixos-org/19799/2


### Multi singing


```bash
nix path-info --sigs $(nix build --print-out-paths --no-link nixpkgs#hello)
```


>  /* Whether the path is ultimately trusted, that is, it's a
>    derivation output that was built locally. */
> bool ultimate = false;

Refs.: 
- https://github.com/NixOS/nix/blob/1de5b0e4e64cb1062965c73d3037fc798cd018bb/src/libstore/path-info.hh#L39-L41
- https://discourse.nixos.org/t/how-do-i-query-the-nix-store-for-all-packages-i-have-built-myself/19047/6



On the builder machine:

```bash
mkdir -pv ~/play-with-singing \
&& cd ~/play-with-singing
```


```bash
BINARY_CACHE_NAME=binarycache-11
PRIVATE_KEY_NAME=binarycache-priv-key-1.pem
PUBLIC_KEY_NAME=binarycache-pub-key-1.pem


nix-store --generate-binary-cache-key "$BINARY_CACHE_NAME" "$PRIVATE_KEY_NAME" "$PUBLIC_KEY_NAME"

chown -v "$USER" "$PRIVATE_KEY_NAME" \
&& chmod -v 0600 "$PRIVATE_KEY_NAME"
cat "$PUBLIC_KEY_NAME"


# The seconde pair
BINARY_CACHE_NAME=binarycache-12
PRIVATE_KEY_NAME=binarycache-priv-key-2.pem
PUBLIC_KEY_NAME=binarycache-pub-key-2.pem


nix-store --generate-binary-cache-key "$BINARY_CACHE_NAME" "$PRIVATE_KEY_NAME" "$PUBLIC_KEY_NAME"

chown -v "$USER" "$PRIVATE_KEY_NAME" \
&& chmod -v 0600 "$PRIVATE_KEY_NAME"
cat "$PUBLIC_KEY_NAME"
```


```bash
nix path-info --sigs $(nix build --print-out-paths --no-link nixpkgs#hello)
```


```bash
sudo nix store sign --key-file binarycache-priv-key-1.pem --recursive $(nix build --print-out-paths --no-link nixpkgs#hello)
```

```bash
nix path-info --sigs $(nix build --print-out-paths --no-link nixpkgs#hello)
```

```bash
nix store verify --recursive --sigs-needed 1 $(nix build --print-out-paths --no-link nixpkgs#hello)
```

```bash
nix \
--option extra-trusted-public-keys "$(cat binarycache-pub-key-1.pem)" \
store verify --recursive --sigs-needed 2 $(nix build --print-out-paths --no-link nixpkgs#hello)
```

```bash
sudo nix store sign --key-file binarycache-priv-key-2.pem --recursive $(nix build --print-out-paths --no-link nixpkgs#hello)
```

```bash
nix \
--option extra-trusted-public-keys "$(cat binarycache-pub-key-1.pem) $(cat binarycache-pub-key-2.pem)" \
store verify --recursive --sigs-needed 3 $(nix build --print-out-paths --no-link nixpkgs#hello)
```



#### Using the `--rebuild` flag


```bash
nix path-info --sigs $(nix build --print-out-paths --no-link --rebuild nixpkgs#hello)
```

```bash
nix store verify --recursive --sigs-needed 1 $(nix build --print-out-paths --no-link --rebuild nixpkgs#hello)
```

```bash
nix path-info --sigs $(nix build --print-out-paths --no-link nixpkgs#hello)
```
Refs.: 
- https://github.com/NixOS/nix/blob/1de5b0e4e64cb1062965c73d3037fc798cd018bb/src/libstore/path-info.hh#L39-L41
- https://discourse.nixos.org/t/how-do-i-query-the-nix-store-for-all-packages-i-have-built-myself/19047/6

```bash
sudo nix store sign --key-file binarycache-priv-key-1.pem --recursive $(nix build --print-out-paths --no-link --rebuild nixpkgs#hello)
```

```bash
nix path-info --sigs $(nix build --print-out-paths --no-link --rebuild nixpkgs#hello)
```

```bash
nix \
--option extra-trusted-public-keys "$(cat binarycache-pub-key-1.pem)" \
store verify --recursive --sigs-needed 2 $(nix build --print-out-paths --no-link nixpkgs#hello)
```

```bash
sudo nix store sign --key-file binarycache-priv-key-2.pem --recursive $(nix build --print-out-paths --no-link --rebuild nixpkgs#hello)
```

```bash
nix path-info --sigs $(nix build --print-out-paths --no-link --rebuild nixpkgs#hello)
```

```bash
nix \
--option extra-trusted-public-keys "$(cat binarycache-pub-key-1.pem) $(cat binarycache-pub-key-2.pem)" \
store verify --recursive --sigs-needed 3 $(nix build --print-out-paths --no-link nixpkgs#hello)
```



#### Inspecting sqlite


```bash
nix path-info --sigs $(readlink -f result)
```
Refs.:
- https://github.com/NixOS/nix/issues/4258


```bash
nix run nixpkgs#sqlite -- ~/.cache/nix/binary-cache-v6.sqlite 'pragma integrity_check'
```
Refs.:
- https://github.com/NixOS/nix/issues/3545#issuecomment-621107449



```bash
sqlite3 ~/.cache/nix/binary-cache-v6.sqlite
```
Refs.:
- https://github.com/NixOS/nix/issues/4258


```bash
.fullschema

# sqlite3 ~/.cache/nix/binary-cache-v6.sqlite <<< '.fullschema'
```
Refs.:
- https://stackoverflow.com/a/25734826


```bash
select * from nars where hashPart='ab5pw1y75x4ndjd3dkxbcjkwjc3vp13s';
```
Refs.:
- https://github.com/NixOS/nix/issues/4258



```bash
sudo sqlite3 /root/.cache/nix/binary-cache-v6.sqlite
```
Refs.:
- https://github.com/NixOS/nix/issues/4258



```bash
nix path-info --sigs $(readlink -f result)
```


#### Troubleshoting, old


For some reason once in the past someone messed up its aws region, here is how to use a different region:
```bash
AWS_DEFAULT_REGION=xy-abcd-w 
aws s3 ls
```
https://github.com/aws/aws-cli/issues/3772#issuecomment-657038848

