data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "trust_oidc" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.provider.arn]
    }
    condition {
      test     = "StringLike"
      variable = "${var.domain_name}:sub"
      values   = ["test-subject-user"] # This has to match the subject in JWT signer
    }
  }
}

resource "aws_iam_role" "oidc_role" {
  name               = "RoleForCustomOIDCProvider"
  assume_role_policy = data.aws_iam_policy_document.trust_oidc.json
}

output "oidc_role_to_assume" {
  value = aws_iam_role.oidc_role.arn
}