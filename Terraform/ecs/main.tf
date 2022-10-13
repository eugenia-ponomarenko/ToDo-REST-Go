terraform {
    backend "s3" {
    bucket = "onboarding-tf-backend"
    key    = "todo-serverless-ecs/terrraform.tfstate"
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

data "aws_availability_zones" "available" {
  state = "available"
}

variable "lb_target_arn" {
  type = string
}

variable "ecs_sg_id" {
  type = string
}

variable "public_subnet_0" {
  type = string
}

variable "public_subnet_1" {
  type = string
}

variable "public_subnet_2" {
  type = string
}

variable "sns_topic_arn" {
  type = string
}