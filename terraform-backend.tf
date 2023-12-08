terraform {
  backend "s3" {
    bucket = "redmi-project-svannarath.site"
    key    = "terraform.tfstate"
    region = "ap-south-1"
  }
}
