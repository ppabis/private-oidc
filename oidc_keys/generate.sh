#!/bin/bash

echo "Generating a 2048 bit RSA key pair..."
openssl genrsa -out private.pem 2048
openssl rsa -in private.pem -pubout -outform PEM -out public.pem

echo "Creating Python virtual environment with packages..."
python3 -m venv venv
source venv/bin/activate
pip install cryptography

echo "Converting public key..."
python3 extract_ne.py

echo "Creating openid-configuration..."
python3 openid_configure.py

echo "Cleaning up..."
rm -rf venv