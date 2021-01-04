provider "aws" {
  profile = "default"
  region = var.aws_region
  version = "~> 3.22"
}

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}
