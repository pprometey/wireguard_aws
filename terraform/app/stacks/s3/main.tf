resource "aws_s3_bucket_object" "objects" {
  for_each = fileset("${path.module}/shell-scripts/", "*")
  bucket = var.bucket
  key = "wireguard/${each.value}"
  source = "${path.module}/shell-scripts/${each.value}"
  etag = filemd5("${path.module}/shell-scripts/${each.value}")
}