terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "random_id" "suffix" {
  byte_length = 4
}

# Look up the default VPC so we don't use a placeholder ID
data "aws_vpc" "default" {
  default = true
}

#importing an existing s3 bucket
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-existing-bucket-${random_id.suffix.hex}"
}

resource "aws_s3_bucket_public_access_block" "my_bucket_pab" {
  bucket                  = aws_s3_bucket.my_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "my_bucket_policy" {
  bucket     = aws_s3_bucket.my_bucket.id
  depends_on = [aws_s3_bucket_public_access_block.my_bucket_pab]
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.my_bucket.arn}/*"
    }]
  })
}

#creating a new s3 bucket
resource "aws_s3_bucket" "new_bucket" {
  bucket = "my-new-bucket-${random_id.suffix.hex}"
}

resource "aws_s3_bucket_ownership_controls" "new_bucket_ownership" {
  bucket = aws_s3_bucket.new_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "new_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.new_bucket_ownership]
  bucket     = aws_s3_bucket.new_bucket.id
  acl        = "private"
}

#creating a new s3 bucket with versioning enabled
resource "aws_s3_bucket" "versioned_bucket" {
  bucket = "my-versioned-bucket-${random_id.suffix.hex}"
}

resource "aws_s3_bucket_ownership_controls" "versioned_bucket_ownership" {
  bucket = aws_s3_bucket.versioned_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "versioned_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.versioned_bucket_ownership]
  bucket     = aws_s3_bucket.versioned_bucket.id
  acl        = "private"
}

resource "aws_s3_bucket_versioning" "versioned_bucket_versioning" {
  bucket = aws_s3_bucket.versioned_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

#creating a new s3 bucket with encryption enabled
resource "aws_s3_bucket" "encrypted_bucket" {
  bucket = "my-encrypted-bucket-${random_id.suffix.hex}"
}

resource "aws_s3_bucket_ownership_controls" "encrypted_bucket_ownership" {
  bucket = aws_s3_bucket.encrypted_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "encrypted_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.encrypted_bucket_ownership]
  bucket     = aws_s3_bucket.encrypted_bucket.id
  acl        = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encrypted_bucket_sse" {
  bucket = aws_s3_bucket.encrypted_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

#creating a new s3 bucket with lifecycle rules
resource "aws_s3_bucket" "lifecycle_bucket" {
  bucket = "my-lifecycle-bucket-${random_id.suffix.hex}"
}

resource "aws_s3_bucket_ownership_controls" "lifecycle_bucket_ownership" {
  bucket = aws_s3_bucket.lifecycle_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "lifecycle_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.lifecycle_bucket_ownership]
  bucket     = aws_s3_bucket.lifecycle_bucket.id
  acl        = "private"
}

resource "aws_s3_bucket_lifecycle_configuration" "lifecycle_bucket_lifecycle" {
  bucket = aws_s3_bucket.lifecycle_bucket.id
  rule {
    id     = "log"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    expiration {
      days = 365
    }

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    filter {}

    noncurrent_version_expiration {
      noncurrent_days = 365
    }
  }
}

#creating a new s3 bucket with a policy
resource "aws_s3_bucket" "policy_bucket" {
  bucket = "my-policy-bucket-${random_id.suffix.hex}"
}

resource "aws_s3_bucket_ownership_controls" "policy_bucket_ownership" {
  bucket = aws_s3_bucket.policy_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "policy_bucket_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.policy_bucket_ownership]
  bucket     = aws_s3_bucket.policy_bucket.id
  acl        = "private"
}

resource "aws_s3_bucket_public_access_block" "policy_bucket_pab" {
  bucket                  = aws_s3_bucket.policy_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "policy_bucket_policy" {
  bucket     = aws_s3_bucket.policy_bucket.id
  depends_on = [aws_s3_bucket_public_access_block.policy_bucket_pab]
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "${aws_s3_bucket.policy_bucket.arn}/*"
    }]
  })
}

#import an existing security group
resource "aws_security_group" "my_security_group" {
  name        = "my-existing-security-group"
  description = "My existing security group"
  vpc_id      = data.aws_vpc.default.id
}

#creating a new security group
resource "aws_security_group" "new_security_group" {
  name        = "my-new-security-group"
  description = "My new security group"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#creating a new security group with tags
resource "aws_security_group" "tagged_security_group" {
  name        = "my-tagged-security-group"
  description = "My tagged security group"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Environment = "Production"
    Owner       = "John Doe"
  }
}
