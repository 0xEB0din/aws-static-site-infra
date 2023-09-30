output "alb_dns_name" {
  value = aws_lb.main.dns_name
}

output "s3_website_url" {
  value = aws_s3_bucket.hosting_bucket.website_endpoint
}