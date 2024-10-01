import jwt, datetime

# TODO: These three things must be correct.
# Match the issuer to your website.
# Match sub and aud to the values in Terraform.
iss = "https://oidc.mydomain.com"
sub = "test-subject-user"
aud = "my-client-id"

iat = datetime.datetime.now(datetime.timezone.utc)
exp = iat + datetime.timedelta(minutes=20)

key_path = "../oidc_keys/private.pem"

with open(key_path, "rb") as key_file:
    private_key = key_file.read()

# Create the JWT
new_token = jwt.encode(
    {"sub": sub, "aud": aud, "iss": iss, "iat": iat, "exp": exp},
    private_key,
    algorithm="RS256",
    headers={"kid": "1234"}
)

print(new_token)

# Verify if the JWT is usable with our endpoint.
from jwt import PyJWKClient
jwks_client = PyJWKClient(f'{iss}/jwks/keys')
signing_key = jwks_client.get_signing_key_from_jwt(new_token)
jwt.decode(
    new_token,
    signing_key,
    audience=aud,
    options={"verify_exp": True},
    algorithms=["RS256"],
)