import json

with open('openid-configuration.json', 'r') as file:
    data = json.load(file)

domain = input("Enter your domain (such as oidc.mywebsite.net): ")

data['issuer'] = f"https://{domain}"
data['jwks_uri'] = f"https://{domain}/jwks/keys"

with open('openid-configuration', 'w') as file:
    json.dump(data, file, indent=2)

print("openid-configuration created.")