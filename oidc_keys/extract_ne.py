#!/usr/bin/env python3
# extract_ne.py
from cryptography.hazmat.primitives import serialization
import json, base64

with open('public.pem', 'rb') as key_file:
    pub = serialization.load_pem_public_key(key_file.read())

# Extract modulus and exponent
modulus = pub.public_numbers().n
exponent = pub.public_numbers().e

# 1. Convert to raw bytes with big-endian encoding
# 2. Because numbers are large, we have to specify the number of bytes. We pick the shortest length using this math and align to full bytes.
# 3. Encode to base64 and remove '=' padding.
modulus = base64\
    .urlsafe_b64encode( modulus.to_bytes((modulus.bit_length() + 7) // 8, 'big') )\
    .decode('utf-8')\
    .rstrip('=')

exponent = base64\
    .urlsafe_b64encode( exponent.to_bytes((exponent.bit_length() + 7) // 8, 'big') )\
    .decode('utf-8')\
    .rstrip('=')

# Format as proper JWK JSON
keys = {
    'keys': [
        {
            'kty': 'RSA',
            'alg': 'RS256',
            'use': 'sig',
            'n': modulus,
            'e': exponent,
            'kid': '1234' # This has to match the kid in the JWT generator
        }
    ]
}

with open('public.json', 'w') as json_file:
    json.dump(keys, json_file)