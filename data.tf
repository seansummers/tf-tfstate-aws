data "aws_iam_policy_document" "tfstate_default" {
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.tfstate.arn]
  }
  statement {
    actions   = ["s3:GetObject", "s3:PutObject"]
    resources = ["${aws_s3_bucket.tfstate.arn}/*"]
  }
  statement {
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
    ]
    resources = [aws_dynamodb_table.tfstate.arn]
  }
}

data "aws_iam_policy_document" "tfstate_workspaces" {
  statement {
    actions   = ["s3:DeleteObject"]
    resources = ["${aws_s3_bucket.tfstate.arn}/*"]
  }
}

data "aws_iam_policy_document" "tfstate_boundary" {
  statement {
    actions = [
      "s3:ListBucket",
    ]
    resources = [aws_s3_bucket.tfstate.arn]
  }
  statement {
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = ["${aws_s3_bucket.tfstate.arn}/*"]
  }
  statement {
    actions = [
      "dynamodb:DescribeTable",
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:DeleteItem",
    ]
    resources = [aws_dynamodb_table.tfstate.arn]
  }
}

data "aws_iam_policy_document" "tfstate_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [local.external_id]
    }
    #condition {
    #  test     = "Bool"
    #  variable = "aws:MultiFactorAuthPresent"
    #  values   = [true]
    #}
  }
}

data "aws_caller_identity" "current" {}
resource "random_string" "external_id" {
  length           = 32
  lower            = true
  min_lower        = 2
  min_numeric      = 2
  min_special      = 2
  min_upper        = 2
  numeric          = true
  override_special = "+=,.@:/-"
  special          = true
  upper            = true
  # from https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_iam-condition-keys.html
}
