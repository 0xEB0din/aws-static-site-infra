provider "aws" {
  region = var.aws_region
}

# VPC and Subnet config
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16" # Example CIDR block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"        # CIDR block for the first subnet
  availability_zone       = "${var.aws_region}a" # Adjust based on your region, e.g., us-west-2a
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-a"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"        # CIDR block for the second subnet
  availability_zone       = "${var.aws_region}b" # Adjust based on your region, e.g., us-west-2b
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-b"
  }
}


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public.id
}

# ALB config
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.main.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow all IPs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_lb" "main" {
  name               = "demo-alb-staticsite"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets = [
    aws_subnet.public_subnet_a.id,
    aws_subnet.public_subnet_b.id
  ]
  enable_deletion_protection = false
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      port        = "80"
      protocol    = "HTTP"
      status_code = "HTTP_301"
      host        = "${var.bucket_name}.s3-website.${var.aws_region}.amazonaws.com"
      path        = "/#{path}"
    }
  }
}



# S3 Bucket
resource "aws_s3_bucket" "hosting_bucket" {
  bucket = var.bucket_name
  tags = {
    "Name"        = "Static Site Hosting Bucket"
    "Environment" = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "hosting_bucket" {
  bucket                  = aws_s3_bucket.hosting_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "hosting_bucket_policy" {
  depends_on = [aws_s3_bucket_public_access_block.hosting_bucket]
  bucket     = aws_s3_bucket.hosting_bucket.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource" : "arn:aws:s3:::${var.bucket_name}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_website_configuration" "hosting_bucket_website_configuration" {
  bucket = aws_s3_bucket.hosting_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_object" "hosting_bucket_files" {
  for_each = fileset("${path.module}/site", "**/*") # All files in '/site' to be uploaded

  bucket = aws_s3_bucket.hosting_bucket.id
  key    = each.value
  source = "${path.module}/site/${each.value}"
  etag   = filemd5("${path.module}/site/${each.value}")
}
