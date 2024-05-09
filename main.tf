resource "aws_s3_bucket" "tfstate" {
  bucket        = local.this
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "tfstate" {
  bucket                  = aws_s3_bucket.tfstate.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id
  rule {
    id = "expire_noncurrent_and_deleted"
    abort_incomplete_multipart_upload {
      days_after_initiation = 1
    }
    expiration {
      expired_object_delete_marker = true
    }
    noncurrent_version_expiration {
      noncurrent_days = 90
    }
    status = "Enabled"
  }
}

resource "aws_dynamodb_table" "tfstate" {
  name         = aws_s3_bucket.tfstate.bucket
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "local_file" "backend_hcl" {
  filename = "${path.cwd}/backend.hcl"
  content = templatefile("backend.hcl.tftpl", {
    bucket_name    = aws_s3_bucket.tfstate.id,
    dynamodb_table = aws_dynamodb_table.tfstate.id,
    region         = aws_s3_bucket.tfstate.region
    role_arn       = aws_iam_role.tfstate.arn
    external_id    = local.external_id
  })
}

output "backend_hcl" {
  value = local_file.backend_hcl.content
}

resource "onepassword_item" "tfstate" {
  vault    = "Shared"
  title    = "Terraform State"
  category = "login"
  username = "TF State Backend Config"

  section {
    label = "Backend Configuration"
    field {
      label = "S3 Region"
      type  = "STRING"
      value = aws_s3_bucket.tfstate.region
    }
    field {
      label = "S3 Bucket"
      type  = "STRING"
      value = aws_s3_bucket.tfstate.id
    }
    field {
      label = "S3 Lock Table"
      type  = "STRING"
      value = aws_dynamodb_table.tfstate.id
    }
    field {
      label   = "backend.hcl"
      type    = "STRING"
      purpose = "NOTES"
      value   = local_file.backend_hcl.content
    }
  }
  lifecycle {
    ignore_changes = [vault]
  }
}

resource "aws_iam_policy" "tfstate_default" {
  name   = "${local.this}-default"
  policy = data.aws_iam_policy_document.tfstate_default.json
}

resource "aws_iam_policy" "tfstate_workspaces" {
  name   = "${local.this}-workspaces"
  policy = data.aws_iam_policy_document.tfstate_workspaces.json
}

resource "aws_iam_role" "tfstate" {
  name                 = local.this
  assume_role_policy   = data.aws_iam_policy_document.tfstate_assume_role.json
  max_session_duration = 43200 # 12 hour max
  permissions_boundary = resource.aws_iam_policy.tfstate_boundary.arn
}

resource "aws_iam_policy" "tfstate_boundary" {
  name   = "${local.this}-boundary"
  policy = data.aws_iam_policy_document.tfstate_boundary.json
}

resource "aws_iam_role_policy_attachment" "tfstate_default" {
  role       = aws_iam_role.tfstate.name
  policy_arn = aws_iam_policy.tfstate_default.arn
}

resource "aws_iam_role_policy_attachment" "tfstate_workspaces" {
  role       = aws_iam_role.tfstate.name
  policy_arn = aws_iam_policy.tfstate_workspaces.arn
}

resource "random_pet" "tfstate" {
  prefix = "tfstate"
  length = 3
}
