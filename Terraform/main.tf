terraform {
    backend "s3" {
    bucket = "onboarding-tf-backend"
    key    = "todo/terrraform.tfstate"
    region = "eu-central-1"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region  = "eu-north-1"
}

variable "db_password" {
  type = string
  sensitive = true
}

data "aws_availability_zones" "available" {
  state = "available"
}