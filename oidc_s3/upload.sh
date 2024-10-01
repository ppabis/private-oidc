#!/bin/bash

cd ../oidc_website
BUCKET_NAME=$(tofu output -raw bucket_name)
cd ../oidc_s3
# Upload the keys to S3
aws s3 cp index.html s3://${BUCKET_NAME}/
aws s3 cp ../oidc_keys/openid-configuration s3://${BUCKET_NAME}/.well-known/openid-configuration
aws s3 cp ../oidc_keys/public.json s3://${BUCKET_NAME}/jwks/keys

echo "Website uploaded to S3."
