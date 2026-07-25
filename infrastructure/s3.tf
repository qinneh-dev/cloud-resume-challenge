resource "aws_s3_bucket" "website_bucket" {
  bucket = "omaralqinneh-resume-bucket-eu" 
}

# blocking public access to the bucket
resource "aws_s3_bucket_public_access_block" "website_bucket_pab" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}