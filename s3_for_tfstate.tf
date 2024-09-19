resource "aws_s3_bucket" "terraform_state" {
    bucket = "sameer-practice-terraform-state-backend"
    force_destroy = true
    
    tags = {
        Name = "S3 Remote Terraform State Store"
    }
}

resource "aws_s3_bucket_versioning" "versioning_tfstate" {
    bucket = aws_s3_bucket.terraform_state.id
    versioning_configuration {
        status = "Enabled"
    }
} 

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_tfstate" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_object_lock_configuration" "olock_tfstate" {
  bucket = aws_s3_bucket.terraform_state.id
  object_lock_enabled = "Enabled"

  # rule {
  #   default_retention {
  #     mode = "COMPLIANCE"
  #     days = 5
  #   }
  # }
}