terraform {
  backend "s3" {
    bucket = "redmi-project-vannarath.site"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}
