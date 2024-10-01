# Creates an IAM OpenID Connect provider. But first it retrieves
# the thumbprint of the certificate that is presented by the HTTPS
# website at this domain. It is SHA-1 hash of the certificate.
resource "null_resource" "get_thumbprint" {
  provisioner "local-exec" {
    command = "./get_thumbprint.sh ${var.domain_name} | tee thumbprint.txt"
  }
}

resource "aws_iam_openid_connect_provider" "provider" {
  url             = "https://${var.domain_name}"
  client_id_list  = ["my-client-id"] # This has to match the audience in JWT signer
  thumbprint_list = [file("thumbprint.txt")]
  depends_on      = [null_resource.get_thumbprint]
}