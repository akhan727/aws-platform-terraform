# 1. The bucket (AWS adds a unique suffix to the name)
resource "aws_s3_bucket" "history" {
  bucket_prefix = "${var.name_prefix}-history-"
  force_destroy = true # lab only: lets terraform destroy remove files
}

# 2. Never public
resource "aws_s3_bucket_public_access_block" "history" {
  bucket                  = aws_s3_bucket.history.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 3. Encrypted at rest
resource "aws_s3_bucket_server_side_encryption_configuration" "history" {
  bucket = aws_s3_bucket.history.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 4. Keep older versions as a safety net
resource "aws_s3_bucket_versioning" "history" {
  bucket = aws_s3_bucket.history.id

  versioning_configuration {
    status = "Enabled"
  }
}

# 5. Hot -> warm -> cold -> gone, for files under raw/
resource "aws_s3_bucket_lifecycle_configuration" "history" {
  bucket     = aws_s3_bucket.history.id
  depends_on = [aws_s3_bucket_versioning.history]

  rule {
    id     = "hot-to-cold"
    status = "Enabled"

    filter {
      prefix = "raw/"
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA" # warm
    }

    transition {
      days          = 90
      storage_class = "GLACIER" # cold
    }

    expiration {
      days = 365 # gone
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}
