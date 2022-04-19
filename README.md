# terraform-ec2




If you use `nix-direnv` + `direnv`, just `cd` into the project cloned folder. 

```bash
nix develop .#
```

```bash
aws configure
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
&& TERRAFORM_OUTPUT_PUBLIC_IP="$(terraform output public_ip)" \
&& sleep 30 \
&& ssh \
    ubuntu@"${TERRAFORM_OUTPUT_PUBLIC_IP}" \
    -i ~/.ssh/my-ec2.pem \
    -o StrictHostKeyChecking=no
```


TODO: 
- The `key_name` (`my-ec2.pem`) needs some manual work.
- Explain all steps need to make it work
- Change the sleep 30 with some "smarter logic of retry" 

References

- https://learn.hashicorp.com/tutorials/terraform/module-use