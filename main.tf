resource "aws_key_pair" "auth_key" {

  key_name   = "${var.project_name}-${var.project_env}"
  public_key = file("mykey.pub")
  tags = {
    Name        = "${var.project_name}-${var.project_env}"
    Project     = var.project_name
    Environment = var.project_env
    owner       = var.project_owner
  }
}
resource "aws_security_group" "web-access" {

  name        = "${var.project_name}-${var.project_env}-web-access"
  description = "${var.project_name}-${var.project_env}-web-access"


  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }
  tags = {
    Name        = "${var.project_name}-${var.project_env}-web-access"
    Project     = var.project_name
    Environment = var.project_env
  }
}
resource "aws_security_group" "remote_access" {

  name        = "${var.project_name}-${var.project_env}-remote_access"
  description = "${var.project_name}-${var.project_env}-remote_access"

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]

  }
  tags = {
    Name        = "${var.project_name}-${var.project_env}-remote_access"
    Project     = var.project_name
    Environment = var.project_env
  }
}
resource "aws_instance" "frontend" {

  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.auth_key.key_name
  user_data              = file("setup.sh")
  vpc_security_group_ids = [aws_security_group.web-access.id, aws_security_group.remote_access.id]

  tags = {
    Name        = "${var.project_name}-${var.project_env}-frontend"
    Project     = var.project_name
    Environment = var.project_env
  }

  lifecycle {

    create_before_destroy = true
  }
}
resource "aws_eip" "frontend" {
  instance = aws_instance.frontend.id
  domain   = "vpc"
  tags = {
    Name        = "${var.project_name}-${var.project_env}-frontend"
    Project     = var.project_name
    Environment = var.project_env
  }
}

resource "aws_route53_record" "frontend" {

  zone_id = data.aws_route53_zone.official.id
  name    = "${var.hostname}.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [aws_eip.frontend.public_ip]
}
