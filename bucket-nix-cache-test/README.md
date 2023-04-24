
## In the first time

Configuring the aws CLI:
```bash
sudo \
sh <<'EOF'

test -d ~/.aws || mkdir -pv ~/.aws

cat > ~/.aws/credentials << 'NESTEDEOF'
[default]

NESTEDEOF

cat > ~/.aws/config << 'NESTEDEOF'
[default]
region = us-east-1
output = json
NESTEDEOF

aws s3 ls
EOF
```


```bash
nix store ping --store s3://playing-bucket-nix-cache-test
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

Empting a bucket:
```bash
aws s3 rm s3://playing-bucket-nix-cache-test --recursive
```
Refs.:
- https://docs.aws.amazon.com/AmazonS3/latest/userguide/empty-bucket.html


WARNING: be carefull. Removing the bucket:

> Note: `rb` stands for "remove bucket".

```bash
aws s3 rb s3://playing-bucket-nix-cache-test --force
```



So this is going to be empty:
```bash
aws s3 ls
```

```bash
aws s3 ls --summarize --human-readable --recursive s3://playing-bucket-nix-cache-test
```
Refs.:
- https://aws.amazon.com/pt/blogs/storage/find-out-the-size-of-your-amazon-s3-buckets/


How to print all the s3 bucket contents:
```bash
aws s3 cp s3://playing-bucket-nix-cache-test/nix-cache-info -
```
Refs.:
- https://stackoverflow.com/a/28390423


#### nix cache in s3 bucket


TODO: document it
```bash
aws s3 cp nix-cache-info s3://playing-bucket-nix-cache-test/
```


```bash
curl -I https://playing-bucket-nix-cache-test.s3.amazonaws.com/nix-cache-info
```


#### Sending GNU hello to a custom s3 binary cache


```bash
nix \
copy \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#hello \
--to 'ssh-ng://builder'
```

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
--store 's3://playing-bucket-nix-cache-test/' \
--long \
--recursive \
$(nix eval --raw github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#hello)
```


```bash
nix \
build \
--eval-store auto \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
--rebuild \
--store ssh-ng://builder \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#hello
```


```bash
nix-store --query --requisites --include-outputs --force-realise \
$(nix path-info github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#hello) \
| xargs -I{} nix \
    copy \
    --no-check-sigs \
    {} \
    --to 's3://playing-bucket-nix-cache-test'
```



Build it from s3 custom cache AND the official cache:
```bash
nix \
--option eval-cache false \
--option extra-trusted-public-keys binarycache-1:3IpDUoZn47UKPA/SFvgrTLIskDMoxG8xyeqRP/f5RvM=% \
--option extra-substituters https://playing-bucket-nix-cache-test.s3.amazonaws.com \
build \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#hello
```
Refs.:
- https://github.com/NixOS/nix/issues/6672#issuecomment-1251573660



```bash
nix-store --query --requisites --include-outputs --force-realise \
$(nix path-info --derivation github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#hello) \
| xargs -I{} nix \
    copy \
    --no-check-sigs \
    {} \
    --to 's3://playing-bucket-nix-cache-test'
```

Build and `--rebuild` it from s3 cache ONLY:
```bash
nix \
--option eval-cache false \
--option trusted-public-keys binarycache-1:JQoiDAGCaEkxmSPGLuM4qZVA+NDrBQHrVYY4Wi/Zi/E= \
--option substituters https://playing-bucket-nix-cache-test.s3.amazonaws.com \
build \
--keep-failed \
--no-link \
--print-build-logs \
--print-out-paths \
--rebuild \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#hello
```
Refs.:
- https://github.com/NixOS/nix/issues/6672#issuecomment-1251573660


nix build --no-link --print-build-logs --rebuild \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#gcc-unwrapped



```bash
nix \
build \
--eval-store auto \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
--rebuild \
--store ssh-ng://builder \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#pkgsStatic.hello
```



```bash
nix \
build \
--eval-store auto \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
--rebuild \
--store ssh-ng://builder \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#pkgsStatic.nix
```



```bash
nix \
build \
--builders-use-substitutes \
--eval-store auto \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
--store ssh-ng://builder \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#pkgsStatic.hello
```
Refs.:
- https://gist.github.com/danbst/09c3f6cd235ae11ccd03215d4542f7e7?permalink_comment_id=3140653#gistcomment-3140653



#### hello in s3 cache

In the client:
```bash
nix \
build \
--eval-store auto \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
--rebuild \
--store ssh-ng://builder \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#hello
```

In the builder itself:
```bash
nix \
build \
--eval-store auto \
--keep-failed \
--no-link \
--print-build-logs \
--print-out-paths \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#hello
```


Note: the `--rebuild` flag:
```bash
nix \
build \
--eval-store auto \
--keep-failed \
--no-link \
--print-build-logs \
--print-out-paths \
--rebuild \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#hello
```


##### Testing the populated cache


Testing that it is in the cache:
```bash
nix \
--option eval-cache false \
store \
ls \
--store 's3://playing-bucket-nix-cache-test/' \
--long \
--recursive \
$(nix eval --raw github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#hello)
```

Build it from s3 cache:
```bash
nix \
--option eval-cache false \
--option extra-trusted-public-keys binarycache-1:iuW9hwt11/OqxdXo1Hf0r+1Vp3CxSvd9kok7xi0HqAM= \
--option extra-substituters https://playing-bucket-nix-cache-test.s3.amazonaws.com \
build \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#hello
```
Refs.:
- https://github.com/NixOS/nix/issues/6672#issuecomment-1251573660



The fastest:
```bash
nix \
--option eval-cache false \
--option trusted-public-keys binarycache-1:iuW9hwt11/OqxdXo1Hf0r+1Vp3CxSvd9kok7xi0HqAM= \
--option trusted-substituters https://playing-bucket-nix-cache-test.s3.amazonaws.com \
build \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#hello
```


```bash
nix \
--option eval-cache false \
--option trusted-public-keys binarycache-1:iuW9hwt11/OqxdXo1Hf0r+1Vp3CxSvd9kok7xi0HqAM= \
--option trusted-substituters https://playing-bucket-nix-cache-test.s3.amazonaws.com \
--option build-use-substitutes false \
--option substitute false \
--extra-experimental-features 'nix-command flakes' \
build \
--keep-failed \
--no-link \
--max-jobs 0 \
--print-build-logs \
--print-out-paths \
--substituters "https://playing-bucket-nix-cache-test.s3.amazonaws.com" \
'github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#hello'
```

Forcing a local build with `--rebuild` and remove `--max-jobs 0`:
```bash
nix \
--option eval-cache false \
--option trusted-public-keys binarycache-1:iuW9hwt11/OqxdXo1Hf0r+1Vp3CxSvd9kok7xi0HqAM= \
--option trusted-substituters https://playing-bucket-nix-cache-test.s3.amazonaws.com \
build \
--keep-failed \
--no-link \
--print-build-logs \
--print-out-paths \
--rebuild \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#hello
```


```bash
nix \
--option trusted-public-keys binarycache-1:iuW9hwt11/OqxdXo1Hf0r+1Vp3CxSvd9kok7xi0HqAM= \
--option trusted-substituters https://playing-bucket-nix-cache-test.s3.amazonaws.com \
--option build-use-substitutes true \
--option substitute true \
--extra-experimental-features 'nix-command flakes' \
build \
--keep-failed \
--no-link \
--print-build-logs \
--print-out-paths \
--rebuild \
--substituters https://playing-bucket-nix-cache-test.s3.amazonaws.com \
'github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#hello'
```



#### pkgsStatic.hello



In the builder itself:
```bash
nix \
build \
--eval-store auto \
--keep-failed \
--no-link \
--print-build-logs \
--print-out-paths \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#pkgsStatic.hello
```

```bash
nix \
copy \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#pkgsStatic.hello \
--to 's3://playing-bucket-nix-cache-test'
```

```bash
nix \
--option eval-cache false \
--option trusted-public-keys binarycache-1:XiPHS/XT/ziMHu5hGoQ8Z0K88sa1Eqi5kFTYyl33FJg= \
--option trusted-substituters https://playing-bucket-nix-cache-test.s3.amazonaws.com \
--option build-use-substitutes true \
--option substitute true \
--extra-experimental-features 'nix-command flakes' \
build \
--keep-failed \
--no-link \
--print-build-logs \
--print-out-paths \
--max-jobs 0 \
--substituters https://playing-bucket-nix-cache-test.s3.amazonaws.com \
'github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#pkgsStatic.hello'
```


```bash
nix \
--option extra-trusted-public-keys 'binarycache-1:XiPHS/XT/ziMHu5hGoQ8Z0K88sa1Eqi5kFTYyl33FJg=' \
store verify --sigs-needed 1 'github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#pkgsStatic.hello'
```

#### pkgsCross.aarch64-multiplatform.pkgsStatic.hello



```bash
nix \
build \
--eval-store auto \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
--store ssh-ng://builder \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#pkgsCross.aarch64-multiplatform.pkgsStatic.hello
```


With `--rebuild`:
```bash
nix \
build \
--eval-store auto \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
--rebuild \
--store ssh-ng://builder \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#pkgsCross.aarch64-multiplatform.pkgsStatic.hello
```



```bash
nix-store --query --requisites --include-outputs --force-realise \
$(nix path-info --derivation github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#pkgsStatic.hello) \
| wc -l
```



```bash
nix \
copy \
$(nix eval --raw --expr $EXPR_NIX) \
--to 's3://playing-bucket-nix-cache-test'
```


```bash
nix-store --query --requisites --include-outputs --force-realise \
$(nix path-info --derivation github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#pkgsCross.aarch64-multiplatform.pkgsStatic.hello) \
| xargs -I{} nix \
    copy \
    --no-check-sigs \
    {} \
    --to 's3://playing-bucket-nix-cache-test'
```

```bash
nix-store --query --requisites --include-outputs --force-realise \
$(nix path-info --derivation github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#pkgsCross.aarch64-multiplatform.pkgsStatic.hello) \
| xargs -I{} aws s3 cp \
    {} \
    s3://playing-bucket-nix-cache-test
```


```bash
nix \
path-info \
--closure-size \
--eval-store auto \
--store s3://playing-bucket-nix-cache-test \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#pkgsCross.aarch64-multiplatform.pkgsStatic.hello
```

#### pkgsStatic.python3Minimal


```bash
EXPR_NIX='
  (
    with builtins.getFlake "github:NixOS/nixpkgs/3364b5b117f65fe1ce65a3cdd5612a078a3b31e3";
    with legacyPackages.${builtins.currentSystem};
    (pkgsStatic.python3Minimal.override
      {
        reproducibleBuild = true;
      }
    )
  )
'

nix \
build \
--impure \
--eval-store auto \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
--rebuild \
--store ssh-ng://builder \
--expr \
"$EXPR_NIX"

EXPECTED_SHA512SUM=b6621c62c76c3d09c488222a5813e2f67f4f256c66780ca0da41eb6fe71d798c702e270c35cfa3b761484eef8a539589b3b3824523ecf6a8ad837ab74a3ce506
FULL_PATH=$(nix eval --impure --raw --expr $EXPR_NIX)/bin/python
echo "$EXPECTED_SHA512SUM"'  '"$FULL_PATH" | sha512sum -c
```





#### pkgsStatic.nix

```bash
nix \
--option eval-cache false \
--option extra-trusted-public-keys binarycache-1:PbJHKsLPq2DJ2OXhvqk1VgwFl04tvaHz3PzjZrrFNh0= \
store \
ls \
--store 's3://playing-bucket-nix-cache-test/' \
--long \
--recursive \
$(nix eval --raw github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#pkgsStatic.nix)
```


```bash
nix \
--option eval-cache false \
--option extra-trusted-public-keys binarycache-1:iuW9hwt11/OqxdXo1Hf0r+1Vp3CxSvd9kok7xi0HqAM= \
--option extra-substituters https://playing-bucket-nix-cache-test.s3.amazonaws.com \
build \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#pkgsStatic.nix
```

--eval-store ??
```bash
nix \
build \
--eval-store auto \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
--rebuild \
--store ssh-ng://builder \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#pkgsCross.aarch64-multiplatform.pkgsStatic.hello
```


binarycache-1:vBBc6CVmjXj5dPH0x5zPPZvkc1U9QbVoSqHcUcx6cSY=
```bash
nix \
--option eval-cache false \
--option extra-trusted-public-keys binarycache-1:tcdI+LZIBrh5xmvW2P0NO5ZPwTKpkCoGq3Hmmj58yOI= \
--option extra-substituters https://playing-bucket-nix-cache-test.s3.amazonaws.com \
build \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#pkgsCross.aarch64-multiplatform.pkgsStatic.hello
```


```bash
EXPR_NIX='
  (
    with builtins.getFlake "github:NixOS/nixpkgs/3364b5b117f65fe1ce65a3cdd5612a078a3b31e3";
    with legacyPackages.${builtins.currentSystem};
      (pkgsStatic.nix.overrideAttrs (oldAttrs: {
          configureFlags = (oldAttrs.configureFlags or "") ++ [ 
            "--with-store-dir=/home/abcuser/.local/share/nix/root/nix/store"
            "--localstatedir=/home/abcuser/.local/share/nix/root/nix/var"
            "--sysconfdir=/home/abcuser/.local/share/nix/root/etc"
            "--enable-gc"
            "--disable-doc-gen"
            "--with-sandbox-shell=${busybox-sandbox-shell}/bin/busybox"
            "--enable-embedded-sandbox-shell"
            "--enable-static"
            "--disable-shared"
            "--disable-shared"
            "--build=x86_64-unknown-linux-gnu"
            "--host=x86_64-unknown-linux-musl"
          ];
      })).override {
        storeDir = "/home/abcuser/.local/share/nix/root";
        stateDir = "/home/abcuser/.local/share/nix/root";
        confDir = "/home/abcuser/.local/share/nix/root";
      }
  )
'


nix show-derivation --impure --expr "$EXPR_NIX"



#nix \
#build \
#--impure \
#--keep-failed \
#--no-link \
#--print-build-logs \
#--print-out-paths \
#--expr $EXPR_NIX

time \
nix \
build \
--impure \
--eval-store auto \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
--store ssh-ng://builder \
--substituters '' \
--expr "$EXPR_NIX"
```



```bash
time \
nix-store --query --requisites --include-outputs --force-realise \
/nix/store/llnb5mxrxaa5njj3jvqm0kw002x1ww27-nix-static-x86_64-unknown-linux-musl-2.13.3 \
| xargs -I{} nix \
    copy \
    --no-check-sigs \
    {} \
    --to 's3://playing-bucket-nix-cache-test'
```




In the client. The fastest:
```bash
EXPR_NIX='
  (
    with builtins.getFlake "github:NixOS/nixpkgs/3364b5b117f65fe1ce65a3cdd5612a078a3b31e3";
    with legacyPackages.${builtins.currentSystem};
    
      (pkgsStatic.nix.override {
        storeDir = "/home/abcuser/.nix/store";
        stateDir = "/home/abcuser/.nix/var";
        confDir = "/home/abcuser/.nix/etc";
      })
  )
'


nix \
--option eval-cache false \
store \
ls \
--store 's3://playing-bucket-nix-cache-test/' \
--long \
--recursive \
$(nix eval --impure --raw --expr $EXPR_NIX)


# --max-jobs 0 \
nix \
--option eval-cache false \
--option trusted-public-keys binarycache-1:iuW9hwt11/OqxdXo1Hf0r+1Vp3CxSvd9kok7xi0HqAM= \
--option extra-trusted-substituters https://playing-bucket-nix-cache-test.s3.amazonaws.com \
build \
--keep-failed \
--no-link \
--print-build-logs \
--print-out-paths \
--substituters https://playing-bucket-nix-cache-test.s3.amazonaws.com \
$(nix eval --raw --expr "$EXPR_NIX")
```

```bash
nix-store --query --requisites --include-outputs --force-realise \
$(nix path-info --derivation --raw github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#pkgsCross.aarch64-multiplatform.pkgsStatic.hello) \
| wc -l
```




```bash
EXPR_NIX='
  (
    with builtins.getFlake "github:NixOS/nixpkgs/3364b5b117f65fe1ce65a3cdd5612a078a3b31e3";
    with legacyPackages.${builtins.currentSystem};
    
      (pkgsStatic.nix.override {
        storeDir = "/home/vagrant/.nix/store";
        stateDir = "/home/vagrant/.nix/var";
        confDir = "/home/vagrant/.nix/etc";
      })
  )
'

#nix \
#build \
#--impure \
#--keep-failed \
#--no-link \
#--print-build-logs \
#--print-out-paths \
#--expr $EXPR_NIX

nix \
build \
--impure \
--eval-store auto \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
--store ssh-ng://builder \
--substituters '' \
--expr $EXPR_NIX
```



```bash
FLAKE_ATTR=".#homeConfigurations.""$HM_ATTR_FULL_NAME"".activationPackage"

nix \
--option eval-cache false \
--option extra-trusted-public-keys binarycache-1:XiPHS/XT/ziMHu5hGoQ8Z0K88sa1Eqi5kFTYyl33FJg= \
--option extra-substituters https://playing-bucket-nix-cache-test.s3.amazonaws.com \
build \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
"$FLAKE_ATTR"
```


#### Vagrant 

```bash
export NIXPKGS_ALLOW_UNFREE=1

nix \
build \
--impure \
--eval-store auto \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
--store ssh-ng://builder \
--substituters '' \
~/.config/nixpkgs#homeConfigurations.vagrant.activationPackage
```

```bash
nix \
--option eval-cache false \
--option extra-trusted-public-keys binarycache-1:vBBc6CVmjXj5dPH0x5zPPZvkc1U9QbVoSqHcUcx6cSY= \
--option extra-substituters https://playing-bucket-nix-cache-test.s3.amazonaws.com \
build \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
~/.config/nixpkgs#homeConfigurations.vagrant.activationPackage
```




```bash
export NIXPKGS_ALLOW_UNFREE=1

nix \
build \
--impure \
--eval-store auto \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
--store ssh-ng://builder \
--substituters '' \
~/.config/nixpkgs#homeConfigurations.vagrant-alpine316.localdomain.activationPackage
```

```bash
export NIXPKGS_ALLOW_UNFREE=1

nix \
--option eval-cache false \
--option extra-trusted-public-keys binarycache-1:vBBc6CVmjXj5dPH0x5zPPZvkc1U9QbVoSqHcUcx6cSY= \
--option extra-substituters https://playing-bucket-nix-cache-test.s3.amazonaws.com \
build \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
~/.config/nixpkgs#homeConfigurations.vagrant-alpine316.localdomain.activationPackage
```


```bash
export NIXPKGS_ALLOW_UNFREE=1

nix \
build \
--impure \
--eval-store auto \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
--store ssh-ng://builder \
--substituters '' \
~/.config/nixpkgs#homeConfigurations."$(hostname)"-"$(id -un)".activationPackage
```


```bash
nix \
build \
--impure \
--eval-store auto \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
--store ssh-ng://builder \
--substituters '' \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#pkgsCross.aarch64-darwin.pkgsStatic.dockerTools.examples.redis
```


```bash
nix \
build \
--keep-failed \
--no-link \
--print-build-logs \
--print-out-paths \
--rebuild \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#systemd
```


```bash
nix \
build \
--eval-store auto \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
--rebuild \
--store ssh-ng://builder \
--substituters '' \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#systemd
```


```bash
nix \
build \
--eval-store auto \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
--rebuild \
--store ssh-ng://builder \
--substituters '' \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#pkgsCross.x86_64-embedded.hello
```

```bash
nix \
build \
--eval-store auto \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
--rebuild \
--store ssh-ng://builder \
--substituters '' \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#pkgsCross.x86_64-embedded.pkgsStatic.hello
```


```bash
nix \
build \
--eval-store auto \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
--rebuild \
--store ssh-ng://builder \
--substituters '' \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#pkgsCross.aarch64-multiplatform.pkgsStatic.hello
```


```bash
export NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1

nix \
build \
--impure \
--eval-store auto \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
--rebuild \
--store ssh-ng://builder \
--substituters '' \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#pkgsCross.aarch64-darwin.pkgsStatic.dockerTools.examples.redis
```


```bash
# --max-jobs 0 \

nix \
build \
--option trusted-public-keys 'binarycache-1:EI/f6+36zVrbrmH0CiPOkC8s9JWVs+X6UpJv2VQUcsQ=' \
--store 's3://playing-bucket-nix-cache-test/' \
--eval-store auto \
--keep-failed \
--no-link \
--print-build-logs \
--print-out-paths \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#pkgsStatic.hello
```


```bash
# --max-jobs 0 \

nix \
build \
--option trusted-public-keys 'binarycache-1:EI/f6+36zVrbrmH0CiPOkC8s9JWVs+X6UpJv2VQUcsQ=' \
--store 's3://playing-bucket-nix-cache-test/' \
--eval-store auto \
--keep-failed \
--no-link \
--print-build-logs \
--print-out-paths \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#pkgsCross.aarch64-multiplatform.pkgsStatic.hello
```


```bash
nix \
store \
ls \
--store 's3://playing-bucket-nix-cache-test/' \
--long \
--recursive \
$(nix eval --raw github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#hello)
```



```bash
nix \
copy \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#python3 \
--to 's3://playing-bucket-nix-cache-test'
```



```bash
EXPR_NIX='
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

nix \
build \
--eval-store auto \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
--rebuild \
--store ssh-ng://builder \
--substituters '' \
--expr \
$EXPR_NIX
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
build \
--eval-store auto \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
--rebuild \
--refresh \
--store ssh-ng://builder \
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

# EXPECTED_SHA512='c24d5b36de84ebd88df2946bd65259d81cbfcb7da30690ecaeacb86e0c1028d4601e1f6165ea0775791c18161eee241092705cd350f0e935c715f2508c915741'
# EXPECTED_SHA512='5a761bd0f539a6ef53a002f73ee598e728565d7ac2f60a5947862d8795d233e3cf6bbf3c55f70a361f55e4b30e499238799d2ddb379e10a063d469d93276e3d8'
EXPECTED_SHA512='b6811ca1bc46b8b8dbc7dc94b62c71a83ef1a1dae0c7586e600010d8899100d2e58fb3aa585c398036f49b5e22a6a3ce10ceb142db0f37c098bc7e5a71894515'
ISO_PATTERN_NAME='result/iso/nixos-21.11.20210618.4b4f4bf-x86_64-linux.iso'
# sha512sum "${ISO_PATTERN_NAME}"
echo "${EXPECTED_SHA512}"'  '"${ISO_PATTERN_NAME}" | sha512sum -c
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



```bash
nix \
build \
--eval-store auto \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
--rebuild \
--store ssh-ng://builder \
github:NixOS/nixpkgs/3954218cf613eba8e0dcefa9abe337d26bc48fd0#pkgsCross.aarch64-multiplatform.pkgsStatic.hello
```


```bash
export HOST_MAPPED_PORT=10022
export REMOVE_DISK=true
export QEMU_NET_OPTS='hostfwd=tcp::10022-:10022'
export QEMU_OPTS='-nographic'
export SHARED_DIR="$(pwd)"

"$REMOVE_DISK" && rm -fv nixos.qcow2
nc -v -4 localhost "$HOST_MAPPED_PORT" -w 1 -z && echo 'There is something already using the port:'"$HOST_MAPPED_PORT"

# sudo lsof -t -i tcp:10022 -s tcp:listen
# sudo lsof -t -i tcp:10022 -s tcp:listen | sudo xargs --no-run-if-empty kill

cat << 'EOF' >> id_ed25519
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACCsoS8eR1Ot8ySeS8eI/jUwvzkGe1npaHPMvjp+Ou5JcgAAAIjoIwah6CMG
oQAAAAtzc2gtZWQyNTUxOQAAACCsoS8eR1Ot8ySeS8eI/jUwvzkGe1npaHPMvjp+Ou5Jcg
AAAEAbL0Z61S8giktfR53dZ2fztctV/0vML24doU0BMGLRZqyhLx5HU63zJJ5Lx4j+NTC/
OQZ7Weloc8y+On467klyAAAAAAECAwQF
-----END OPENSSH PRIVATE KEY-----
EOF

chmod -v 0600 id_ed25519


EXPR_NIX='
(
  (
    with builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4";
    with legacyPackages."aarch64-linux";
    let
      nixuserKeys = writeText "nixuser-keys.pub" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKyhLx5HU63zJJ5Lx4j+NTC/OQZ7Weloc8y+On467kly";
    in
    (
      builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4"
    ).lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/build-vm.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/qemu-vm.nix"
          # "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/qemu-guest.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/installer/cd-dvd/channel.nix"

          ({
            # https://gist.github.com/andir/88458b13c26a04752854608aacb15c8f#file-configuration-nix-L11-L12
            boot.loader.grub.extraConfig = "serial --unit=0 --speed=115200 \n terminal_output serial console; terminal_input serial console";
            boot.kernelParams = [
              "console=tty0"
              "console=ttyAMA0,115200n8"
              # Set sensible kernel parameters
              # https://nixos.wiki/wiki/Bootloader
              # https://git.redbrick.dcu.ie/m1cr0man/nix-configs-rb/commit/ddb4d96dacc52357e5eaec5870d9733a1ea63a5a?lang=pt-PT
              "boot.shell_on_fail"
              "panic=30"
              "boot.panic_on_fail" # reboot the machine upon fatal boot issues
              # TODO: test it
              # "intel_iommu=on"
              # "iommu=pt"

              # https://discuss.linuxcontainers.org/t/podman-wont-run-containers-in-lxd-cgroup-controller-pids-unavailable/13049/2
              # https://github.com/NixOS/nixpkgs/issues/73800#issuecomment-729206223
              # https://github.com/canonical/microk8s/issues/1691#issuecomment-977543458
              # https://github.com/grahamc/nixos-config/blob/35388280d3b06ada5882d37c5b4f6d3baa43da69/devices/petunia/configuration.nix#L36
              # cgroup_no_v1=all
              "swapaccount=0"
              "systemd.unified_cgroup_hierarchy=0"
              "group_enable=memory"
            ];

            boot.tmpOnTmpfs = false;
            # https://github.com/AtilaSaraiva/nix-dotfiles/blob/main/lib/modules/configHost/default.nix#L271-L273
            boot.tmpOnTmpfsSize = "100%";

              virtualisation = {
                # following configuration is added only when building VM with build-vm
                memorySize = 3072; # Use MiB memory.
                diskSize = 1024 * 16; # Use MiB memory.
                cores = 6;         # Simulate 3 cores.
                #
                docker.enable = false;
                useNixStoreImage = true;
                writableStore = true; # TODO: hardnig
              };

              nixpkgs.config.allowUnfree = true;
              nix = {
                package = nix;
                extraOptions = "experimental-features = nix-command flakes repl-flake";
                readOnlyStore = true;
              };

              # https://github.com/NixOS/nixpkgs/issues/21332#issuecomment-268730694
              services.openssh = {
                allowSFTP = true;
                kbdInteractiveAuthentication = false;
                enable = true;
                forwardX11 = false;
                passwordAuthentication = false;
                permitRootLogin = "yes";
                ports = [ 10022 ];
                authorizedKeysFiles = [
                  "${toString nixuserKeys}"
                ];
              };

            time.timeZone = "America/Recife";
            system.stateVersion = "22.11";

            users.users.root = {
              password = "root";
              initialPassword = "root";
              openssh.authorizedKeys.keyFiles = [
                nixuserKeys
              ];
            };
          })
        ];
    }
  ).config.system.build.vm
)
' 

# --rebuild \
#--substituters '' \
# --max-jobs 0 \

nix \
build \
--keep-failed \
--no-link \
--print-build-logs \
--print-out-paths \
--expr \
$EXPR_NIX

nix \
build \
--eval-store auto \
--keep-failed \
--no-link \
--print-build-logs \
--print-out-paths \
--store ssh-ng://builder \
--expr \
$EXPR_NIX 

nix \
run \
--impure \
--expr \
$EXPR_NIX \
< /dev/null &

while ! nc -t -w 1 -z localhost 10022; do echo $(date +'%d/%m/%Y %H:%M:%S:%3N'); sleep 0.5; done \
&& ssh-keygen -R '[localhost]:10022'; \
ssh \
-i id_ed25519 \
-tt \
-X \
-o StrictHostKeyChecking=no \
nixuser@localhost \
-p 10022
#<<COMMANDS
#id
#COMMANDS
#"$REMOVE_DISK" && rm -fv nixos.qcow2 id_ed25519
```





```bash
export HOST_MAPPED_PORT=10022
export REMOVE_DISK=true
export QEMU_NET_OPTS='hostfwd=tcp::10022-:10022'
export QEMU_OPTS='-nographic'
export SHARED_DIR="$(pwd)"

"$REMOVE_DISK" && rm -fv nixos.qcow2
nc -v -4 localhost "$HOST_MAPPED_PORT" -w 1 -z && echo 'There is something already using the port:'"$HOST_MAPPED_PORT"

# sudo lsof -t -i tcp:10022 -s tcp:listen
# sudo lsof -t -i tcp:10022 -s tcp:listen | sudo xargs --no-run-if-empty kill

cat << 'EOF' >> id_ed25519
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAMwAAAAtzc2gtZW
QyNTUxOQAAACCsoS8eR1Ot8ySeS8eI/jUwvzkGe1npaHPMvjp+Ou5JcgAAAIjoIwah6CMG
oQAAAAtzc2gtZWQyNTUxOQAAACCsoS8eR1Ot8ySeS8eI/jUwvzkGe1npaHPMvjp+Ou5Jcg
AAAEAbL0Z61S8giktfR53dZ2fztctV/0vML24doU0BMGLRZqyhLx5HU63zJJ5Lx4j+NTC/
OQZ7Weloc8y+On467klyAAAAAAECAwQF
-----END OPENSSH PRIVATE KEY-----
EOF

chmod -v 0600 id_ed25519

EXPR_NIX='
(
  (
    with builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4";
    with legacyPackages.aarch64-darwin;
    let
      nixuserKeys = writeText "nixuser-keys.pub" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKyhLx5HU63zJJ5Lx4j+NTC/OQZ7Weloc8y+On467kly";
    in
    (
      builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4"
    ).lib.nixosSystem {
        system = "aarch64-darwin";
        modules = [
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/build-vm.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/qemu-vm.nix"
          # "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/virtualisation/qemu-guest.nix"
          "${toString (builtins.getFlake "github:NixOS/nixpkgs/a8f8b7db23ec6450e384da183d270b18c58493d4")}/nixos/modules/installer/cd-dvd/channel.nix"

          ({
            # https://gist.github.com/andir/88458b13c26a04752854608aacb15c8f#file-configuration-nix-L11-L12
            boot.loader.grub.extraConfig = "serial --unit=0 --speed=115200 \n terminal_output serial console; terminal_input serial console";
            boot.kernelParams = [
              "console=tty0"
              "console=ttyAMA0,115200n8"
              # Set sensible kernel parameters
              # https://nixos.wiki/wiki/Bootloader
              # https://git.redbrick.dcu.ie/m1cr0man/nix-configs-rb/commit/ddb4d96dacc52357e5eaec5870d9733a1ea63a5a?lang=pt-PT
              "boot.shell_on_fail"
              "panic=30"
              "boot.panic_on_fail" # reboot the machine upon fatal boot issues
              # TODO: test it
              "intel_iommu=on"
              "iommu=pt"

              # https://discuss.linuxcontainers.org/t/podman-wont-run-containers-in-lxd-cgroup-controller-pids-unavailable/13049/2
              # https://github.com/NixOS/nixpkgs/issues/73800#issuecomment-729206223
              # https://github.com/canonical/microk8s/issues/1691#issuecomment-977543458
              # https://github.com/grahamc/nixos-config/blob/35388280d3b06ada5882d37c5b4f6d3baa43da69/devices/petunia/configuration.nix#L36
              # cgroup_no_v1=all
              "swapaccount=0"
              "systemd.unified_cgroup_hierarchy=0"
              "group_enable=memory"
            ];

            boot.tmpOnTmpfs = false;
            # https://github.com/AtilaSaraiva/nix-dotfiles/blob/main/lib/modules/configHost/default.nix#L271-L273
            boot.tmpOnTmpfsSize = "100%";

              virtualisation = {
                # following configuration is added only when building VM with build-vm
                memorySize = 3072; # Use MiB memory.
                diskSize = 1024 * 16; # Use MiB memory.
                cores = 6;         # Simulate 3 cores.
                #
                docker.enable = false;
                useNixStoreImage = true;
                writableStore = true; # TODO
              };

              nixpkgs.config.allowUnfree = true;
              nix = {
                package = nix;
                extraOptions = "experimental-features = nix-command flakes repl-flake";
                readOnlyStore = true;
              };

              # https://github.com/NixOS/nixpkgs/issues/21332#issuecomment-268730694
              services.openssh = {
                allowSFTP = true;
                kbdInteractiveAuthentication = false;
                enable = true;
                forwardX11 = false;
                passwordAuthentication = false;
                permitRootLogin = "yes";
                ports = [ 10022 ];
                authorizedKeysFiles = [
                  "${toString nixuserKeys}"
                ];
              };

            time.timeZone = "America/Recife";
            system.stateVersion = "22.11";

            users.users.root = {
              password = "root";
              initialPassword = "root";
              openssh.authorizedKeys.keyFiles = [
                nixuserKeys
              ];
            };
          })
        ];
    }
  ).config.system.build.vm
)
' 


nix \
build \
--eval-store auto \
--keep-failed \
--max-jobs 0 \
--no-link \
--print-build-logs \
--print-out-paths \
--rebuild \
--store ssh-ng://builder \
--substituters '' \
--expr \
$EXPR_NIX 

nix \
run \
--impure \
--expr \
$EXPR_NIX \
< /dev/null &

while ! nc -t -w 1 -z localhost 10022; do echo $(date +'%d/%m/%Y %H:%M:%S:%3N'); sleep 0.5; done \
&& ssh-keygen -R '[localhost]:10022'; \
ssh \
-i id_ed25519 \
-tt \
-X \
-o StrictHostKeyChecking=no \
nixuser@localhost \
-p 10022
#<<COMMANDS
#id
#COMMANDS
#"$REMOVE_DISK" && rm -fv nixos.qcow2 id_ed25519
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
--long \
--recursive \
$(
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
)
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

nix run '.#hello'
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
'.#slow-text'


# If the build is broken it does not work?
nix \
log \
--max-jobs 0 \
--eval-store auto \
--store ssh-ng://builder \
'.#slow-text'

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
nix build --max-jobs 0 --eval-store auto --store ssh-ng://builder nixpkgs#pkgsStatic.hello
```

```bash
nix build --max-jobs 0 --eval-store auto --store ssh-ng://builder --rebuild nixpkgs#pkgsStatic.hello
```

```bash
nix build --max-jobs 0 --eval-store auto --store ssh-ng://builder nixpkgs#pkgsStatic.python3
```


```bash
nix \
--option eval-cache false \
--option substituters = s3://playing-bucket-nix-cache-test https://cache.nixos.org \
--option trusted-public-keys = binarycache-1:CI+cN1SZBS+LQb3ubfHKge/VXLyCV0sDCgMjao+cNC4= \
build \
nixpkgs#pkgsStatic.python3
```

```bash
nix build --max-jobs 0 --eval-store auto --store s3://playing-bucket-nix-cache-test nixpkgs#pkgsStatic.python3
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
mkdir -pv ~/sandbox/sandbox && cd $_
```

```bash
rm -frv custom-build-hook.sh

tee custom-build-hook.sh <<'EOF'
#!/usr/bin/env bash

set -euf 

echo "post-build-hook"
echo "-- ${OUT_PATHS} --"
echo "^^ ${DRV_PATH} ^^"

# set -x

KEY_FILE=/etc/nix/private-key
# Testar ?region=eu-west-1
CACHE=s3://playing-bucket-nix-cache-test/

# mapfile -t DERIVATIONS < <(echo "${OUT_PATHS[@]}" | xargs nix path-info --derivation)
mapfile -t DERIVATIONS < <(echo "${OUT_PATHS[@]}" | xargs nix path-info)
mapfile -t DEPENDENCIES < <(echo "${DRV_PATH[@]}" | xargs nix-store --query --requisites --include-outputs --force-realise)

# TODO: é o correto assinar as derivações, os .drv?
# echo "${DERIVATIONS[@]}" | xargs nix store sign --key-file "$KEY_FILE" --recursive

# TODO:
# echo "${DEPENDENCIES[@]}" | xargs nix store sign --key-file "$KEY_FILE" --recursive

echo "${DEPENDENCIES[@]}" | xargs nix copy --eval-store auto --no-check-sigs -vvv --to "$CACHE"
# echo "${DEPENDENCIES[@]}" | xargs nix copy -vvv --to "$CACHE"

EOF

chmod -v 0755 custom-build-hook.sh

# ./custom-build-hook.sh
```

```bash
nix build --max-jobs $(nproc) --rebuild --no-link --print-build-logs \
nixpkgs#hello --post-build-hook ./custom-build-hook.sh
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

#### Other keys

```bash
hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs=
```
Refs.:
- https://www.mankier.com/5/nix.conf

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

