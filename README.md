# terraform-ec2

TODO: The `key_name` (`my-ec2.pem`) needs some manual work.

TODO: $(terraform output public_ip) + ssh


```bash
make destroy args='-auto-approve' \
&& make apply args='-auto-approve' \
&& sleep 30 \
&& ssh ubuntu@$(terraform output public_ip) -i ~/.ssh/my-ec2.pem
```
