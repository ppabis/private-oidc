#!/bin/bash

# Based on https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html

if [ -z "$1" ]; then
  read -p "Enter the domain name: " domain_name
else
  domain_name=$1
fi

# Get hex representation of the thumbprint
THUMBPRINT=$(\
 echo "" | \
 openssl s_client \
  -servername $domain_name \
  -showcerts \
  -connect $domain_name:443 \
  2>/dev/null | \
 openssl x509 -fingerprint -sha1 -noout | \
 cut -d= -f2 | \
 tr -d : | \
 tr 'A-F' 'a-f')

echo -n $THUMBPRINT | tee thumbprint.txt