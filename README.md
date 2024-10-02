Private OpenID Connect identity provider for IAM.
----------------

Read this post to know more:
https://pabis.eu/blog/2024-09-30-Private-Self-Hosted-OIDC-AWS-Authentication.html

### Configuration
#### Step 1.
Go to `oidc_website`. Edit `terraform.tfvars` to match your domain.
If you wish to use CloudFront default, leave the values empty (`""`).
Run `tofu init` and `tofu apply`.

#### Step 2.
Go to `oidc_keys`. Run `./generate.sh`. Type either your domain you use
or the one created by CloudFront if you don't have a domain.

#### Step 3.
Go to `oidc_s3` and run `upload.sh`.

#### Step 3.
Go to `oidc_role`. Edit `terraform.tfvars` to match your domain.

#### Step 4.
Go to `token_signer`. Run `pip install -r requirements.txt`.
Edit values in `token_signer.py` to match your domain.
Test by running `python3 token_signer.py` if token validation
passes.

#### Step 5.
Get the role ARN from `oidc_role` Terraform output. Go to `token_signer`.
Run the following to assume the role:

```bash
$ aws sts assume-role-with-web-identity \
 --role-session-name test-session-abc123def \
 --duration-seconds 900 \
 --web-identity-token $(python3 token_signer.py) \
 --role-arn ${ROLE_ARN}
```
