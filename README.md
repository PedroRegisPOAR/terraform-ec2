# terraform-ec2

TODO: The `key_name` (`my-ec2.pem`) needs some manual work.


```bash
nix develop
```

TODO: check if it is needed in the first time
```bash
make init
```

```bash
make destroy args='-auto-approve' \
&& make apply args='-auto-approve' \
&& sleep 30 \
&& ssh ubuntu@$(terraform output public_ip) -i ~/.ssh/my-ec2.pem
```
